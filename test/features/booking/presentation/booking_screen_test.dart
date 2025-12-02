import 'package:aquaclean_mobile/src/features/admin/data/calendar_repository.dart';
import 'package:aquaclean_mobile/src/features/admin/domain/calendar_config.dart';
import 'package:aquaclean_mobile/src/features/auth/data/auth_repository.dart';
import 'package:aquaclean_mobile/src/features/auth/domain/app_user.dart';
import 'package:aquaclean_mobile/src/features/booking/data/booking_repository.dart';
import 'package:aquaclean_mobile/src/features/booking/domain/service_package.dart';
import 'package:aquaclean_mobile/src/features/booking/presentation/booking_screen.dart';
import 'package:aquaclean_mobile/src/features/profile/domain/vehicle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

// Mock data
final mockAppUser = AppUser(
  uid: 'test_uid',
  email: 'test@example.com',
  displayName: 'Test User',
  photoUrl: null,
  fcmToken: null,
  role: 'client',
);

final mockVehicle = Vehicle(
  id: 'vehicle_1',
  brand: 'Toyota',
  model: 'Corolla',
  plate: 'ABC-1234',
  type: 'sedan',
);

final mockService = ServicePackage(
  id: 'service_1',
  title: 'Lavagem Simples',
  description: 'Lavagem externa',
  price: 50.0,
  durationMinutes: 60,
);

class MockUser implements User {
  @override
  final String uid;

  MockUser({required this.uid});

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  @override
  User? get currentUser => MockUser(uid: 'test_uid');

  @override
  Stream<User?> authStateChanges() => Stream.value(MockUser(uid: 'test_uid'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('BookingScreen shows available dates and slots correctly', (
    tester,
  ) async {
    // Set screen size to avoid overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Setup mock schedule: Mon-Fri 08:00-18:00
    final schedule = List.generate(
      7,
      (index) => WeeklySchedule(
        dayOfWeek: index + 1,
        isOpen: index < 5, // Mon-Fri open
        startHour: 8,
        endHour: 18,
        capacityPerHour: 2,
      ),
    );

    // Setup blocked date: Next Monday
    final now = DateTime.now();
    // Find next Monday
    var nextMonday = now.add(const Duration(days: 1));
    while (nextMonday.weekday != DateTime.monday) {
      nextMonday = nextMonday.add(const Duration(days: 1));
    }
    final blockedDate = BlockedDate(date: nextMonday, reason: 'Holiday');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => MockAuthRepository()),
          userVehiclesProvider(
            mockAppUser.uid,
          ).overrideWith((ref) => Stream.value([mockVehicle])),
          servicesProvider.overrideWith((ref) => Stream.value([mockService])),
          weeklyScheduleProvider.overrideWith((ref) => Future.value(schedule)),
          blockedDatesProvider.overrideWith(
            (ref) => Future.value([blockedDate]),
          ),
        ],
        child: MaterialApp(home: const BookingScreen()),
      ),
    );

    // Wait for initial load
    await tester.pumpAndSettle();

    // 1. Select Service
    expect(find.text('Lavagem Simples'), findsOneWidget);
    await tester.tap(find.text('Lavagem Simples'));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 2. Select Vehicle
    expect(find.text('Toyota Corolla'), findsOneWidget);
    await tester.tap(find.text('Toyota Corolla')); // Select vehicle
    await tester.pumpAndSettle(); // Should auto-advance

    // 3. Date Selection
    expect(find.text('Quando fica melhor para você?'), findsOneWidget);
    expect(find.byType(TableCalendar), findsOneWidget);

    // Verify blocked date (Next Monday) is not selectable/enabled
    // Find a valid day (e.g., next Tuesday, assuming it's not blocked)
    var nextTuesday = nextMonday.add(const Duration(days: 1));

    // Tap on next Tuesday
    await tester.tap(find.text('${nextTuesday.day}'));
    await tester.pumpAndSettle();

    // Verify slots are shown
    // Schedule is 8-18. So 08:00, 09:00 ... 17:00.
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('17:00'), findsOneWidget);
    expect(find.text('18:00'), findsNothing);

    // Select a slot
    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();

    // Verify "Continuar" is enabled
    final continueBtn = find.widgetWithText(ElevatedButton, 'Continuar');
    expect(tester.widget<ElevatedButton>(continueBtn).enabled, isTrue);

    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // 4. Review Step
    expect(find.text('Tudo certo?'), findsOneWidget);
    expect(find.text('Lavagem Simples'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });
}
