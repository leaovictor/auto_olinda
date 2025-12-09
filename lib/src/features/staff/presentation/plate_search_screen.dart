import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/plate_lookup_service.dart';

import '../../../shared/utils/app_toast.dart';

/// Screen for finding bookings by vehicle plate
/// Supports manual entry with autocomplete and QR code scanning
class PlateSearchScreen extends ConsumerStatefulWidget {
  const PlateSearchScreen({super.key});

  @override
  ConsumerState<PlateSearchScreen> createState() => _PlateSearchScreenState();
}

class _PlateSearchScreenState extends ConsumerState<PlateSearchScreen>
    with SingleTickerProviderStateMixin {
  final _plateController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  late TabController _tabController;

  // QR Scanner is not supported on web
  bool get _showQRTab => !kIsWeb;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _showQRTab ? 2 : 1, vsync: this);
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchByPlate(String plate) async {
    if (plate.trim().isEmpty) {
      AppToast.warning(context, message: 'Digite uma placa');
      return;
    }

    setState(() => _isSearching = true);

    try {
      final service = ref.read(plateLookupServiceProvider);
      final result = await service.findActiveBookingByPlate(plate);

      if (!mounted) return;

      if (result == null) {
        AppToast.warning(
          context,
          message: 'Nenhum agendamento ativo encontrado para esta placa',
        );
      } else {
        // Navigate to booking detail
        context.push('/staff/booking/${result.booking.id}');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao buscar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _handleQRDetected(String? code) {
    if (code == null) return;

    // Check if it's a booking ID or plate
    if (code.startsWith('booking:')) {
      // It's a booking ID
      final bookingId = code.replaceFirst('booking:', '');
      context.push('/staff/booking/$bookingId');
    } else {
      // Assume it's a plate or booking ID directly
      _plateController.text = code;
      _searchByPlate(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Veículo'),
        centerTitle: true,
        bottom: _showQRTab
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.keyboard), text: 'Digitar Placa'),
                  Tab(icon: Icon(Icons.qr_code_scanner), text: 'Escanear QR'),
                ],
              )
            : null,
      ),
      body: _showQRTab
          ? TabBarView(
              controller: _tabController,
              children: [
                // Manual Entry Tab
                _buildManualEntryTab(theme),
                // QR Scanner Tab
                _buildQRScannerTab(theme),
              ],
            )
          : _buildManualEntryTab(theme),
    );
  }

  Widget _buildManualEntryTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Plate Input Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Digite a placa do veículo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ex: ABC1D23 ou ABC-1234',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _plateController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABC1D23',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    suffixIcon: _plateController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _plateController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                    LengthLimitingTextInputFormatter(8),
                    UpperCaseTextFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _searchByPlate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Search Button
          FilledButton.icon(
            onPressed: _isSearching
                ? null
                : () => _searchByPlate(_plateController.text),
            icon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isSearching ? 'Buscando...' : 'Buscar Agendamento'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Spacer(),
          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dica: Use a aba "Escanear QR" para ler o QR code do comprovante do cliente.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRScannerTab(ThemeData theme) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _handleQRDetected(barcode.rawValue);
                break;
              }
            }
          },
        ),
        // Overlay with scan area indicator
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SizedBox(),
              ),
            ),
          ),
        ),
        // Clear the center for scanning
        Positioned.fill(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 280,
                height: 280,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        // Instructions at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 48,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Posicione o QR Code dentro da área',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Text input formatter to convert to uppercase
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
