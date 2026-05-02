# Subscription Plans Feature

Manages tenant subscription plans for SaaS billing.

## Structure
- `domain/models/` - TenantPlan entity with Stripe integration
- `domain/usecases/` - Plan CRUD operations
- `data/` - Firestore data source and repository
- `presentation/` - Plan management UI