import 'package:aquaclean_mobile/src/features/appointments/domain/service_package.dart';
import 'package:aquaclean_mobile/src/features/appointments/presentation/booking_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock data
final mockService1 = ServicePackage(
  id: 'service_1',
  title: 'Lavagem Simples',
  description: 'Lavagem externa',
  price: 50.0,
  durationMinutes: 60,
);

final mockService2 = ServicePackage(
  id: 'service_2',
  title: 'Lavagem Completa',
  description: 'Lavagem interna e externa',
  price: 100.0,
  durationMinutes: 120,
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('toggleService should replace existing selection with new service', () {
    final controller = container.read(bookingControllerProvider.notifier);

    // Initial state: empty
    expect(container.read(bookingControllerProvider).selectedServices, isEmpty);

    // Select Service 1
    controller.toggleService(mockService1);
    expect(container.read(bookingControllerProvider).selectedServices, [
      mockService1,
    ]);

    // Select Service 2 (should replace Service 1)
    controller.toggleService(mockService2);
    expect(container.read(bookingControllerProvider).selectedServices, [
      mockService2,
    ]);

    // Select Service 2 again (should remove it)
    controller.toggleService(mockService2);
    expect(container.read(bookingControllerProvider).selectedServices, isEmpty);
  });
}
