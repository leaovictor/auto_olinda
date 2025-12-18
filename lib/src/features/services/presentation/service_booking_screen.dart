import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../data/independent_service_repository.dart';
import '../domain/independent_service.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../shared/utils/app_toast.dart';
import '../../auth/data/auth_repository.dart';
import '../../subscription/data/subscription_repository.dart';
import 'package:flutter/foundation.dart';
import '../domain/service_booking.dart';
import '../../subscription/presentation/widgets/web_payment_sheet.dart';

/// Screen for booking an independent service with premium UX
class ServiceBookingScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceBookingScreen({super.key, required this.serviceId});

  @override
  ConsumerState<ServiceBookingScreen> createState() =>
      _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends ConsumerState<ServiceBookingScreen> {
  DateTime? _selectedDay;
  String? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingSlots = false;
  IndependentService? _service;
  Map<String, int> _availableSlots = {};
  Map<String, bool> _daysWithAvailability = {};
  late ConfettiController _confettiController;

  // Generate next 14 days for horizontal picker
  late List<DateTime> _availableDates;

  @override
  void initState() {
    super.initState();
    _availableDates = List.generate(
      14,
      (i) => DateTime.now().add(Duration(days: i)),
    );
    _selectedDay = _availableDates.first;
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadService();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    final service = await ref
        .read(independentServiceRepositoryProvider)
        .getService(widget.serviceId);
    if (mounted) {
      setState(() => _service = service);
      _loadAvailability();
      _loadAllDaysAvailability();
    }
  }

  Future<void> _loadAllDaysAvailability() async {
    if (_service == null) return;

    // Load in background for next 14 days in parallel
    final availabilityFutures = _availableDates.map((date) async {
      final slots = await ref
          .read(independentServiceRepositoryProvider)
          .getAvailableSlots(date, widget.serviceId);
      return (DateFormat('yyyy-MM-dd').format(date), slots.isNotEmpty);
    });

    final results = await Future.wait(availabilityFutures);

    if (mounted) {
      setState(() {
        for (final result in results) {
          _daysWithAvailability[result.$1] = result.$2;
        }
      });
    }
  }

  Future<void> _loadAvailability() async {
    if (_selectedDay == null || _service == null) return;

    setState(() => _isLoadingSlots = true);

    final slots = await ref
        .read(independentServiceRepositoryProvider)
        .getAvailableSlots(_selectedDay!, widget.serviceId);

    if (mounted) {
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
        _selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_service == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: AppLoader()),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Premium gradient app bar
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Agendar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.purple.shade700, Colors.pink.shade500],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                        child: Text(
                          _service!.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service summary card
                      _buildServiceSummary(theme),
                      const SizedBox(height: 24),

                      // Step 1: Date selection
                      _buildStepHeader(
                        theme,
                        1,
                        'Escolha a data',
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _buildDatePicker(theme),
                      const SizedBox(height: 24),

                      // Step 2: Time selection
                      _buildStepHeader(
                        theme,
                        2,
                        'Escolha o horário',
                        Icons.access_time,
                      ),
                      const SizedBox(height: 12),
                      _buildTimeSlots(theme),
                      const SizedBox(height: 24),

                      // Summary before payment
                      if (_selectedTime != null) ...[
                        _buildBookingSummary(
                          theme,
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                        const SizedBox(height: 16),
                      ],

                      // CTA Button
                      _buildCTAButton(theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _service!.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.attach_money,
                      'R\$ ${_service!.price.toStringAsFixed(0)}',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.timer_outlined,
                      '${_service!.durationMinutes} min',
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(
    ThemeData theme,
    int step,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.pink.shade400],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.purple.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        itemBuilder: (context, index) {
          final date = _availableDates[index];
          final isSelected =
              _selectedDay != null &&
              date.day == _selectedDay!.day &&
              date.month == _selectedDay!.month;
          final isToday =
              date.day == DateTime.now().day &&
              date.month == DateTime.now().month;

          final dayName = DateFormat('EEE', 'pt_BR').format(date).toUpperCase();
          final dayNum = date.day.toString();
          final monthName = DateFormat(
            'MMM',
            'pt_BR',
          ).format(date).toUpperCase();

          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          final hasAvailability = _daysWithAvailability[dateStr] ?? false;

          return GestureDetector(
                onTap: () {
                  setState(() => _selectedDay = date);
                  _loadAvailability();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
                  width: 70,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade600,
                              Colors.pink.shade500,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.purple.shade300, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNum,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (hasAvailability) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn()
              .slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildTimeSlots(ThemeData theme) {
    if (_isLoadingSlots) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Nenhum horário disponível',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tente selecionar outra data',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    final sortedTimes = _availableSlots.keys.toList()..sort();

    // Group times by period (morning, afternoon)
    final morning = sortedTimes
        .where((t) => int.parse(t.split(':')[0]) < 12)
        .toList();
    final afternoon = sortedTimes
        .where((t) => int.parse(t.split(':')[0]) >= 12)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) ...[
          _buildPeriodLabel(theme, '☀️ Manhã'),
          const SizedBox(height: 8),
          _buildTimeGrid(theme, morning),
          const SizedBox(height: 16),
        ],
        if (afternoon.isNotEmpty) ...[
          _buildPeriodLabel(theme, '🌤️ Tarde'),
          const SizedBox(height: 8),
          _buildTimeGrid(theme, afternoon),
        ],
      ],
    );
  }

  Widget _buildPeriodLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTimeGrid(ThemeData theme, List<String> times) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.asMap().entries.map((entry) {
        final index = entry.key;
        final time = entry.value;
        final slots = _availableSlots[time]!;
        final isSelected = _selectedTime == time;
        final isLowAvailability = slots == 1;

        return GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.purple.shade600,
                            Colors.pink.shade500,
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: !isSelected
                      ? Border.all(
                          color: isLowAvailability
                              ? Colors.orange.shade200
                              : theme.colorScheme.outline.withOpacity(0.2),
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLowAvailability)
                          Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: isSelected
                                ? Colors.white
                                : Colors.orange.shade600,
                          ),
                        Text(
                          '$slots vaga${slots > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : isLowAvailability
                                ? Colors.orange.shade600
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isLowAvailability
                                ? FontWeight.w600
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: 30 * index))
            .fadeIn()
            .scale(begin: const Offset(0.9, 0.9));
      }).toList(),
    );
  }

  Widget _buildBookingSummary(ThemeData theme) {
    final dateStr = DateFormat(
      "EEEE, d 'de' MMMM",
      'pt_BR',
    ).format(_selectedDay!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo do agendamento',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr às $_selectedTime',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(ThemeData theme) {
    final isEnabled = _selectedTime != null && !_isLoading;

    return GestureDetector(
      onTap: isEnabled ? _showPaymentOptions : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [Colors.purple.shade600, Colors.pink.shade500],
                )
              : null,
          color: isEnabled ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment,
                    color: isEnabled ? Colors.white : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Continuar para Pagamento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEnabled
                          ? Colors.white
                          : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showPaymentOptions() async {
    if (_selectedDay == null || _selectedTime == null || _service == null) {
      return;
    }

    final subscription = await ref.read(userSubscriptionProvider.future);
    final isPremium = subscription != null;

    if (!mounted) return;

    if (isPremium) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildPaymentOptionsSheet(ctx),
      );
    } else {
      _processStripePayment();
    }
  }

  Widget _buildPaymentOptionsSheet(BuildContext ctx) {
    final theme = Theme.of(ctx);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Como deseja pagar?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Benefício Premium',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildPaymentOption(
            ctx,
            icon: Icons.credit_card,
            title: 'Pagar Agora',
            subtitle: 'Cartão via Stripe',
            color: Colors.purple,
            onTap: () {
              Navigator.pop(ctx);
              _processStripePayment();
            },
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            ctx,
            icon: Icons.store,
            title: 'Pagar no Local',
            subtitle: 'PIX, dinheiro ou cartão',
            color: Colors.green,
            onTap: () {
              Navigator.pop(ctx);
              _confirmBookingPayOnSite();
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(ctx);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _processStripePayment() async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      final result = await functions
          .httpsCallable('createServicePaymentIntent')
          .call({
            'serviceId': widget.serviceId,
            'amount': (_service!.price * 100).round(),
            'serviceName': _service!.title,
          });

      final data = result.data as Map<String, dynamic>;

      Stripe.publishableKey = data['publishableKey'];

      if (kIsWeb) {
        // Web: Show WebPaymentSheet custom modal
        if (mounted) {
          // Temporarily set loading to false to show the sheet
          setState(() => _isLoading = false);

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => WebPaymentSheet(
              clientSecret: data['paymentIntent'],
              onSuccess: () async {
                _confettiController.play();
                setState(() => _isLoading = true);
                try {
                  await _createBooking(paymentMethod: 'stripe', isPaid: true);
                } catch (e) {
                  if (mounted) AppToast.error(context, message: 'Erro: $e');
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              onError: (error) {
                if (mounted) {
                  AppToast.error(context, message: 'Erro no pagamento: $error');
                }
              },
            ),
          );
        }
      } else {
        // Mobile: Native Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: 'AquaClean - ${_service!.title}',
            paymentIntentClientSecret: data['paymentIntent'],
            customerEphemeralKeySecret: data['ephemeralKey'],
            customerId: data['customer'],
            style: ThemeMode.light,
          ),
        );

        await Stripe.instance.presentPaymentSheet();
        _confettiController.play();
        await _createBooking(paymentMethod: 'stripe', isPaid: true);
      }
    } on StripeException catch (e) {
      if (mounted && e.error.code != FailureCode.Canceled) {
        AppToast.error(
          context,
          message: 'Pagamento falhou: ${e.error.localizedMessage}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBookingPayOnSite() async {
    setState(() => _isLoading = true);
    try {
      await _createBooking(paymentMethod: 'on_site', isPaid: false);
    } catch (e) {
      if (mounted) AppToast.error(context, message: 'Erro: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createBooking({
    required String paymentMethod,
    required bool isPaid,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final userProfile = await ref.read(currentUserProfileProvider.future);

    final timeParts = _selectedTime!.split(':');
    final scheduledTime = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final booking = ServiceBooking(
      id: '',
      userId: user.uid,
      serviceId: widget.serviceId,
      scheduledTime: scheduledTime,
      totalPrice: _service!.price,
      status: ServiceBookingStatus.scheduled,
      userName: userProfile?.displayName,
    );

    await ref.read(independentServiceRepositoryProvider).createBooking(booking);

    if (mounted) {
      AppToast.success(
        context,
        message: isPaid
            ? 'Agendamento confirmado!'
            : 'Reserva feita! Pague no local.',
      );

      // Wait for confetti if paid
      if (isPaid) {
        await Future.delayed(const Duration(seconds: 3));
      }

      if (mounted) {
        context.go('/my-services');
      }
    }
  }
}
