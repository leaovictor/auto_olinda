
export type UserRole = 'admin' | 'member' | 'owner';

export interface UserData {
  uid: string;
  email: string;
  displayName?: string;
  tenantId?: string;
  role?: UserRole;
  createdAt: FirebaseFirestore.Timestamp;
}

export interface TenantData {
  id: string;
  name: string;
  ownerId: string;
  stripeCustomerId?: string;
  createdAt: FirebaseFirestore.Timestamp;
}

export interface SubscriptionData {
  status: 'active' | 'past_due' | 'canceled' | 'incomplete' | 'trialing';
  planId: string;
  currentPeriodEnd: FirebaseFirestore.Timestamp;
  stripeSubscriptionId: string;
  stripePriceId: string;
}
