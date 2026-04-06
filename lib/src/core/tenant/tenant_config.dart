import 'package:flutter/material.dart';

/// Represents the tenant document stored at `tenants/{tenantId}`.
///
/// Fields are kept optional so the app degrades gracefully when
/// a tenant does not yet have all white-label properties configured.
class TenantConfig {
  final String id;
  final String appName;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? logoUrl;
  final bool asaasEnabled;
  final String? asaasApiKey;

  const TenantConfig({
    required this.id,
    required this.appName,
    this.primaryColor,
    this.secondaryColor,
    this.logoUrl,
    this.asaasEnabled = false,
    this.asaasApiKey,
  });

  /// Parse from Firestore document data.
  factory TenantConfig.fromJson(String id, Map<String, dynamic> data) {
    return TenantConfig(
      id: id,
      appName: data['appName'] as String? ?? 'Auto Olinda',
      primaryColor: _parseColor(data['primaryColor'] as String?),
      secondaryColor: _parseColor(data['secondaryColor'] as String?),
      logoUrl: data['logoUrl'] as String?,
      asaasEnabled: data['asaasEnabled'] as bool? ?? false,
      asaasApiKey: data['asaasApiKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'appName': appName,
    if (primaryColor != null)
      'primaryColor':
          '#${primaryColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    if (secondaryColor != null)
      'secondaryColor':
          '#${secondaryColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    if (logoUrl != null) 'logoUrl': logoUrl,
    'asaasEnabled': asaasEnabled,
  };

  /// Parses a hex color string such as `#1A2B3C` or `1A2B3C`.
  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    }
    if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    }
    return null;
  }
}
