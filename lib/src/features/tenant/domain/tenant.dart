import 'package:freezed_annotation/freezed_annotation.dart';
import 'business_config.dart';

part 'tenant.freezed.dart';
part 'tenant.g.dart';

@freezed
abstract class Tenant with _$Tenant {
  const factory Tenant({
    required String id,
    required String name,                        // Car wash business name
    required String ownerUid,                    // Firebase UID of owner
    @Default('active') String status,           // active | suspended | trial | cancelled
    
    // Stripe Connect for payments
    String? stripeAccountId,
    @Default(false) bool stripeOnboarded,
    @Default(10) int platformFeePercent,        // Platform commission percentage
    
    // Branding
    String? logoUrl,
    String? coverImageUrl,
    @Default('#0066CC') String primaryColor,
    String? secondaryColor,
    
    // Contact & Location
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    
    // Business Configuration
    BusinessConfig? businessConfig,
    
    // Limits & Features
    @Default(5) int maxStaffCount,
    @Default(100) int maxActiveServices,
    @Default(false) bool hasLoyaltyProgram,
    @Default(false) bool sendAutomatedReminders,
    @Default(true) bool notificationsEnabled,
    
    // Subscription/Trial
    @Default('trial') String subscriptionStatus, // trial | active | suspended | past_due
    DateTime? trialEndsAt,
    @Default(14) int trialDays,
    DateTime? subscriptionEndsAt,
    
    // Staff references
    @Default([]) List<String> staffIds,
    
    // Metadata
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) = _Tenant;

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);
}