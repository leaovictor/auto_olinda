import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/booking/domain/booking.dart';
import '../../../features/booking/domain/service_package.dart';
import '../../../features/profile/domain/vehicle.dart';
import '../../../features/ecommerce/domain/product.dart';
import '../data/booking_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../subscription/data/subscription_repository.dart';

class BookingState {
  final int currentStep;
  final List<ServicePackage> selectedServices;
  final List<Product> selectedProducts; // Additional products
  final Vehicle? selectedVehicle;
  final DateTime? selectedDate;
  final DateTime? selectedTimeSlot;
  final bool isLoading;
  final String? error;

  BookingState({
    this.currentStep = 0,
    this.selectedServices = const [],
    this.selectedProducts = const [],
    this.selectedVehicle,
    this.selectedDate,
    this.selectedTimeSlot,
    this.isLoading = false,
    this.error,
  });

  /// Total price for services only
  double get serviceTotalPrice =>
      selectedServices.fold(0, (sum, service) => sum + service.price);

  /// Total price for products only (always paid, even by subscribers)
  double get productsTotalPrice =>
      selectedProducts.fold(0, (sum, product) => sum + product.price);

  /// Combined total price (services + products)
  double get totalPrice => serviceTotalPrice + productsTotalPrice;

  BookingState copyWith({
    int? currentStep,
    List<ServicePackage>? selectedServices,
    List<Product>? selectedProducts,
    Vehicle? selectedVehicle,
    DateTime? selectedDate,
    DateTime? selectedTimeSlot,
    bool? isLoading,
    Object? error = const _Undefined(), // Wrapped optional to distinguish null
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      isLoading: isLoading ?? this.isLoading,
      error: error is _Undefined ? this.error : error as String?,
    );
  }
}

// Helper class for wrapped optional pattern
class _Undefined {
  const _Undefined();
}

class BookingController extends AutoDisposeNotifier<BookingState> {
  @override
  BookingState build() {
    return BookingState();
  }

  void toggleService(ServicePackage service) {
    // If the clicked service is already selected, deselect it (empty list)
    if (state.selectedServices.contains(service)) {
      state = state.copyWith(selectedServices: []);
    } else {
      // If a new service is clicked, it becomes the ONLY selected service
      state = state.copyWith(selectedServices: [service]);
    }
  }

  /// Toggle product selection (multiple products can be selected)
  void toggleProduct(Product product) {
    final currentProducts = List<Product>.from(state.selectedProducts);
    if (currentProducts.any((p) => p.id == product.id)) {
      currentProducts.removeWhere((p) => p.id == product.id);
    } else {
      currentProducts.add(product);
    }
    state = state.copyWith(selectedProducts: currentProducts);
  }

  void selectVehicle(Vehicle vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
    nextStep();
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTimeSlot(DateTime time) {
    state = state.copyWith(selectedTimeSlot: time);
  }

  void nextStep() {
    // 5 steps: 0=Service, 1=Vehicle, 2=Products, 3=DateTime, 4=Review
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<bool> confirmBooking() async {
    // print('🔵 confirmBooking: Starting...');
    final user = ref.read(authRepositoryProvider).currentUser;
    // print('🔵 confirmBooking: User = ${user?.uid}');

    if (user == null) {
      // print('❌ confirmBooking: No user found');
      state = state.copyWith(error: 'Usuário não autenticado.');
      return false;
    }

    if (state.selectedServices.isEmpty) {
      // print('❌ confirmBooking: No services selected');
      state = state.copyWith(error: 'Selecione pelo menos um serviço.');
      return false;
    }

    if (state.selectedVehicle == null) {
      // print('❌ confirmBooking: No vehicle selected');
      state = state.copyWith(error: 'Selecione um veículo.');
      return false;
    }

    if (state.selectedTimeSlot == null) {
      // print('❌ confirmBooking: No time slot selected');
      state = state.copyWith(error: 'Selecione um horário.');
      return false;
    }

    // print('🔵 confirmBooking: Setting loading state...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check for Premium Subscription — use vehicleSubscriptionProvider
      // (same provider as the UI, keyed by vehicleId + plate) so the isPremium
      // result is always consistent with what the user sees on screen.
      final vehicle = state.selectedVehicle!;
      final vehicleSub = ref.read(
        vehicleSubscriptionProvider((
          vehicleId: vehicle.id,
          plate: vehicle.plate,
        )),
      );

      final isPremium =
          vehicleSub.valueOrNull?.isActive == true &&
          vehicleSub.valueOrNull?.status != 'canceled';

      // print('🔵 confirmBooking: isPremium = $isPremium');

      // For premium users: service is free, but products are always paid
      // For non-premium: everything is paid
      final servicePrice = isPremium ? 0.0 : state.serviceTotalPrice;
      final productsPrice = state.productsTotalPrice; // Always paid
      final finalPrice = servicePrice + productsPrice;

      // print(
      //   '🔵 confirmBooking: finalPrice = $finalPrice (services: $servicePrice, products: $productsPrice)',
      // );

      final booking = Booking(
        id: '', // Will be generated by repository
        userId: user.uid,
        vehicleId: state.selectedVehicle!.id,
        serviceIds: state.selectedServices.map((s) => s.id).toList(),
        productIds: state.selectedProducts.map((p) => p.id).toList(),
        scheduledTime: state.selectedTimeSlot!,
        status: BookingStatus.scheduled,
        totalPrice: finalPrice,
        // ✅ FIX: Define paymentStatus baseado se o usuário é premium
        // Isso permite que os agendamentos sejam contados no card de assinatura
        paymentStatus: isPremium
            ? BookingPaymentStatus.subscription
            : BookingPaymentStatus.pending,
      );

      // print('🔵 confirmBooking: Created booking object');
      // print('   - userId: ${booking.userId}');
      // print('   - vehicleId: ${booking.vehicleId}');
      // print('   - scheduledTime: ${booking.scheduledTime}');
      // print(
      //   '   - serviceIds: ${booking.serviceIds} (Count: ${booking.serviceIds.length})',
      // );
      // print(
      //   '   - formattedTime (UTC): ${booking.scheduledTime.toUtc().toIso8601String()}',
      // );
      // print('   - totalPrice: ${booking.totalPrice} (Premium: $isPremium)');

      // print('🔵 confirmBooking: Calling repository.createBooking...');
      await ref.read(bookingRepositoryProvider).createBooking(booking);
      // print('✅ confirmBooking: SUCCESS! Booking ID = $bookingId');

      // Success - clear error
      state = state.copyWith(error: null);
      return true;
    } catch (e) {
      // 1. Clean extraction of error details
      String rawMessage = e.toString();
      String? code;
      String? details;

      // Try to treat as FirebaseFunctionsException (via dynamic to avoid import if not present)
      try {
        final dynamic customE = e;
        if (customE.runtimeType.toString().contains(
          'FirebaseFunctionsException',
        )) {
          try {
            code = customE.code?.toString();
          } catch (_) {}
          try {
            details = customE.message?.toString();
          } catch (_) {}
          if (details != null && details.isNotEmpty) rawMessage = details;
        }
      } catch (_) {
        // Fallback to string parsing
      }

      // If code is still null, try to parse from string "[firebase_functions/code] message"
      if (code == null && rawMessage.contains('firebase_functions/')) {
        final start = rawMessage.indexOf('/') + 1;
        final end = rawMessage.indexOf(']');
        if (start > 0 && end > start) {
          code = rawMessage.substring(start, end);
        }
      }

      // Cleanup generic prefixes from message if present
      if (details == null) {
        // Remove [firebase_functions/code] prefix
        if (rawMessage.contains('] ')) {
          details = rawMessage.split('] ').last;
        } else {
          details = rawMessage;
        }
      }

      final messageLower = (details ?? rawMessage).toLowerCase();
      final codeLower = (code ?? '').toLowerCase();
      String errorMessage;

      // 2. Map to user friendly messages
      if (codeLower == 'resource-exhausted' ||
          messageLower.contains('resource-exhausted')) {
        if (messageLower.contains('limite')) {
          errorMessage = details ?? 'Limite do plano atingido!';
        } else if (messageLower.contains('esgotado') ||
            messageLower.contains('cheio')) {
          errorMessage = 'Horário esgotado! Por favor escolha outro horário.';
        } else {
          errorMessage = details ?? 'Limite de agendamentos atingido.';
        }
      } else if (codeLower == 'failed-precondition' ||
          messageLower.contains('failed-precondition')) {
        if (messageLower.contains('antecedência')) {
          errorMessage = 'Antecedência mínima necessária (2h).';
        } else if (messageLower.contains('fechado') ||
            messageLower.contains('funcionamento')) {
          errorMessage = 'Estabelecimento fechado neste horário/dia.';
        } else {
          errorMessage =
              details ?? 'Não foi possível agendar. Verifique as regras.';
        }
      } else if (codeLower == 'permission-denied' ||
          messageLower.contains('permission-denied')) {
        errorMessage = details ?? 'Ação não permitida.';
      } else if (codeLower == 'already-exists' ||
          messageLower.contains('already-exists')) {
        errorMessage =
            'Já existe um agendamento para este veículo neste horário.';
      } else if (codeLower == 'unauthenticated' ||
          messageLower.contains('unauthenticated')) {
        errorMessage = 'Você precisa estar logado.';
      } else {
        // Fallback: Show the clean message from server
        errorMessage = details ?? rawMessage;
      }

      state = state.copyWith(error: errorMessage);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final bookingControllerProvider =
    AutoDisposeNotifierProvider<BookingController, BookingState>(
      BookingController.new,
    );
