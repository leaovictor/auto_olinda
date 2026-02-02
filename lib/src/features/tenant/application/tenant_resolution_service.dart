import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:html' as html; // Only works on Web
import '../domain/tenant.dart';

part 'tenant_resolution_service.g.dart';

@riverpod
class TenantResolutionService extends _$TenantResolutionService {
  @override
  FutureOr<Tenant?> build() async {
    final host = _getCurrentHost();
    if (host == null) return null;

    // 1. Check if it's a custom domain or subdomain
    // Example: tenant.lavaflow.app or www.tenant.com

    // 2. Query Firestore by slug (subdomain) or customDomain
    final firestore = FirebaseFirestore.instance;

    // First try by custom domain (exact host match)
    final customDomainQuery = await firestore
        .collection('tenants')
        .where('domains.customDomain', isEqualTo: host)
        .limit(1)
        .get();

    if (customDomainQuery.docs.isNotEmpty) {
      return Tenant.fromJson({
        ...customDomainQuery.docs.first.data(),
        'id': customDomainQuery.docs.first.id,
      });
    }

    // Then try by slug (subdomain)
    final slug = _extractSlugFromHost(host);
    if (slug != null && slug != 'www' && slug != 'app') {
      final slugQuery = await firestore
          .collection('tenants')
          .where('slug', isEqualTo: slug)
          .limit(1)
          .get();

      if (slugQuery.docs.isNotEmpty) {
        return Tenant.fromJson({
          ...slugQuery.docs.first.data(),
          'id': slugQuery.docs.first.id,
        });
      }
    }

    return null;
  }

  String? _getCurrentHost() {
    if (kIsWeb) {
      return html.window.location.host;
    }
    return null;
  }

  String? _extractSlugFromHost(String host) {
    // Basic logic mapping: {slug}.lavaflow.app -> {slug}
    // and {slug}.localhost -> {slug} (for dev)
    final parts = host.split('.');
    if (parts.length >= 2) {
      return parts[0];
    }
    return null;
  }
}
