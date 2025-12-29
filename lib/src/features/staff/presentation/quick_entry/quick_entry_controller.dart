import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quick_entry_repository.dart';
import '../../domain/active_service.dart';
import '../../domain/lead_client.dart';

class QuickEntryState {
  final bool isLoading;
  final LeadClient? existingLead;
  final ActiveService? createdService;
  final String? error;

  // Service selection
  final List<Map<String, dynamic>> availableServices;
  final String? selectedServiceId;
  final String? selectedServiceName;

  QuickEntryState({
    this.isLoading = false,
    this.existingLead,
    this.createdService,
    this.error,
    this.availableServices = const [],
    this.selectedServiceId,
    this.selectedServiceName,
  });

  QuickEntryState copyWith({
    bool? isLoading,
    LeadClient? existingLead,
    ActiveService? createdService,
    String? error,
    List<Map<String, dynamic>>? availableServices,
    String? selectedServiceId,
    String? selectedServiceName,
  }) {
    return QuickEntryState(
      isLoading: isLoading ?? this.isLoading,
      existingLead: existingLead ?? this.existingLead,
      createdService: createdService ?? this.createdService,
      error: error,
      availableServices: availableServices ?? this.availableServices,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      selectedServiceName: selectedServiceName ?? this.selectedServiceName,
    );
  }
}

class QuickEntryController extends StateNotifier<QuickEntryState> {
  final QuickEntryRepository _repository;
  final String staffId;

  QuickEntryController(this._repository, this.staffId)
    : super(QuickEntryState()) {
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      state = state.copyWith(isLoading: true);

      // Fetch both standard and independent services
      final services = await _repository.fetchServices();
      final aesthetic = await _repository.fetchIndependentServices();

      final allServices = [
        ...services.map((s) => {...s, 'type': 'wash'}),
        ...aesthetic.map((s) => {...s, 'type': 'aesthetic'}),
      ];

      state = state.copyWith(
        isLoading: false,
        availableServices: allServices,
        // Set default if available, logic can be improved
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar serviços: $e',
      );
    }
  }

  void selectService(String id, String name) {
    state = state.copyWith(selectedServiceId: id, selectedServiceName: name);
  }

  Future<void> searchPlate(String plate) async {
    if (plate.isEmpty) return;

    final normalizedPlate = plate
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toUpperCase();

    try {
      state = state.copyWith(isLoading: true, error: null);
      final lead = await _repository.getLeadByPlate(normalizedPlate);
      state = state.copyWith(isLoading: false, existingLead: lead);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitEntry({
    required String plate,
    required String vehicleModel,
    required String phoneNumber,
  }) async {
    if (state.selectedServiceId == null) {
      state = state.copyWith(error: 'Selecione um serviço');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final normalizedPlate = plate
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      final now = DateTime.now();

      // 1. Create/Update Lead
      var lead = state.existingLead;

      if (lead != null) {
        lead = lead.copyWith(
          vehicleModel: vehicleModel,
          phoneNumber: phoneNumber,
          lastServiceAt: now,
        );
      } else {
        lead = LeadClient(
          plate: normalizedPlate,
          phoneNumber: phoneNumber,
          vehicleModel: vehicleModel,
          status: LeadStatus.leadNaoCadastrado,
          createdAt: now,
          lastServiceAt: now,
        );
      }

      await _repository.saveLead(lead);

      // 2. Create Active Service
      final service = await _repository.createActiveService(
        plate: normalizedPlate,
        staffId: staffId,
        serviceType: state.selectedServiceName ?? 'Serviço',
        vehicleModel: vehicleModel,
      );

      state = state.copyWith(isLoading: false, createdService: service);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = QuickEntryState(
      availableServices: state.availableServices,
    ); // Keep services loaded
  }
}

final quickEntryControllerProvider =
    StateNotifierProvider.autoDispose<QuickEntryController, QuickEntryState>((
      ref,
    ) {
      final repo = ref.watch(quickEntryRepositoryProvider);
      final user = FirebaseAuth.instance.currentUser;
      final staffId = user?.uid ?? 'unknown_staff';
      return QuickEntryController(repo, staffId);
    });
