import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/booking_repository.dart';
import '../domain/booking.dart';

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
    _processBooking();
  }

  Future<void> _processBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingBookingJson = prefs.getString('pendingBooking');

      if (pendingBookingJson == null) {
        setState(() {
          _isProcessing = false;
          _error = 'Dados do agendamento não encontrados';
        });
        return;
      }

      final pendingBooking =
          jsonDecode(pendingBookingJson) as Map<String, dynamic>;

      // Verify timestamp is recent (within last 30 minutes)
      final timestamp = DateTime.parse(pendingBooking['timestamp'] as String);
      if (DateTime.now().difference(timestamp).inMinutes > 30) {
        setState(() {
          _isProcessing = false;
          _error = 'Dados do agendamento expiraram';
        });
        await prefs.remove('pendingBooking');
        return;
      }

      // Validate required fields
      final vehicleId = pendingBooking['vehicleId'] as String?;
      if (vehicleId == null || vehicleId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _error = 'Veículo não encontrado';
        });
        return;
      }

      // Create the booking
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

      await ref.read(bookingRepositoryProvider).createBooking(booking);

      // Clear pending booking data
      await prefs.remove('pendingBooking');

      setState(() {
        _isProcessing = false;
        _success = true;
      });

      // Navigate to dashboard after a delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = 'Erro ao criar agendamento: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Finalizando seu agendamento...',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ] else if (_success) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Pagamento Confirmado!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Seu agendamento foi realizado com sucesso.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Redirecionando...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else if (_error != null) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 80),
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
