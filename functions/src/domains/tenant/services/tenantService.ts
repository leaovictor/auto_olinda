
import { db, FieldValue } from '../../../config/firebase';
import { getStripe } from '../../billing/helpers/stripe';
import { TenantData } from '../../../core/types';

const generateSlug = (name: string): string => {
  return name
    .toLowerCase()
    .normalize('NFD') // Remove accents
    .replace(/[\u0300-\u036f]/g, '')
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
};

export const createTenantService = async (ownerUid: string, name: string, preferredTenantId?: string) => {
  // 1. Create Tenant Reference
  const tenantId = preferredTenantId || db.collection('tenants').doc().id;
  const tenantRef = db.collection('tenants').doc(tenantId);
  const slug = `${generateSlug(name)}-${tenantId.substring(0, 4)}`; // Ensure uniqueness with prefix

  // 2. Create Stripe Customer with Metadata
  const stripe = await getStripe();
  const customer = await stripe.customers.create({
    name: name,
    metadata: {
      firebaseTenantId: tenantRef.id,
      ownerUid: ownerUid
    }
  });

  // 3. Create Tenant Doc
  const newTenant: TenantData = {
    id: tenantRef.id,
    name: name,
    slug: slug,
    ownerId: ownerUid,
    stripeCustomerId: customer.id,
    branding: {
      primaryColor: '#2196F3', // Default Material Blue
    },
    domains: {
      subdomain: slug,
      domainVerified: false,
    },
    createdAt: FieldValue.serverTimestamp() as FirebaseFirestore.Timestamp,
  };

  await tenantRef.set(newTenant);

  // 4. Update User with TenantId and Role
  await db.collection('users').doc(ownerUid).set({
    tenantId: tenantRef.id,
    role: 'owner'
  }, { merge: true });

  return { tenantId: tenantRef.id, slug: slug };
};
