import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/booking_repository.dart';
import '../../domain/booking.dart';

final bookingServiceTitleProvider = FutureProvider.family<String, Booking>((
  ref,
  booking,
) async {
  if (booking.serviceIds.isEmpty) return 'Lavagem';

  final serviceId = booking.serviceIds.first;

  // 1. Check for Subscription ID
  if (serviceId == 'subscription_wash') return 'Lavagem Premium';
  if (serviceId == 'lavagem_simples') return 'Lavagem Simples';
  if (serviceId == 'lavagem_completa') return 'Lavagem Completa';
  if (serviceId == 'lavagem_detalhada') return 'Lavagem Detalhada';
  if (serviceId == 'polimento') return 'Polimento';
  if (serviceId == 'higienizacao') return 'Higienização';

  // 2. Fetch from repository if not a known static ID
  final services = await ref.read(servicesProvider.future);
  final service = services.where((s) => s.id == serviceId).firstOrNull;

  return service?.title ?? 'Lavagem (ID: $serviceId)';
});
