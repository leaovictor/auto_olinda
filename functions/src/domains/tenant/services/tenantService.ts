
import { db, FieldValue } from '../../../config/firebase';
import { getStripe } from '../../billing/helpers/stripe';
import { TenantData } from '../../../core/types';

export const createTenantService = async (ownerUid: string, name: string) => {
  // 1. Create Tenant Reference
  const tenantRef = db.collection('tenants').doc();
  
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
    ownerId: ownerUid,
    stripeCustomerId: customer.id,
    createdAt: FieldValue.serverTimestamp() as FirebaseFirestore.Timestamp,
  };

  await tenantRef.set(newTenant);

  // 4. Update User with TenantId and Role
  await db.collection('users').doc(ownerUid).update({
    tenantId: tenantRef.id,
    role: 'owner'
  });

  return { tenantId: tenantRef.id };
};
