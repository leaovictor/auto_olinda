import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Domain & Data
import '../../../booking/data/booking_repository.dart';
import '../../../booking/domain/booking.dart';
import '../../../booking/domain/service_package.dart';
import '../../../profile/domain/vehicle.dart';
import '../../../services/data/independent_service_repository.dart';
import '../../../services/domain/independent_service.dart';
import '../../../services/domain/service_booking.dart';
// Shared & Theme
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

enum BookingType { carWash, aesthetic }

/// Quick Booking Dialog for walk-in customers
/// Supports both Car Wash (BookingRepository) and Aesthetic (IndependentServiceRepository)
class QuickBookingDialog extends ConsumerStatefulWidget {
  const QuickBookingDialog({super.key});

  @override
  ConsumerState<QuickBookingDialog> createState() => _QuickBookingDialogState();
}

class _QuickBookingDialogState extends ConsumerState<QuickBookingDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  late TabController _tabController;
  BookingType _selectedType = BookingType.carWash;

  // Car Wash State
  List<ServicePackage> _availableWashServices = [];
  final List<String> _selectedWashServiceIds = [];

  // Aesthetic State
  List<IndependentService> _availableAestheticServices = [];
  String? _selectedAestheticServiceId;

  bool _isLoading = false;
  bool _isLoadingServices = true;
  double _totalPrice = 0.0;

  // Date & Time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedType = BookingType.values[_tabController.index];
          _updateTotalPrice();
        });
      }
    });

    // Default time: next full hour
    final now = DateTime.now();
    _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);

    // Initial Load
    _loadServices();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      // Fetch Wash Services
      final washServices = await ref
          .read(bookingRepositoryProvider)
          .getServicesStream()
          .first;

      // Fetch Aesthetic Services (Independent)
      final aestheticServices = await ref
          .read(independentServiceRepositoryProvider)
          .getServicesStream()
          .first;

      if (mounted) {
        setState(() {
          _availableWashServices = washServices;
          _availableAestheticServices = aestheticServices;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingServices = false);
        // Silent error or toast if critical
      }
    }
  }

  void _updateTotalPrice() {
    double total = 0.0;

    if (_selectedType == BookingType.carWash) {
      for (final id in _selectedWashServiceIds) {
        final service = _availableWashServices.firstWhere(
          (s) => s.id == id,
          orElse: () => const ServicePackage(
            id: '',
            title: '',
            description: '',
            price: 0,
            durationMinutes: 0,
          ),
        );
        total += service.price;
      }
    } else {
      if (_selectedAestheticServiceId != null) {
        final service = _availableAestheticServices.firstWhere(
          (s) => s.id == _selectedAestheticServiceId,
          orElse: () => const IndependentService(
            id: '',
            title: '',
            description: '',
            price: 0,
            durationMinutes: 0,
            isActive: false,
            iconName: 'build',
          ),
        );
        total += service.price;
      }
    }
    setState(() => _totalPrice = total);
  }

  Future<void> _handleCreateBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedType == BookingType.carWash &&
        _selectedWashServiceIds.isEmpty) {
      AppToast.warning(context, message: 'Selecione pelo menos um serviço');
      return;
    }

    if (_selectedType == BookingType.aesthetic &&
        _selectedAestheticServiceId == null) {
      AppToast.warning(context, message: 'Selecione um serviço');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (_selectedType == BookingType.carWash) {
        await _createCarWashBooking(scheduledDateTime);
      } else {
        await _createAestheticBooking(scheduledDateTime);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        AppToast.success(context, message: 'Agendamento criado com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao criar: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createCarWashBooking(DateTime scheduledDateTime) async {
    // 1. Create temporary vehicle logic
    String vehicleId;
    try {
      final vehicle = Vehicle(
        id: '',
        brand: 'Walk-In',
        model: _modelController.text.isNotEmpty
            ? _modelController.text
            : 'Veículo Rápido',
        plate: _plateController.text.toUpperCase(),
        type: 'sedan',
        color: 'Other',
      );
      final docRef = await ref
          .read(bookingRepositoryProvider)
          .createVehicle(vehicle, 'walk-in');
      vehicleId = docRef.id;
    } catch (e) {
      print('Error creating vehicle: $e');
      throw Exception('Falha ao registrar veículo: $e');
    }

    // 2. Create Booking
    // Fixed: Removed 'createdAt' and 'updatedAt' as they are not in the Booking constructor
    final booking = Booking(
      id: '',
      userId: 'walk-in',
      vehicleId: vehicleId,
      serviceIds: _selectedWashServiceIds,
      scheduledTime: scheduledDateTime,
      status: BookingStatus.confirmed,
      totalPrice: _totalPrice,
      staffNotes:
          'Cliente: ${_customerNameController.text} (${_customerPhoneController.text})\n'
          'Placa: ${_plateController.text}\n'
          'Obs: ${_notesController.text}',
    );

    // Call Repository -> Cloud Function
    await ref.read(bookingRepositoryProvider).createBooking(booking);
  }

  Future<void> _createAestheticBooking(DateTime scheduledDateTime) async {
    final booking = ServiceBooking(
      id: '',
      userId: 'walk-in',
      serviceId: _selectedAestheticServiceId!,
      scheduledTime: scheduledDateTime,
      totalPrice: _totalPrice,
      status: ServiceBookingStatus.scheduled,
      paymentStatus: PaymentStatus.pending,
      vehiclePlate: _plateController.text.toUpperCase(),
      vehicleModel: _modelController.text,
      userName: _customerNameController.text,
      userPhone: _customerPhoneController.text,
      notes: _notesController.text,
      createdAt: DateTime.now(),
      // updatedAt is nullable, okay to omit or pass null
    );

    await ref.read(independentServiceRepositoryProvider).createBooking(booking);
  }

  @override
  Widget build(BuildContext context) {
    // Local theme helpers since they are not static in AdminTheme
    final primaryColor = AdminTheme.gradientPrimary[0];
    final secondaryColor = AdminTheme.gradientInfo[0];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 550,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: AdminTheme.bgCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AdminTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(primaryColor),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AdminTheme.bgCardLight,
                    border: Border(
                      bottom: BorderSide(color: AdminTheme.borderLight),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: primaryColor,
                    indicatorWeight: 3,
                    labelColor: primaryColor,
                    unselectedLabelColor: AdminTheme.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(
                        text: 'Lavagem & Estética',
                        icon: Icon(Icons.local_car_wash),
                      ),
                      Tab(
                        text: 'Serviços Independentes',
                        icon: Icon(Icons.handyman),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Flexible(
                  child: _isLoadingServices
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer Info
                                _buildSectionTitle('Cliente & Veículo'),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _buildTextField(
                                        controller: _customerNameController,
                                        label: 'Nome',
                                        icon: Icons.person_outline,
                                        primaryColor: primaryColor,
                                        required: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: _customerPhoneController,
                                        label: 'Tel (Opcional)',
                                        icon: Icons.phone_outlined,
                                        primaryColor: primaryColor,
                                        keyboardType: TextInputType.phone,
                                        required: false,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _plateController,
                                        label: 'Placa',
                                        icon:
                                            Icons.confirmation_number_outlined,
                                        primaryColor: primaryColor,
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                          LengthLimitingTextInputFormatter(7),
                                        ],
                                        required: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: _buildTextField(
                                        controller: _modelController,
                                        label: 'Modelo',
                                        icon: Icons.directions_car_outlined,
                                        primaryColor: primaryColor,
                                        required: true,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Date & Time
                                _buildSectionTitle('Data & Hora'),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDatePicker(primaryColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTimePicker(secondaryColor),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Services
                                _buildSectionTitle('Serviços'),
                                const SizedBox(height: 12),
                                if (_selectedType == BookingType.carWash)
                                  _buildCarWashServices(primaryColor)
                                else
                                  _buildAestheticServices(secondaryColor),

                                const SizedBox(height: 24),

                                // Notes
                                _buildTextField(
                                  controller: _notesController,
                                  label: 'Observações (Interno)',
                                  icon: Icons.note_alt_outlined,
                                  primaryColor: primaryColor,
                                  required: false,
                                  maxLines: 2,
                                ),

                                const SizedBox(height: 24),

                                // Total
                                _buildTotalSection(),
                              ],
                            ),
                          ),
                        ),
                ),

                // Footer Actions
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AdminTheme.gradientSuccess[0].withOpacity(0.15),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.gradientSuccess[0],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AdminTheme.gradientSuccess[0].withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_task, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Novo Agendamento', style: AdminTheme.headingSmall),
              Text(
                'Entrada Rápida / Walk-in',
                style: AdminTheme.labelSmall.copyWith(
                  color: AdminTheme.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: AdminTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(Color color) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: color,
                  onPrimary: Colors.white,
                  surface: AdminTheme.bgCard,
                  onSurface: AdminTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: AdminTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(Color color) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: color,
                  onPrimary: Colors.white,
                  surface: AdminTheme.bgCard,
                  onSurface: AdminTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) setState(() => _selectedTime = time);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AdminTheme.bgCardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled, size: 20, color: color),
            const SizedBox(width: 12),
            Text(_selectedTime.format(context), style: AdminTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCarWashServices(Color activeColor) {
    if (_availableWashServices.isEmpty) {
      return Text(
        'Nenhum serviço de lavagem encontrado.',
        style: AdminTheme.labelSmall,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableWashServices.map((service) {
        final isSelected = _selectedWashServiceIds.contains(service.id);
        return FilterChip(
          label: Text(service.title),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedWashServiceIds.add(service.id);
              } else {
                _selectedWashServiceIds.remove(service.id);
              }
              _updateTotalPrice();
            });
          },
          backgroundColor: AdminTheme.bgCardLight,
          selectedColor: activeColor.withOpacity(0.2),
          checkmarkColor: activeColor,
          labelStyle: TextStyle(
            color: isSelected ? activeColor : AdminTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? activeColor : AdminTheme.borderLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAestheticServices(Color activeColor) {
    if (_availableAestheticServices.isEmpty) {
      return Text(
        'Nenhum serviço independente encontrado.',
        style: AdminTheme.labelSmall,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAestheticServiceId,
          hint: Text(
            'Selecione um serviço...',
            style: TextStyle(color: AdminTheme.textMuted),
          ),
          isExpanded: true,
          dropdownColor: AdminTheme.bgCard,
          items: _availableAestheticServices.map((service) {
            return DropdownMenuItem(
              value: service.id,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'R\$ ${service.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedAestheticServiceId = val;
              _updateTotalPrice();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AdminTheme.labelSmall.copyWith(
        color: AdminTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AdminTheme.textSecondary),
        prefixIcon: Icon(icon, color: AdminTheme.textMuted, size: 20),
        filled: true,
        fillColor: AdminTheme.bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AdminTheme.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AdminTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      validator: required
          ? (v) => v?.isEmpty == true ? 'Obrigatório' : null
          : null,
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.bgCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Estimado', style: AdminTheme.bodyMedium),
          Text(
            NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            ).format(_totalPrice),
            style: AdminTheme.headingMedium.copyWith(
              color: AdminTheme.gradientSuccess[0],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AdminTheme.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AdminTheme.borderMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AdminTheme.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: AdminTheme.gradientSuccess),
                boxShadow: [
                  BoxShadow(
                    color: AdminTheme.gradientSuccess[0].withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirmar Agendamento',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
