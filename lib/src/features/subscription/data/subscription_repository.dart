import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../features/subscription/domain/subscription_plan.dart';
import '../../../features/subscription/domain/subscriber.dart';
import '../../../features/subscription/domain/subscription_details.dart';
import '../../../features/subscription/domain/subscription_invoice.dart';
import '../../auth/data/auth_repository.dart';
import '../../admin/data/analytics_repository.dart';
import '../../../core/tenant/tenant_firestore.dart';
import '../../../core/tenant/tenant_service.dart';

part 'subscription_repository.g.dart';

class SubscriptionRepository {
  // ignore: unused_field — passed to AnalyticsRepository which needs it for Firestore transactions
  final FirebaseFirestore _firestore;
  final String _tenantId;

  final AnalyticsRepository _analytics;

  SubscriptionRepository(this._firestore, this._tenantId)
    : _analytics = AnalyticsRepository(_firestore, _tenantId);

  /// Swap the vehicle for an existing subscription.
  /// This involves:
  /// 1. Verifying 30-day limit (optional strict check).
  /// 2. Changing the Stripe Subscription Plan if the new plan is different.
  /// 3. Updating the Firestore subscription document with new vehicle details and `lastPlateChange`.
  Future<void> swapSubscriptionVehicle({
    required String subscriptionId,
    required String userId,
    required String oldVehicleId,
    required String newVehicleId,
    required String newVehiclePlate,
    required String newVehicleCategory,
    required SubscriptionPlan newPlan,
    required SubscriptionPlan oldPlan,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );

      // 1. If Plan/Price is different, calling Stripe Change
      if (newPlan.id != oldPlan.id) {
        print('SWAP: Changing plan from ${oldPlan.name} to ${newPlan.name}');
        print('SWAP: Changing plan from ${oldPlan.name} to ${newPlan.name}');
        await changeSubscriptionPlan(subscriptionId, newPlan.stripePriceId);

        // Log plan change
        await _analytics.logSubscriptionStatusChange(
          subscriptionId: subscriptionId,
          userId: userId,
          previousStatus: 'active', // Assuming it was active
          newStatus: 'active',
          reason: 'vehicle_swap_upgrade',
          planId: newPlan.id,
          planValue: newPlan.price,
        );
      }

      // 2. Call Cloud Function to validate and update vehicle (Asaas)
      await functions.httpsCallable('updateAsaasSubscriptionVehicle').call({
        'subscriptionId': subscriptionId,
        'newVehicleId': newVehicleId,
      });

      print('SWAP: Successfully swapped to vehicle $newVehiclePlate');
    } catch (e) {
      print('SWAP Error: $e');
      // Map Cloud Function errors to user friendly messages if possible
      if (e is FirebaseFunctionsException) {
        throw Exception(e.message ?? 'Erro ao trocar veículo');
      }
      throw Exception('Falha ao trocar de veículo: $e');
    }
  }

  Stream<List<SubscriptionPlan>> getActivePlans() {
    return TenantFirestore.col('plans', _tenantId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  Stream<List<Subscriber>> getUserSubscriptions(String userId) {
    return TenantFirestore.col('subscriptions', _tenantId)
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['active', 'trialing'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Subscriber.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  // Legacy method kept for backward compatibility but modified to return the first if available
  Stream<Subscriber?> getUserSubscription(String userId) {
    return getUserSubscriptions(userId).map((list) {
      if (list.isEmpty) return null;
      return list.first;
    });
  }

  Future<Map<String, dynamic>> createSubscriptionIntent(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleCategory,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final params = {'priceId': plan.stripePriceId};

      if (couponId != null) params['couponId'] = couponId;
      if (vehicleId != null) params['vehicleId'] = vehicleId;
      if (vehiclePlate != null) params['vehiclePlate'] = vehiclePlate;
      if (vehicleCategory != null) params['vehicleCategory'] = vehicleCategory;

      // Asaas-based subscription creation
      final result = await functions
          .httpsCallable('createAsaasSubscription')
          .call(params);

      return result.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create subscription intent: $e');
    }
  }

  Future<void> subscribeToPlan(
    String userId,
    SubscriptionPlan plan, {
    String? couponId,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleCategory,
  }) async {
    try {
      if (kIsWeb) {
        // Web Flow is now handled in the UI using createSubscriptionIntent
        // and WebPaymentSheet.
        throw UnimplementedError(
          'Use createSubscriptionIntent and WebPaymentSheet for Web',
        );
      } else {
        // Mobile Flow: Payment Sheet
        final data = await createSubscriptionIntent(
          userId,
          plan,
          couponId: couponId,
          vehicleId: vehicleId,
          vehiclePlate: vehiclePlate,
          vehicleCategory: vehicleCategory,
        );

        // Set the publishable key from the server response
        Stripe.publishableKey = data['publishableKey'];

        // 1. Initialize Stripe
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            customFlow: false,
            merchantDisplayName: 'AquaClean',
            paymentIntentClientSecret: data['paymentIntent'],
            setupIntentClientSecret: data['setupIntent'],
            customerEphemeralKeySecret: data['ephemeralKey'],
            customerId: data['customer'],
            style: ThemeMode.light,
          ),
        );

        // 2. Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();
      }

      // 3. Payment successful (if no exception thrown)
    } catch (e) {
      if (e is StripeException) {
        throw Exception(
          'Payment cancelled or failed: ${e.error.localizedMessage}',
        );
      }
      throw Exception('Failed to start subscription: $e');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas-based cancellation
      await functions.httpsCallable('cancelAsaasSubscription').call({
        'subscriptionId': subscriptionId,
      });

      try {
        final sub = await getSubscriptionById(subscriptionId);
        if (sub != null) {
          await _analytics.logSubscriptionStatusChange(
            subscriptionId: subscriptionId,
            userId: sub.userId,
            previousStatus: sub.status,
            newStatus: 'canceled',
            reason: 'user_cancelled',
            planId: sub.planId,
          );
        }
      } catch (e) {
        print('Error logging cancellation: $e');
      }
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<void> reactivateSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas-based reactivation
      await functions.httpsCallable('reactivateAsaasSubscription').call({
        'subscriptionId': subscriptionId,
      });

      try {
        final sub = await getSubscriptionById(subscriptionId);
        if (sub != null) {
          await _analytics.logSubscriptionStatusChange(
            subscriptionId: subscriptionId,
            userId: sub.userId,
            previousStatus: 'canceled',
            newStatus: 'active',
            reason: 'user_reactivated',
            planId: sub.planId,
          );
        }
      } catch (e) {
        print('Error logging reactivation: $e');
      }
    } catch (e) {
      throw Exception('Failed to reactivate subscription: $e');
    }
  }

  Future<void> changeSubscriptionPlan(
    String subscriptionId,
    String newPriceId,
  ) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas plan change
      await functions
          .httpsCallable('changeAsaasPlan')
          .call({'subscriptionId': subscriptionId, 'newPriceId': newPriceId});
    } catch (e) {
      throw Exception('Failed to change subscription plan: $e');
    }
  }

  Future<Subscriber?> getAnyUserSubscription(String userId) async {
    try {
      final snapshot = await TenantFirestore.col('subscriptions', _tenantId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Subscriber.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      return null;
    }
  }

  Future<Subscriber?> checkExistingSubscriptionByPlate(
    String userId,
    String plate,
  ) async {
    try {
      final snapshot = await TenantFirestore.col('subscriptions', _tenantId)
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['active', 'trialing'])
          .get();

      if (snapshot.docs.isEmpty) return null;

      final normalizedPlate = plate.toUpperCase();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final linkedPlate = (data['linkedPlate'] as String? ?? '').toUpperCase();
        if (linkedPlate == normalizedPlate) {
          return Subscriber.fromJson({...data, 'id': doc.id});
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> syncSubscriptionStatus(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas sync
      await functions.httpsCallable('syncAsaasSubscriptions').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to sync subscription status: $e');
    }
  }

  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) async {
    try {
      final doc = await TenantFirestore.doc('plans', planId, _tenantId).get();
      if (!doc.exists) return null;
      return SubscriptionPlan.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<Subscriber?> getSubscriptionById(String subscriptionId) async {
    try {
      final doc = await TenantFirestore.doc(
        'subscriptions',
        subscriptionId,
        _tenantId,
      ).get();
      if (!doc.exists) return null;
      return Subscriber.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<void> syncUserSubscriptionsFromStripe() async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas equivalent
      await functions.httpsCallable('syncAsaasSubscriptions').call();
    } catch (e) {
      throw Exception('Failed to sync subscriptions: $e');
    }
  }

  Future<SubscriptionPlan?> getSubscriptionPlanIncludingInactive(
    String planId,
  ) async {
    try {
      final doc = await TenantFirestore.doc('plans', planId, _tenantId).get();
      if (!doc.exists) return null;
      return SubscriptionPlan.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<SubscriptionPlan?> getSubscriptionPlanByStripePriceId(
    String stripePriceId,
  ) async {
    try {
      final snapshot = await TenantFirestore.col('plans', _tenantId)
          .where('stripePriceId', isEqualTo: stripePriceId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return SubscriptionPlan.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      return null;
    }
  }

  /// Admin creates a subscription manually using a PaymentMethod ID (from CardField)
  Future<void> adminCreateSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required String paymentMethodId,
    String? couponId,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final params = {
        'userId': userId,
        'priceId': plan.stripePriceId,
        'paymentMethodId': paymentMethodId,
      };
      if (couponId != null) {
        params['couponId'] = couponId;
      }
      await functions.httpsCallable('adminCreateSubscription').call(params);

      // Log creation
      await _analytics.logSubscriptionStatusChange(
        subscriptionId:
            'new_admin_sub', // We don't get the ID back easily from this specific call structure without return
        userId: userId,
        previousStatus: 'none',
        newStatus: 'active',
        reason: 'admin_created',
        planId: plan.id,
        planValue: plan.price,
      );
    } catch (e) {
      if (e is FirebaseFunctionsException) {
        throw Exception(e.message ?? e.toString());
      }
      throw Exception('Failed to create subscription: $e');
    }
  }

  Future<SubscriptionDetails> getSubscriptionDetails(
    String subscriptionId,
  ) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas details
      final result = await functions
          .httpsCallable('getAsaasSubscriptionDetails')
          .call({'subscriptionId': subscriptionId});

      return SubscriptionDetails.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get subscription details: $e');
    }
  }

  Future<List<SubscriptionInvoice>> getSubscriptionInvoices({
    String? stripeSubscriptionId,
  }) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      // Asaas invoices
      final result = await functions
          .httpsCallable('getAsaasInvoices')
          .call(
            stripeSubscriptionId != null
                ? {'subscriptionId': stripeSubscriptionId}
                : null,
          );

      final raw = result.data;
      // Cloud Functions can return a Map or a List depending on implementation
      List<dynamic> invoicesList;
      if (raw is Map) {
        invoicesList = (raw['invoices'] as List<dynamic>? ?? []);
      } else if (raw is List) {
        invoicesList = raw;
      } else {
        invoicesList = [];
      }

      return invoicesList.map((invoice) {
        return SubscriptionInvoice.fromJson(
          Map<String, dynamic>.from(invoice as Map),
        );
      }).toList();
    } catch (e) {
      print('Error fetching subscription invoices: $e');
      // Rethrow so the UI can display the real error
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  final tenantId =
      ref.watch(tenantServiceProvider).valueOrNull?.tenantId ?? '';
  return SubscriptionRepository(ref.watch(firebaseFirestoreProvider), tenantId);
}

@riverpod
Stream<List<SubscriptionPlan>> activePlans(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).getActivePlans();
}

final userSubscriptionsProvider = StreamProvider<List<Subscriber>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(subscriptionRepositoryProvider)
      .getUserSubscriptions(user.uid);
});

/// Family key: (vehicleId, plate) — plate is the primary lookup key;
/// vehicleId is kept as a fallback for legacy documents.
typedef VehicleSubKey = ({String vehicleId, String plate});

final vehicleSubscriptionProvider =
    StreamProvider.family<Subscriber?, VehicleSubKey>((ref, key) {
      final user = ref.watch(authStateChangesProvider).value;
      if (user == null) return Stream.value(null);

      final normalizedPlate = key.plate.toUpperCase();

      return ref
          .watch(subscriptionRepositoryProvider)
          .getUserSubscriptions(user.uid)
          .map((subscriptions) {
            if (subscriptions.isEmpty) return null;

            // 1. Prefer match by plate (survives vehicle doc deletion)
            for (final sub in subscriptions) {
              if ((sub.linkedPlate ?? '').toUpperCase() == normalizedPlate) {
                return sub;
              }
            }
            // 2. Fallback: match by vehicleId (legacy documents)
            for (final sub in subscriptions) {
              if (sub.vehicleId == key.vehicleId) return sub;
            }
            // 3. Final fallback: if the user has any active subscription,
            //    treat this vehicle as covered (handles legacy subscriptions
            //    that were created before linkedPlate was stored in Stripe metadata).
            return subscriptions.first;
          });
    });

@riverpod
Stream<Subscriber?> userSubscription(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(subscriptionRepositoryProvider)
      .getUserSubscription(user.uid);
}

/// Provider to get subscription for any user ID (used by staff to check if customer is premium)
/// Using manual provider family to avoid needing build_runner
final subscriptionByUserIdProvider = StreamProvider.family<Subscriber?, String>(
  (ref, userId) {
    return ref
        .watch(subscriptionRepositoryProvider)
        .getUserSubscription(userId);
  },
);

final subscriptionPlanProvider =
    FutureProvider.family<SubscriptionPlan?, String>((ref, planId) {
      return ref
          .watch(subscriptionRepositoryProvider)
          .getSubscriptionPlan(planId);
    });

/// Resolves a SubscriptionPlan from a Stripe Price ID or a Firestore plan ID.
/// First tries matching by stripePriceId (covers the common case where
/// subscriber.planId stores a Stripe Price ID), then falls back to a direct
/// document lookup, and finally to the active-plans list.
final resolvedPlanProvider =
    FutureProvider.family<SubscriptionPlan?, String>((ref, planId) async {
      final repo = ref.watch(subscriptionRepositoryProvider);

      // 1. Try to match by stripePriceId (most common case)
      final byPriceId = await repo.getSubscriptionPlanByStripePriceId(planId);
      if (byPriceId != null) return byPriceId;

      // 2. Fallback: try direct Firestore doc lookup (in case planId IS the doc ID)
      final byDocId = await repo.getSubscriptionPlanIncludingInactive(planId);
      if (byDocId != null) return byDocId;

      // 3. Fallback: check active plans list
      final activePlans = ref.read(activePlansProvider).valueOrNull ?? [];
      try {
        return activePlans.firstWhere(
          (p) => p.stripePriceId == planId || p.id == planId,
        );
      } catch (_) {
        return null;
      }
    });
