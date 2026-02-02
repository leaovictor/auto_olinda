import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lavaflow_app/src/features/subscription/data/subscription_repository.dart';
import 'app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeData theme(ThemeRef ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);

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
