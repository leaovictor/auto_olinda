import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/subscription/data/subscription_repository.dart';
import '../../core/tenant/tenant_config_provider.dart';
import 'app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeData theme(ThemeRef ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);
  final tenantConfig = ref.watch(tenantConfigProvider).valueOrNull;

  // If tenant has a custom primary color, build a white-label theme.
  if (tenantConfig?.primaryColor != null) {
    final primaryColor = tenantConfig!.primaryColor!;
    final base = subscriptionAsync.when(
      data: (subscription) {
        if (subscription != null &&
            subscription.isActive &&
            subscription.status != 'canceled') {
          return AppTheme.goldTheme;
        }
        return AppTheme.lightTheme;
      },
      loading: () => AppTheme.lightTheme,
      error: (_, __) => AppTheme.lightTheme,
    );

    // Override the colorScheme primary with the tenant color.
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: primaryColor),
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: primaryColor),
      floatingActionButtonTheme:
          base.floatingActionButtonTheme.copyWith(backgroundColor: primaryColor),
    );
  }

  // Default: subscription-driven theme.
  return subscriptionAsync.when(
    data: (subscription) {
      if (subscription != null &&
          subscription.isActive &&
          subscription.status != 'canceled') {
        return AppTheme.goldTheme;
      }
      return AppTheme.lightTheme;
    },
    loading: () => AppTheme.lightTheme,
    error: (_, __) => AppTheme.lightTheme,
  );
}
