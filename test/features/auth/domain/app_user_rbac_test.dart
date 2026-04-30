import 'package:flutter_test/flutter_test.dart';
import 'package:aquaclean_mobile/src/features/auth/domain/app_user.dart';

void main() {
  group('AppUser RBAC (Role-Based Access Control)', () {
    test('isSuperAdmin is true only for superAdmin role', () {
      const user = AppUser(uid: '1', email: 'test@test.com', role: 'superAdmin');
      expect(user.isSuperAdmin, isTrue);
      expect(user.hasAdminAccess, isTrue);
      expect(user.isTenantAdmin, isFalse);
      expect(user.isStaff, isFalse);
      expect(user.isCustomer, isFalse);
    });

    test('isTenantAdmin is true for tenantOwner and admin roles', () {
      const owner = AppUser(uid: '2', email: 'test@test.com', role: 'tenantOwner', tenantId: 'tenant-1');
      expect(owner.isTenantAdmin, isTrue);
      expect(owner.hasAdminAccess, isTrue);
      expect(owner.isSuperAdmin, isFalse);

      // Legacy role fallback check
      const admin = AppUser(uid: '3', email: 'test@test.com', role: 'admin', tenantId: 'tenant-1');
      expect(admin.isTenantAdmin, isTrue);
      expect(admin.hasAdminAccess, isTrue);
    });

    test('isStaff is true only for staff role', () {
      const staff = AppUser(uid: '4', email: 'test@test.com', role: 'staff', tenantId: 'tenant-1');
      expect(staff.isStaff, isTrue);
      expect(staff.isSuperAdmin, isFalse);
      expect(staff.isTenantAdmin, isFalse);
      expect(staff.hasAdminAccess, isFalse);
    });

    test('isCustomer is true for customer and client roles', () {
      const customer = AppUser(uid: '5', email: 'test@test.com', role: 'customer', tenantId: 'tenant-1');
      expect(customer.isCustomer, isTrue);
      expect(customer.hasAdminAccess, isFalse);

      // Legacy role fallback check
      const client = AppUser(uid: '6', email: 'test@test.com', role: 'client', tenantId: 'tenant-1');
      expect(client.isCustomer, isTrue);
      expect(client.hasAdminAccess, isFalse);
    });
  });
}
