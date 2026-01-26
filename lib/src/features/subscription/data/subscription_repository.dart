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

part 'subscription_repository.g.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository(this._firestore);

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
        await changeSubscriptionPlan(subscriptionId, newPlan.stripePriceId);
      }

      // 2. Call Cloud Function to validate and update vehicle (enforces 30-day rule)
      print('SWAP: Calling updateSubscriptionVehicle for $newVehiclePlate');
      await functions.httpsCallable('updateSubscriptionVehicle').call({
        'subscriptionId': subscriptionId,
        'newVehicleId': newVehicleId,
        // The Cloud Function uses newVehicleId to fetch details, or we might need to pass plate/category if the function expects it.
        // My new function `subscription_vehicle.ts` expects `subscriptionId` and `newVehicleId`.
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
    return _firestore
        .collection('plans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SubscriptionPlan.fromJson({...doc.data(), 'id': doc.id});
          }).toList();
        });
  }

  Stream<List<Subscriber>> getUserSubscriptions(String userId) {
    return _firestore
        .collection('subscriptions')
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

      if (couponId != null) {
        params['couponId'] = couponId;
      }
      if (vehicleId != null) params['vehicleId'] = vehicleId;
      if (vehiclePlate != null) params['vehiclePlate'] = vehiclePlate;
      if (vehicleCategory != null) params['vehicleCategory'] = vehicleCategory;

      final result = await functions
          .httpsCallable('createPaymentSheet')
          .call(params);

      print('createPaymentSheet result: ${result.data}');

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
      await functions.httpsCallable('cancelSubscription').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  Future<void> reactivateSubscription(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('reactivateSubscription').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to reactivate subscription: $e');
    }
  }

  Future<void> changeSubscriptionPlan(
    String subscriptionId,
    String newPriceId,
  ) async {
    try {
      // Debug logging
      print('changeSubscriptionPlan called');
      print('subscriptionId: $subscriptionId');
      print('newPriceId: $newPriceId');

      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('changeSubscriptionPlan')
          .call({'subscriptionId': subscriptionId, 'newPriceId': newPriceId});

      print('changeSubscriptionPlan result: $result');
    } catch (e) {
      print('changeSubscriptionPlan error: $e');
      throw Exception('Failed to change subscription plan: $e');
    }
  }

  Future<Subscriber?> getAnyUserSubscription(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Subscriber.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      print('DEBUG: Error fetching any subscription: $e');
      return null;
    }
  }

  Future<void> syncSubscriptionStatus(String subscriptionId) async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      await functions.httpsCallable('syncSubscriptionStatus').call({
        'subscriptionId': subscriptionId,
      });
    } catch (e) {
      throw Exception('Failed to sync subscription status: $e');
    }
  }

  /// Get a single subscription plan by ID
  Future<SubscriptionPlan?> getSubscriptionPlan(String planId) async {
    try {
      final doc = await _firestore.collection('plans').doc(planId).get();
      if (!doc.exists) return null;
      return SubscriptionPlan.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('DEBUG: Error fetching subscription plan: $e');
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
      final result = await functions
          .httpsCallable('getSubscriptionDetails')
          .call({'subscriptionId': subscriptionId});

      return SubscriptionDetails.fromJson(
        Map<String, dynamic>.from(result.data as Map),
      );
    } catch (e) {
      throw Exception('Failed to get subscription details: $e');
    }
  }

  /// Fetch subscription invoices (payment history)
  Future<List<SubscriptionInvoice>> getSubscriptionInvoices() async {
    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      );
      final result = await functions
          .httpsCallable('getSubscriptionInvoices')
          .call();

      final data = result.data as Map<String, dynamic>;
      final invoices = data['invoices'] as List<dynamic>;

      return invoices.map((invoice) {
        return SubscriptionInvoice.fromJson(
          Map<String, dynamic>.from(invoice as Map),
        );
      }).toList();
    } catch (e) {
      print('Error fetching subscription invoices: $e');
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepository(ref.watch(firebaseFirestoreProvider));
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

final vehicleSubscriptionProvider = StreamProvider.family<Subscriber?, String>((
  ref,
  vehicleId,
) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Stream.value(null);

  return ref
      .watch(subscriptionRepositoryProvider)
      .getUserSubscriptions(user.uid)
      .map((subscriptions) {
        try {
          return subscriptions.firstWhere((sub) => sub.vehicleId == vehicleId);
        } catch (_) {
          return null;
        }
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
