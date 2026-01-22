import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/profile/domain/vehicle.dart';
import '../../data/booking_repository.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../common_widgets/atoms/app_card.dart';
import '../../../../common_widgets/atoms/app_text_field.dart';
import '../../../../common_widgets/atoms/primary_button.dart';
import '../../../../shared/utils/app_toast.dart';

part 'add_vehicle_screen.g.dart';

@riverpod
class AddVehicleController extends _$AddVehicleController {
  @override
  FutureOr<void> build() async {
    return null;

    // No initial state
  }

  Future<void> addVehicle({
    required String brand,
    required String model,
    required String plate,
    required String color,
    required String type,
  }) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final vehicle = Vehicle(
        id: '', // Will be set by Firestore
        brand: brand,
        model: model,
        plate: plate,
        color: color,
        type: type,
      );

      await ref
          .read(bookingRepositoryProvider)
          .createVehicle(vehicle, user.uid);
    });
  }
}

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  String _selectedType = 'sedan';

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(addVehicleControllerProvider.notifier)
          .addVehicle(
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            plate: _plateController.text.trim(),
            color: _colorController.text.trim(),
            type: _selectedType,
          );

      if (mounted && !ref.read(addVehicleControllerProvider).hasError) {
        AppToast.success(context, message: 'Veículo adicionado com sucesso!');
        // Redirect to plans after adding vehicle (subscription-only model)
        context.go('/plans');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addVehicleControllerProvider);
    final theme = Theme.of(context);

    ref.listen<AsyncValue>(addVehicleControllerProvider, (_, state) {
      if (state.hasError) {
        AppToast.error(context, message: 'Erro: ${state.error}');
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Adicionar Veículo',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: AppCard(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Detalhes do Veículo',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _brandController,
                  label: 'Marca',
                  hint: 'Ex: Toyota, Honda',
                  prefixIcon: const Icon(Icons.branding_watermark_outlined),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _modelController,
                  label: 'Modelo',
                  hint: 'Ex: Corolla, Civic',
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _plateController,
                  label: 'Placa',
                  hint: 'Ex: ABC1234',
                  prefixIcon: const Icon(Icons.numbers),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                      );
                    }),
                  ],
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _colorController,
                  label: 'Cor',
                  hint: 'Ex: Preto, Branco',
                  prefixIcon: const Icon(Icons.palette_outlined),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'sedan', child: Text('Sedan')),
                    DropdownMenuItem(value: 'suv', child: Text('SUV')),
                    DropdownMenuItem(value: 'hatch', child: Text('Hatch')),
                    DropdownMenuItem(value: 'pickup', child: Text('Picape')),
                    DropdownMenuItem(value: 'moto', child: Text('Moto')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Salvar Veículo',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
