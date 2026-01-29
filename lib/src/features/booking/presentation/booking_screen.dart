import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/system_settings_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import '../data/booking_repository.dart';
import '../domain/booking.dart';
import 'booking_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../payment/data/payment_service.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/utils/app_toast.dart';
import '../../../common_widgets/atoms/app_card.dart';
import '../../../common_widgets/atoms/primary_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../admin/data/calendar_repository.dart';
import '../../admin/domain/calendar_config.dart';
import '../../../common_widgets/atoms/secondary_button.dart';
import '../../../common_widgets/atoms/app_loader.dart';
import '../../../common_widgets/molecules/full_screen_loader.dart';
import '../../subscription/data/subscription_repository.dart';
import '../../subscription/domain/subscriber.dart';
import '../../subscription/presentation/widgets/web_payment_sheet.dart';
import '../../../common_widgets/molecules/app_refresh_indicator.dart';
import '../../../shared/widgets/async_loader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../ecommerce/data/product_repository.dart';
import '../../../shared/widgets/discount_badge.dart';

import '../../pricing/data/pricing_repository.dart';
import '../../pricing/domain/pricing_matrix.dart';
import '../domain/service_package.dart';
import '../../profile/domain/vehicle.dart';
import '../../../shared/extensions/vehicle_category_extension.dart';
import 'widgets/service_price_list.dart';

// --- PREMIUM THEME CONSTANTS ---
const _kPremiumColor = Color(0xFF1E88E5); // Blue 600
const _kPremiumGradient = LinearGradient(
  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);
    final supportPhone = ref.watch(supportPhoneNumberProvider);

    // Listen for booking errors
    ref.listen<BookingState>(bookingControllerProvider, (previous, next) {
      if (!next.isLoading &&
          next.error != null &&
          (previous?.error != next.error)) {
        AppToast.error(context, message: next.error!);
      }
    });

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: AppRefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserProfileProvider);
                await Future.delayed(const Duration(seconds: 1));
              },
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 500,
                  child: Center(
                    child: Text(
                      'Usuário não encontrado. Arraste para atualizar.',
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (user.status == 'suspended') {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: const Text('Conta Suspensa'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 64,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sua conta está suspensa.',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre em contato com o suporte para mais informações.',
                      textAlign: TextAlign.center,
                    ),
                    if (supportPhone != null) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final cleanNumber = supportPhone.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          final uri = Uri.parse(
                            'https://wa.me/$cleanNumber?text=Olá, minha conta está suspensa. Poderia me ajudar?',
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.support_agent),
                        label: const Text('Falar com Suporte'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        if (user.status == 'cancelled') {
          return Scaffold(
            appBar: AppBar(title: const Text('Conta Cancelada')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Sua conta foi cancelada.',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(
              'Novo Agendamento',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: _kPremiumGradient),
            ),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (state.currentStep > 0) {
                  controller.previousStep();
                } else {
                  context.pop();
                }
              },
            ),
          ),
          body: Column(
            children: [
              _buildProgressHeader(context, state.currentStep),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: IndexedStack(
                    key: ValueKey(state.currentStep),
                    index: state.currentStep,
                    children: [
                      // Step 0: Vehicle
                      _VehicleSelectionStep(),
                      // Step 1: Service (now dynamic based on vehicle)
                      _ServiceSelectionStep(),
                      // Step 2: Products
                      _ProductsSelectionStep(),
                      // Step 3: DateTime
                      _DateTimeSelectionStep(),
                      // Step 4: Review
                      const _ReviewStep(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: FullScreenLoader(message: 'Carregando...')),
      error: (err, stack) => Scaffold(body: Center(child: Text('Erro: $err'))),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    // Swapped Vehicle and Service
    final steps = ['Veículo', 'Serviço', 'Produtos', 'Horário', 'Revisão'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Expanded(
                  child: Container(
                    height: 2,
                    color: index ~/ 2 < currentStep
                        ? _kPremiumColor
                        : Colors.grey.shade200,
                  ),
                );
              }
              final stepIndex = index ~/ 2;
              final isActive = stepIndex <= currentStep;
              final isCompleted = stepIndex < currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? _kPremiumColor : Colors.white,
                  gradient: isActive ? _kPremiumGradient : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.transparent : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _kPremiumColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Optional: Show current step name label?
          // Text(steps[currentStep], style: ...)
        ],
      ),
    );
  }
}

class _ServiceSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);
    final selectedVehicle = state.selectedVehicle;

    // Safety check: if no vehicle selected, go back (shouldn't happen with correct flow)
    if (selectedVehicle == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Selecione um veículo primeiro.'),
            ElevatedButton(
              onPressed: () => controller.previousStep(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
    }

    // Check Subscription Status for THIS vehicle
    final allSubs = ref.watch(userSubscriptionsProvider).valueOrNull ?? [];
    final activeSub = allSubs.firstWhere(
      (s) => s.vehicleId == selectedVehicle.id && s.isActive,
      orElse: () => Subscriber(
        id: '',
        userId: '',
        planId: '',
        startDate: DateTime.fromMillisecondsSinceEpoch(0),
        status: 'none',
      ), // Dummy empty subscriber
    );

    final isSubscriber = activeSub.status != 'none';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: [
              Text(
                'Escolha o Serviço',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              if (isSubscriber)
                Text(
                  'Sua assinatura inclui lavagens ilimitadas para este veículo.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Selecione o tipo de lavagem para seu ${selectedVehicle.model}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        Expanded(
          child: isSubscriber
              ? _buildSubscriptionCard(context, ref, controller, theme)
              : _buildPayPerUseList(context, ref, controller, selectedVehicle),
        ),
        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Ensure service is selected before proceeding
                  if (state.selectedServices.isNotEmpty) {
                    controller.nextStep();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione um serviço para continuar.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPremiumColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    WidgetRef ref,
    BookingController controller,
    ThemeData theme,
  ) {
    // For subscribers, we fake a "Full Wash" service package
    final subService = ServicePackage(
      id: 'subscription_wash',
      title: 'Lavagem Completa',
      description: 'Inclusa na sua assinatura',
      price: 0.0,
      durationMinutes: 45,
      isPopular: true,
      category: 'wash',
    );

    // Auto-select if not selected
    final state = ref.watch(bookingControllerProvider);
    if (state.selectedServices.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.toggleService(subService);
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {
            if (!state.selectedServices.contains(subService)) {
              controller.toggleService(subService);
            }
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _kPremiumGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _kPremiumColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lavagem Premium',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ASSINANTE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child:
                      state.selectedServices.any((s) => s.id == subService.id)
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 28,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        ),
      ),
    );
  }

  Widget _buildPayPerUseList(
    BuildContext context,
    WidgetRef ref,
    BookingController controller,
    Vehicle vehicle,
  ) {
    final matrixAsync = ref.watch(pricingMatrixStreamProvider);
    final state = ref.watch(bookingControllerProvider);

    return matrixAsync.when(
      data: (matrix) {
        // Get prices for this vehicle category
        final prices = matrix.getPricesForCategory(vehicle.category);

        if (prices.isEmpty) {
          return const Center(child: Text('Preços não configurados.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ServicePriceList(
            prices: prices,
            selectedService: state.selectedServices.isNotEmpty
                ? state.selectedServices.first.id
                : null,
            onServiceSelected: (serviceKey) {
              final price = prices[serviceKey] ?? 0.0;

              // Create a temporary ServicePackage from the matrix data
              // In a real app we might want to fetch Service metadata (description, duration)
              // separately, but for now this fits the requirement.
              final servicePkg = ServicePackage(
                id: serviceKey,
                title: _formatServiceName(serviceKey),
                description: 'Lavagem avulsa',
                price: price,
                durationMinutes: 45, // Default/Estimate
                category: 'wash',
              );

              controller.toggleService(servicePkg);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro ao carregar preços: $e')),
    );
  }

  String _formatServiceName(String key) {
    return key
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _VehicleSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    final vehiclesAsync = ref.watch(userVehiclesProvider(user.uid));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Qual veículo vamos lavar?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        Expanded(
          child: vehiclesAsync.when(
            data: (vehicles) {
              if (vehicles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_car_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum veículo cadastrado.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SecondaryButton(
                        text: 'Adicionar Veículo',
                        onPressed: () => context.push('/add-vehicle'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final state = ref.watch(bookingControllerProvider);
                  final isSelected = state.selectedVehicle?.id == vehicle.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .selectVehicle(vehicle);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _kPremiumColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _kPremiumColor.withOpacity(0.15)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? _kPremiumGradient
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade200,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              vehicle.category.assetPath,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.brand} ${vehicle.model}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    vehicle.plate,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: _kPremiumColor),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
                },
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: const ShimmerLoading.rectangular(height: 80),
              ),
            ),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
      ],
    );
  }
}

/// Step for selecting additional products (wax, perfume, etc.)
class _ProductsSelectionStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final productsAsync = ref.watch(activeProductsProvider);
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Deseja adicionar algo?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              subscriptionAsync.when(
                data: (sub) {
                  final isPremium =
                      sub != null && sub.isActive && sub.status != 'canceled';
                  return Text(
                    isPremium
                        ? 'Produtos adicionais são cobrados separadamente'
                        : 'Adicione produtos ao seu agendamento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum produto disponível',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = state.selectedProducts.any(
                    (p) => p.id == product.id,
                  );

                  return GestureDetector(
                    onTap: () => controller.toggleProduct(product),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _kPremiumColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _kPremiumColor.withOpacity(0.15)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                image: product.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.imageUrl == null
                                  ? Icon(
                                      Icons.shopping_bag,
                                      color: isSelected
                                          ? _kPremiumColor
                                          : Colors.grey.shade400,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${product.price.toStringAsFixed(2)}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _kPremiumColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? _kPremiumColor
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? _kPremiumColor
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
                },
              );
            },
            loading: () => const Center(child: AppLoader()),
            error: (err, stack) => Center(child: Text('Erro: $err')),
          ),
        ),
        // Summary and action buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              if (state.selectedProducts.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produtos selecionados:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'R\$ ${state.productsTotalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => controller.nextStep(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text('Pular'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPremiumColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => controller.nextStep(),
                      child: Text(
                        state.selectedProducts.isEmpty
                            ? 'Continuar sem produtos'
                            : 'Continuar (${state.selectedProducts.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTimeSelectionStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DateTimeSelectionStep> createState() =>
      _DateTimeSelectionStepState();
}

class _DateTimeSelectionStepState
    extends ConsumerState<_DateTimeSelectionStep> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isCheckingAvailability = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
    final controller = ref.read(bookingControllerProvider.notifier);
    final theme = Theme.of(context);

    final bookingsAsync = ref.watch(bookingsForDateProvider(_selectedDay!));
    final weeklyScheduleAsync = ref.watch(weeklyScheduleProvider);
    final blockedDatesAsync = ref.watch(blockedDatesProvider);

    return weeklyScheduleAsync.when(
      data: (schedule) => blockedDatesAsync.when(
        data: (blockedDates) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Quando fica melhor para você?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                  CalendarFormat.twoWeeks: '2 Semanas',
                  CalendarFormat.week: 'Semana',
                },
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                enabledDayPredicate: (day) {
                  // 1. Check if past
                  if (day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  )) {
                    return false;
                  }

                  // 2. Check if blocked
                  final isBlocked = blockedDates.any(
                    (blocked) => isSameDay(blocked.date, day),
                  );
                  if (isBlocked) return false;

                  // 3. Check if open in weekly schedule
                  // day.weekday: 1=Mon, 7=Sun
                  final daySchedule = schedule.firstWhere(
                    (s) => s.dayOfWeek == day.weekday,
                    orElse: () => WeeklySchedule(
                      dayOfWeek: day.weekday,
                      isOpen: false,
                      startHour: 0,
                      endHour: 0,
                      capacityPerHour: 0,
                    ),
                  );
                  return daySchedule.isOpen;
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _calendarFormat = CalendarFormat.twoWeeks;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: _kPremiumColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: bookingsAsync.when(
                  data: (bookings) {
                    return _buildTimeSlots(
                      context,
                      _selectedDay!,
                      schedule,
                      state.selectedTimeSlot,
                      controller,
                      bookings,
                    );
                  },
                  loading: () => const Center(child: AppLoader()),
                  error: (err, stack) => Center(child: Text('Erro: $err')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: PrimaryButton(
                  text: 'Continuar',
                  isLoading: _isCheckingAvailability,
                  onPressed:
                      state.selectedTimeSlot != null && !_isCheckingAvailability
                      ? () async {
                          // Check for duplicate booking before proceeding
                          final vehicle = state.selectedVehicle;
                          final timeSlot = state.selectedTimeSlot;

                          if (vehicle == null || timeSlot == null) return;

                          setState(() => _isCheckingAvailability = true);

                          try {
                            final hasExisting = await ref
                                .read(bookingRepositoryProvider)
                                .hasExistingBookingForVehicle(
                                  vehicleId: vehicle.id,
                                  scheduledTime: timeSlot,
                                );

                            if (!mounted) return;

                            if (hasExisting) {
                              AppToast.error(
                                context,
                                message:
                                    'Este veículo já possui um agendamento neste horário. Escolha outro horário.',
                              );
                            } else {
                              controller.nextStep();
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isCheckingAvailability = false);
                            }
                          }
                        }
                      : null,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
  }

  Widget _buildTimeSlots(
    BuildContext context,
    DateTime date,
    List<WeeklySchedule> schedule,
    DateTime? selectedSlot,
    BookingController controller,
    List<Booking> existingBookings,
  ) {
    final theme = Theme.of(context);
    final daySchedule = schedule.firstWhere(
      (s) => s.dayOfWeek == date.weekday,
      orElse: () => WeeklySchedule(
        dayOfWeek: date.weekday,
        isOpen: false,
        startHour: 0,
        endHour: 0,
        capacityPerHour: 0,
        slots: [],
      ),
    );

    if (!daySchedule.isOpen) {
      return const Center(child: Text('Fechado neste dia'));
    }

    // Determine available slots
    // If we have granular slots configured, use them.
    // Otherwise fallback to legacy start/end hour logic.
    final List<({DateTime dateTime, int capacity, bool isBlocked})>
    availableSlots = [];

    if (daySchedule.slots.isNotEmpty) {
      for (final slotConfig in daySchedule.slots) {
        final timeParts = slotConfig.time.split(':');
        if (timeParts.length != 2) continue;

        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (hour == null || minute == null) continue;

        final slotDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        if (slotDateTime.isAfter(DateTime.now())) {
          availableSlots.add((
            dateTime: slotDateTime,
            capacity: slotConfig.capacity,
            isBlocked: slotConfig.isBlocked,
          ));
        }
      }
    } else {
      // Legacy Fallback
      for (
        int hour = daySchedule.startHour;
        hour < daySchedule.endHour;
        hour++
      ) {
        final slotDateTime = DateTime(date.year, date.month, date.day, hour);
        if (slotDateTime.isAfter(DateTime.now())) {
          availableSlots.add((
            dateTime: slotDateTime,
            capacity: daySchedule.capacityPerHour,
            isBlocked: false,
          ));
        }
      }
    }

    if (availableSlots.isEmpty) {
      return const Center(child: Text('Sem horários disponíveis'));
    }

    // Sort slots by time just in case
    availableSlots.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8, // Taller to fit text
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slotData = availableSlots[index];
        final slot = slotData.dateTime;
        final capacity = slotData.capacity;
        final isBlocked = slotData.isBlocked;

        // Lead Time Rule: 2 Hours
        final minTime = DateTime.now().add(const Duration(hours: 2));
        final isTooClose = slot.isBefore(minTime);

        final isSelected =
            selectedSlot != null &&
            isSameDay(selectedSlot, slot) &&
            selectedSlot.hour == slot.hour &&
            selectedSlot.minute == slot.minute;

        // Calculate bookings count for this specific slot time
        final bookedCount = existingBookings.where((b) {
          if (b.status == BookingStatus.cancelled) return false;
          return isSameDay(b.scheduledTime, slot) &&
              b.scheduledTime.hour == slot.hour &&
              b.scheduledTime.minute == slot.minute;
        }).length;

        final availableSpots = capacity - bookedCount;
        final isFull = availableSpots <= 0;

        // Blocked slots are also disabled
        final isDisabled = isFull || isTooClose || isBlocked;

        String statusText;
        Color statusColor;

        if (isBlocked) {
          statusText = 'Bloqueado';
          statusColor = theme.colorScheme.error; // Or a muted color
        } else if (isTooClose) {
          statusText = 'Encerrado';
          statusColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
        } else if (isFull) {
          statusText = 'Esgotado';
          statusColor = theme.colorScheme.error;
        } else {
          statusText = '$availableSpots vagas';
          statusColor = Colors.green;
        }

        if (isSelected) statusColor = Colors.white;

        return InkWell(
          onTap: isDisabled ? null : () => controller.selectTimeSlot(slot),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? _kPremiumColor
                  : isDisabled
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _kPremiumColor
                    : isDisabled
                    ? Colors.transparent
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(slot),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: isBlocked ? TextDecoration.lineThrough : null,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected ? 'Selecionado' : statusText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (30 * index).ms).scale();
      },
    );
  }
}

class _ReviewStep extends ConsumerStatefulWidget {
  const _ReviewStep();

  @override
  ConsumerState<_ReviewStep> createState() => _ReviewStepState();
}

class _ReviewStepState extends ConsumerState<_ReviewStep> {
  bool _isProcessingPayment = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingControllerProvider);
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            ShimmerLoading.rectangular(height: 300),
            SizedBox(height: 24),
            ShimmerLoading.rectangular(height: 60),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildContent(context, state, theme),
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
              Colors.yellow,
            ],
            numberOfParticles: 30,
            gravity: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingState state,
    ThemeData theme,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          100,
        ), // Extra bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tudo certo?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final selectedVehicle = state.selectedVehicle;
                      final vehicleSubAsync = selectedVehicle != null
                          ? ref.watch(
                              vehicleSubscriptionProvider(selectedVehicle.id),
                            )
                          : const AsyncValue<Subscriber?>.data(null);

                      final isPremium =
                          vehicleSubAsync.valueOrNull?.isActive ?? false;
                      // Calculate purely the service cost that is being discounted
                      final serviceOriginalPrice = state.serviceTotalPrice;

                      return Column(
                        children: [
                          // 1. SERVICES
                          ...state.selectedServices.map((service) {
                            if (isPremium) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.title,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'R\$ ${service.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const DiscountBadge(),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _buildSummaryRow(
                              context,
                              'Serviço',
                              service.title,
                            );
                          }),

                          Divider(
                            height: 32,
                            color: theme.colorScheme.outlineVariant,
                          ),

                          // 2. VEHICLE & DETAILS
                          _buildSummaryRow(
                            context,
                            'Veículo',
                            '${state.selectedVehicle?.brand} ${state.selectedVehicle?.model}',
                          ),
                          _buildSummaryRow(
                            context,
                            'Placa',
                            state.selectedVehicle?.plate ?? '',
                          ),

                          // 3. PRODUCTS
                          if (state.selectedProducts.isNotEmpty) ...[
                            Divider(
                              height: 32,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            ...state.selectedProducts.map(
                              (product) => _buildSummaryRow(
                                context,
                                'Produto',
                                '${product.name} (R\$ ${product.price.toStringAsFixed(2)})',
                              ),
                            ),
                          ],

                          Divider(
                            height: 32,
                            color: theme.colorScheme.outlineVariant,
                          ),

                          // 4. DATE & TIME
                          _buildSummaryRow(
                            context,
                            'Data',
                            state.selectedTimeSlot != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(state.selectedTimeSlot!)
                                : '',
                          ),
                          _buildSummaryRow(
                            context,
                            'Horário',
                            state.selectedTimeSlot != null
                                ? DateFormat(
                                    'HH:mm',
                                  ).format(state.selectedTimeSlot!)
                                : '',
                          ),

                          // 5. SAVINGS CARD (Premium Only)
                          if (isPremium && serviceOriginalPrice > 0) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.savings_outlined,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Você economizou ',
                                          ),
                                          TextSpan(
                                            text:
                                                'R\$ ${serviceOriginalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ' com seu plano nesta lavagem!',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: theme.textTheme.titleLarge),
                Builder(
                  builder: (context) {
                    final selectedVehicle = state.selectedVehicle;
                    final vehicleSubAsync = selectedVehicle != null
                        ? ref.watch(
                            vehicleSubscriptionProvider(selectedVehicle.id),
                          )
                        : const AsyncValue<Subscriber?>.data(null);

                    final isPremium =
                        vehicleSubAsync.valueOrNull?.isActive ?? false;

                    // If premium, the service is free. Total is just products.
                    final displayPrice = isPremium
                        ? state.productsTotalPrice
                        : state.totalPrice;

                    return Text(
                      'R\$ ${displayPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _kPremiumColor,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context, ref, state, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    BookingState state,
    ThemeData theme,
  ) {
    final selectedVehicle = state.selectedVehicle;
    final vehicleSubAsync = selectedVehicle != null
        ? ref.watch(vehicleSubscriptionProvider(selectedVehicle.id))
        : const AsyncValue<Subscriber?>.data(null);

    final controller = ref.read(bookingControllerProvider.notifier);

    return vehicleSubAsync.when(
      data: (sub) {
        final isPremium =
            sub != null && sub.isActive && sub.status != 'canceled';

        if (isPremium) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPremiumColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _isProcessingPayment
                ? null
                : () async {
                    await _confirmBooking(context, ref, controller, theme);
                  },
            child: _isProcessingPayment
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirmar Agendamento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          );
        } else {
          return PrimaryButton(
            text: _isProcessingPayment ? 'Processando...' : 'Pagar e Agendar',
            icon: _isProcessingPayment ? null : Icons.payment,
            isLoading: _isProcessingPayment,
            onPressed: _isProcessingPayment
                ? null
                : () async {
                    setState(() => _isProcessingPayment = true);

                    // Pre-payment validation: Lead Time
                    final minTime = DateTime.now().add(
                      const Duration(hours: 2),
                    );
                    if (state.selectedTimeSlot != null &&
                        state.selectedTimeSlot!.isBefore(minTime)) {
                      AppToast.error(
                        context,
                        message:
                            'Este horário não está mais disponível (antecedência mínima de 2h). Escolha outro.',
                      );
                      setState(() => _isProcessingPayment = false);
                      return;
                    }

                    try {
                      // 1. Initialize Payment
                      final paymentService = ref.read(paymentServiceProvider);

                      if (kIsWeb) {
                        // Web Flow: Use WebPaymentSheet for ALL web platforms
                        // This matches the subscription flow which works correctly
                        final data = await paymentService.createPaymentIntent(
                          state.totalPrice,
                        );

                        if (data['publishableKey'] != null) {
                          Stripe.publishableKey = data['publishableKey'];
                        }

                        if (!context.mounted) return;

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) => WebPaymentSheet(
                            clientSecret: data['paymentIntent'],
                            onSuccess: () async {
                              // Navigator.pop(sheetContext); // Handled by WebPaymentSheet
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );
                              if (context.mounted) {
                                _confirmBooking(
                                  context,
                                  ref,
                                  controller,
                                  theme,
                                );
                              }
                            },
                            onError: (error) {
                              Navigator.pop(sheetContext); // Close sheet
                              AppToast.error(
                                context,
                                message: 'Erro no pagamento: $error',
                              );
                            },
                          ),
                        );
                      } else {
                        // Mobile App Flow
                        final initSuccess = await paymentService
                            .initPaymentSheet(state.totalPrice);

                        if (!initSuccess) {
                          if (context.mounted) {
                            AppToast.error(
                              context,
                              message:
                                  'Erro ao iniciar pagamento. Tente novamente.',
                            );
                          }
                          return;
                        }

                        // 2. Present Payment Sheet
                        final paymentSuccess = await paymentService
                            .presentPaymentSheet();

                        if (!paymentSuccess) {
                          if (context.mounted) {
                            AppToast.warning(
                              context,
                              message: 'Pagamento cancelado ou falhou.',
                            );
                          }
                          return;
                        }

                        // 3. Create Booking (Payment Confirmed)
                        if (context.mounted) {
                          _confirmBooking(context, ref, controller, theme);
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppToast.error(
                          context,
                          message: 'Erro ao iniciar pagamento: $e',
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessingPayment = false);
                      }
                    }
                  },
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking(
    BuildContext context,
    WidgetRef ref,
    BookingController controller,
    ThemeData theme,
  ) async {
    // debugPrint(
    //   '🔵 BookingScreen: _confirmBooking called. Starting creation...',
    // );
    try {
      // Wrap the confirmation future with AsyncLoader
      // controller.confirmBooking() returns bool
      final success = await AsyncLoader.show(
        context,
        future: controller.confirmBooking(),
        message: 'Agendando...',
      );

      // debugPrint('🔵 BookingScreen: confirmBooking result: $success');

      if (!context.mounted) {
        // debugPrint('🔴 BookingScreen: Context detached after confirmBooking.');
        return;
      }

      if (success) {
        // debugPrint('🟢 BookingScreen: Booking created successfully!');
        _confettiController.play();
        AppToast.success(
          context,
          message: 'Agendamento realizado com sucesso!',
        );
        // Wait for confetti animation to complete (3 seconds duration)
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          context.go('/my-bookings');
        }
      } else {
        // Error handling is managed by the listener in build()
        // debugPrint('🔴 BookingScreen: confirmBooking returned false.');
        // Fallback: Show error from controller state if available
        final controllerState = ref.read(bookingControllerProvider);
        final errorMsg = controllerState.error;
        // debugPrint('🔴 BookingScreen: Controller error state = $errorMsg');
        if (context.mounted && errorMsg != null) {
          AppToast.error(context, message: errorMsg);
        } else if (context.mounted) {
          AppToast.error(
            context,
            message:
                'Não foi possível finalizar o agendamento. Tente novamente.',
          );
        }
      }
    } catch (e) {
      // debugPrint('🔴 BookingScreen: Error in _confirmBooking: $e');
      // debugPrint('Stack trace: $stack');
      if (context.mounted) {
        AppToast.error(
          context,
          message: 'Erro inesperado ao criar agendamento.',
        );
      }
    }
  }
}

class PriceDisplay extends ConsumerWidget {
  final double price;
  final bool isLarge;

  const PriceDisplay({super.key, required this.price, this.isLarge = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(userSubscriptionProvider);
    final bookingState = ref.watch(bookingControllerProvider);

    return subscriptionAsync.when(
      data: (sub) {
        final isPremium =
            sub != null && sub.isActive && sub.status != 'canceled';

        if (isPremium) {
          final productsTotal = bookingState.productsTotalPrice;

          if (productsTotal > 0) {
            // Premium with products: show products price only
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$ ${productsTotal.toStringAsFixed(2)}',
                  style:
                      (isLarge
                              ? theme.textTheme.headlineMedium
                              : theme.textTheme.headlineSmall)
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                ),
                Text(
                  'Serviço gratuito + Produtos',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }

          // Premium without products: fully free
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ 0,00',
                style:
                    (isLarge
                            ? theme.textTheme.headlineMedium
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
              ),
              Text(
                'Gratuito (Premium)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        }

        // Non-premium: full price
        return Text(
          'R\$ ${price.toStringAsFixed(2)}',
          style:
              (isLarge
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.headlineSmall)
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
        );
      },
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Text('R\$ ${price.toStringAsFixed(2)}'),
    );
  }
}
