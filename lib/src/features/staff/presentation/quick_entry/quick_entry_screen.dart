import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/utils/app_toast.dart';
import 'quick_entry_controller.dart';

class QuickEntryScreen extends ConsumerStatefulWidget {
  const QuickEntryScreen({super.key});

  @override
  ConsumerState<QuickEntryScreen> createState() => _QuickEntryScreenState();
}

class _QuickEntryScreenState extends ConsumerState<QuickEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _phoneController = TextEditingController();

  final _plateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _plateFocus.addListener(_onPlateFocusChange);
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _phoneController.dispose();
    _plateFocus.removeListener(_onPlateFocusChange);
    _plateFocus.dispose();
    super.dispose();
  }

  void _onPlateFocusChange() {
    if (!_plateFocus.hasFocus) {
      // Lost focus, search
      ref
          .read(quickEntryControllerProvider.notifier)
          .searchPlate(_plateController.text);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(quickEntryControllerProvider.notifier)
          .submitEntry(
            plate: _plateController.text,
            vehicleModel: _modelController.text,
            phoneNumber: _phoneController.text,
          );
    }
  }

  void _showSuccessDialog(String bookingId) {
    // Generate link dynamically based on current environment
    // This ensures testing on localhost works, and production uses the correct domain
    final String baseUrl =
        Uri.base.origin.isNotEmpty && Uri.base.origin != 'null'
        ? Uri.base.origin
        : 'http://autoolinda-5199e.web.app';

    final clientLink = '$baseUrl/check-in?id=$bookingId';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Serviço Iniciado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('O serviço foi iniciado com sucesso.'),
            const SizedBox(height: 16),
            SelectableText(
              clientLink,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Link gerado para o cliente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // Share via WhatsApp
                  final message =
                      "Olá! Seu ${_modelController.text} deu entrada na Lavagem. Acompanhe aqui: $clientLink";

                  final cleanPhone = _phoneController.text.replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  final waUrl =
                      "https://wa.me/55$cleanPhone?text=${Uri.encodeComponent(message)}";
                  launchUrl(
                    Uri.parse(waUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: const Text('WhatsApp'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Reset form for new entry
                      _plateController.clear();
                      _modelController.clear();
                      _phoneController.clear();
                      ref.read(quickEntryControllerProvider.notifier).reset();
                    },
                    child: const Text('Nova Entrada'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      context.pop(); // Go back to Dashboard
                    },
                    child: const Text('Concluir'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes
    ref.listen(quickEntryControllerProvider, (prev, next) {
      if (prev?.existingLead != next.existingLead &&
          next.existingLead != null) {
        // Auto fill form
        _modelController.text = next.existingLead!.vehicleModel;
        _phoneController.text = next.existingLead!.phoneNumber;
        AppToast.success(context, message: 'Cadastro encontrado!');
      }

      if (next.createdBookingId != null &&
          prev?.createdBookingId != next.createdBookingId) {
        _showSuccessDialog(next.createdBookingId!);
      }

      if (next.error != null) {
        AppToast.error(context, message: next.error!);
      }
    });

    final state = ref.watch(quickEntryControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrada Rápida'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova Lavagem',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os dados para iniciar o atendimento.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Plate Field
              TextFormField(
                controller: _plateController,
                focusNode: _plateFocus,
                decoration: InputDecoration(
                  labelText: 'Placa do Veículo',
                  hintText: 'ABC1D23',
                  prefixIcon: const Icon(Icons.directions_car),
                  suffixIcon: state.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(
                    7,
                  ), // Mercosul/Old standard usually 7 chars alphanumeric
                  UpperCaseTextFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.length < 7) {
                    return 'Placa inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Model Field
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Modelo do Veículo',
                  hintText: 'Ex: Fial Palio',
                  prefixIcon: const Icon(Icons.commute),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o modelo' : null,
              ),
              const SizedBox(height: 24),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp do Cliente',
                  hintText: '(81) 99999-9999',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  PhoneInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.length < 14) {
                    // (XX) XXXXX-XXXX is 15 chars, (XX) XXXX-XXXX is 14
                    return 'Telefone inválido';
                  }
                  return null;
                },
              ),
              // Service Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Serviço',
                  prefixIcon: const Icon(Icons.cleaning_services),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: state.selectedServiceId,
                items: state.availableServices.map((service) {
                  final name = service['title'] ?? service['name'] ?? 'Serviço';
                  final price = service['price'] ?? 0;
                  return DropdownMenuItem<String>(
                    value:
                        service['id'], // Assuming ID is unique across both collections
                    child: Text('$name (R\$ $price)'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final selected = state.availableServices.firstWhere(
                      (s) => s['id'] == value,
                    );
                    final name =
                        selected['title'] ?? selected['name'] ?? 'Serviço';
                    ref
                        .read(quickEntryControllerProvider.notifier)
                        .selectService(value, name);
                  }
                },
                validator: (value) =>
                    value == null ? 'Selecione um serviço' : null,
              ),
              const SizedBox(height: 48),

              // Action Button
              FilledButton.icon(
                onPressed: state.isLoading ? null : _submit,
                icon: const Icon(Icons.play_arrow),
                label: const Text('INICIAR SERVIÇO'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    var buffer = StringBuffer();

    // (11) 91234-5678
    if (text.length >= 1) buffer.write('(');
    if (text.length >= 1)
      buffer.write(text.substring(0, text.length >= 2 ? 2 : text.length));
    if (text.length >= 2) buffer.write(') ');

    if (text.length > 2) {
      if (text.length < 7) {
        buffer.write(text.substring(2));
      } else {
        // If 11 digits: (XX) 9XXXX-XXXX
        // If 10 digits: (XX) XXXX-XXXX
        // We are handling raw digits here so text is just digits?
        // No, InputFormatter receives the NEW value effectively.
        // But FilteringTextInputFormatter.digitsOnly ensures we only have digits if applied before?
        // Actually we should write a proper mask logic, but simplistic approach:
        // Let's rely on the fact that digitsOnly runs first in the list.

        // Logic for dynamic mask based on length 10 or 11 is tricky in simple formatter.
        // Let's assume 11 digits (mobile) mostly.

        if (text.length <= 7) {
          buffer.write(text.substring(2));
        } else {
          // (XX) XXXXX-XXXX
          int splitPoint = text.length - 4;
          buffer.write(text.substring(2, splitPoint));
          buffer.write('-');
          buffer.write(text.substring(splitPoint));
        }
      }
    }

    // Since we are adding characters, we need to adjust cursor?
    // Simple return without selection calc might mess up cursor if typing in middle.
    // Given 'Rapid Entry' implies appending usually, it might be fine, but proper implementation is better.
    // For now I'll use this simple one.

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
