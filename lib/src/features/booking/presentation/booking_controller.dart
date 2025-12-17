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
    String? error,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
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
    print('🔵 confirmBooking: Starting...');
    final user = ref.read(authRepositoryProvider).currentUser;
    print('🔵 confirmBooking: User = ${user?.uid}');

    if (user == null) {
      print('❌ confirmBooking: No user found');
      state = state.copyWith(error: 'Usuário não autenticado.');
      return false;
    }

    if (state.selectedServices.isEmpty) {
      print('❌ confirmBooking: No services selected');
      state = state.copyWith(error: 'Selecione pelo menos um serviço.');
      return false;
    }

    if (state.selectedVehicle == null) {
      print('❌ confirmBooking: No vehicle selected');
      state = state.copyWith(error: 'Selecione um veículo.');
      return false;
    }

    if (state.selectedTimeSlot == null) {
      print('❌ confirmBooking: No time slot selected');
      state = state.copyWith(error: 'Selecione um horário.');
      return false;
    }

    print('🔵 confirmBooking: Setting loading state...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check for Premium Subscription
      final subscriptionAsync = ref.read(userSubscriptionProvider);
      print(
        '🔵 confirmBooking: Subscription state = ${subscriptionAsync.runtimeType}',
      );
      print(
        '🔵 confirmBooking: Subscription value = ${subscriptionAsync.value}',
      );
      print(
        '🔵 confirmBooking: Subscription isActive = ${subscriptionAsync.value?.isActive}',
      );
      print(
        '🔵 confirmBooking: Subscription status = ${subscriptionAsync.value?.status}',
      );

      final isPremium =
          subscriptionAsync.value?.isActive == true &&
          subscriptionAsync.value?.status != 'canceled';

      print('🔵 confirmBooking: isPremium = $isPremium');

      // For premium users: service is free, but products are always paid
      // For non-premium: everything is paid
      final servicePrice = isPremium ? 0.0 : state.serviceTotalPrice;
      final productsPrice = state.productsTotalPrice; // Always paid
      final finalPrice = servicePrice + productsPrice;

      print(
        '🔵 confirmBooking: finalPrice = $finalPrice (services: $servicePrice, products: $productsPrice)',
      );

      final booking = Booking(
        id: '', // Will be generated by repository
        userId: user.uid,
        vehicleId: state.selectedVehicle!.id,
        serviceIds: state.selectedServices.map((s) => s.id).toList(),
        productIds: state.selectedProducts.map((p) => p.id).toList(),
        scheduledTime: state.selectedTimeSlot!,
        status: BookingStatus.scheduled,
        totalPrice: finalPrice,
      );

      print('🔵 confirmBooking: Created booking object');
      print('   - userId: ${booking.userId}');
      print('   - vehicleId: ${booking.vehicleId}');
      print('   - scheduledTime: ${booking.scheduledTime}');
      print(
        '   - serviceIds: ${booking.serviceIds} (Count: ${booking.serviceIds.length})',
      );
      print(
        '   - formattedTime (UTC): ${booking.scheduledTime.toUtc().toIso8601String()}',
      );
      print('   - totalPrice: ${booking.totalPrice} (Premium: $isPremium)');

      print('🔵 confirmBooking: Calling repository.createBooking...');
      final bookingId = await ref
          .read(bookingRepositoryProvider)
          .createBooking(booking);
      print('✅ confirmBooking: SUCCESS! Booking ID = $bookingId');

      // Success - clear error
      state = state.copyWith(error: null);
      return true;
    } catch (e, stackTrace) {
      print('❌ confirmBooking: ERROR - $e');
      print('❌ Stack trace: $stackTrace');

      String errorMessage = 'Ocorreu um erro ao processar seu agendamento.';

      // Parse Exception message if it comes from our Repository/Cloud Function
      // The repository usually throws Exception(message) or FirebaseFunctionsException
      final message = e.toString();

      if (message.contains('resource-exhausted')) {
        // Extract the actual server message - e.g., "Você atingiu o limite de X lavagens..."
        if (message.contains('limite')) {
          // Use the actual message from server
          final parts = message.split(': ');
          errorMessage = parts.length > 1
              ? parts.last
              : 'Limite do plano atingido! Faça um upgrade para continuar agendando.';
        } else if (message.contains('Horário esgotado')) {
          errorMessage =
              'Este horário está cheio. Por favor, escolha outro horário.';
        } else {
          errorMessage =
              'Limite do plano atingido! Faça um upgrade para continuar agendando.';
        }
      } else if (message.contains('failed-precondition')) {
        // Extract the custom message from backend if possible, or generic
        if (message.contains('antecedência')) {
          errorMessage =
              'Agendamentos devem ter antecedência mínima. Tente um horário mais tarde.';
        } else {
          errorMessage =
              'Não foi possível completar o agendamento. Verifique se o horário é válido.';
        }
        // If the exception message has the clean text, use it:
        // usually it is "Exception: [code] message"
        if (message.contains(': ')) {
          errorMessage = message.split(': ').last;
        }
      } else if (message.contains('unauthenticated')) {
        errorMessage = 'Você precisa estar logado.';
      } else if (message.contains('invalid-argument')) {
        errorMessage = 'Dados inválidos. Tente novamente.';
        if (message.contains(': ')) {
          errorMessage = message.split(': ').last;
        }
      } else {
        // For other errors, try to show the server message if available
        if (message.contains(': ')) {
          errorMessage = message.split(': ').last;
        }
      }

      state = state.copyWith(error: errorMessage);
      return false;
    } finally {
      print('🔵 confirmBooking: Setting loading to false');
      state = state.copyWith(isLoading: false);
    }
  }
}

final bookingControllerProvider =
    NotifierProvider.autoDispose<BookingController, BookingState>(() {
      return BookingController();
    });
