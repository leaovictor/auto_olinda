import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';
import '../../auth/data/auth_repository.dart';

/// Screen shown after successful Stripe Checkout payment
/// Reads pending booking data from localStorage and creates the booking
class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  bool _isProcessing = true;
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    // Start processing, but it will wait for auth if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        _processBooking();
      } else {
        // Use a heuristic delay or just wait for the listener
        debugPrint(
          '🔵 PaymentSuccessScreen: User not logged in, waiting for auth...',
        );
      }
    });
  }

  void _listenToAuth() {
    ref.listenManual(authStateChangesProvider, (previous, next) {
      if (next.value != null && !_success && _error == null && _isProcessing) {
        debugPrint(
          '🔵 PaymentSuccessScreen: User authenticated via listener, retrying processing...',
        );
        _processBooking();
      }
    });
  }

  Future<void> _processBooking() async {
    debugPrint('🔵 PaymentSuccessScreen: Starting _processBooking');
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingBookingJson = prefs.getString('pendingBooking');

      debugPrint(
        '🔵 PaymentSuccessScreen: pendingBookingJson = $pendingBookingJson',
      );

      if (pendingBookingJson == null) {
        debugPrint('❌ PaymentSuccessScreen: No pending booking data found');
        setState(() {
          _isProcessing = false;
          _error = 'Dados do agendamento não encontrados. Tente novamente.';
        });
        return;
      }

      final pendingBooking =
          jsonDecode(pendingBookingJson) as Map<String, dynamic>;

      debugPrint(
        '🔵 PaymentSuccessScreen: Parsed pendingBooking = $pendingBooking',
      );

      // Verify timestamp is recent (within last 30 minutes)
      final timestamp = DateTime.parse(pendingBooking['timestamp'] as String);
      final minutesElapsed = DateTime.now().difference(timestamp).inMinutes;
      debugPrint('🔵 PaymentSuccessScreen: Minutes elapsed = $minutesElapsed');

      if (minutesElapsed > 30) {
        debugPrint('❌ PaymentSuccessScreen: Booking data expired');
        setState(() {
          _isProcessing = false;
          _error = 'Dados do agendamento expiraram. Tente novamente.';
        });
        await prefs.remove('pendingBooking');
        return;
      }

      // Validate required fields
      final vehicleId = pendingBooking['vehicleId'] as String?;
      debugPrint('🔵 PaymentSuccessScreen: vehicleId = $vehicleId');

      if (vehicleId == null || vehicleId.isEmpty) {
        debugPrint('❌ PaymentSuccessScreen: Vehicle not found');
        setState(() {
          _isProcessing = false;
          _error = 'Veículo não encontrado. Tente novamente.';
        });
        return;
      }

      final scheduledTime = DateTime.parse(
        pendingBooking['scheduledTime'] as String,
      );

      // Check if booking already exists (created by Webhook)
      debugPrint('🔵 PaymentSuccessScreen: Checking for existing booking...');
      final existingBooking = await ref
          .read(bookingRepositoryProvider)
          .findBooking(
            userId: pendingBooking['userId'] as String,
            vehicleId: vehicleId,
            scheduledTime: scheduledTime,
          );

      if (existingBooking != null) {
        debugPrint(
          '✅ PaymentSuccessScreen: Booking already exists (Webhook handled it)!',
        );
        await prefs.remove('pendingBooking');
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _success = true;
          });
        }
        await Future.delayed(const Duration(milliseconds: 1500));
        SystemNavigator.pop();
        return;
      }

      // Create the booking
      debugPrint('🔵 PaymentSuccessScreen: Creating booking...');
      final booking = Booking(
        id: '',
        userId: pendingBooking['userId'] as String,
        vehicleId: vehicleId,
        serviceIds: List<String>.from(pendingBooking['serviceIds'] as List),
        scheduledTime: DateTime.parse(
          pendingBooking['scheduledTime'] as String,
        ),
        status: BookingStatus.scheduled,
        totalPrice: (pendingBooking['totalPrice'] as num).toDouble(),
      );

      debugPrint(
        '🔵 PaymentSuccessScreen: Booking object created, calling repository...',
      );
      await ref.read(bookingRepositoryProvider).createBooking(booking);
      debugPrint('✅ PaymentSuccessScreen: Booking created successfully!');

      // Clear pending booking data
      await prefs.remove('pendingBooking');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _success = true;
        });
      }

      // Try to close the tab/window since it was opened as a popup
      // SystemNavigator.pop() works on some browsers if opened via script
      await Future.delayed(const Duration(milliseconds: 1500));
      SystemNavigator.pop();

      // If it didn't close, show message
    } catch (e, stackTrace) {
      debugPrint('❌ PaymentSuccessScreen: Error - $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Erro ao criar agendamento: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuth();
    final theme = Theme.of(context);

    // Common style for animations
    const duration = Duration(milliseconds: 600);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator().animate().fadeIn(
                  duration: duration,
                ),
                const SizedBox(height: 24),
                Text(
                      'Confirmando pagamento...',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: duration)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Aguarde enquanto finalizamos seu agendamento.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: duration),
              ] else if (_success) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut)
                    .fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'Tudo pronto!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  'Você pode fechar esta aba e voltar para o aplicativo.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => SystemNavigator.pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Fechar Aba'),
                ).animate().fadeIn(delay: 800.ms),
              ] else if (_error != null) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ).animate().shake(),
                const SizedBox(height: 24),
                Text(
                  'Erro no Pagamento',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.home),
                  label: const Text('Ir para o Início'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
