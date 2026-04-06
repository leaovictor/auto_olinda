#!/usr/bin/env sh
#
# setup-secrets.sh
# Run this ONCE to configure all required Firebase Secrets before deploying.
#
# Prerequisites:
#   - Firebase CLI installed: npm install -g firebase-tools
#   - Logged in: firebase login
#   - Project selected: firebase use autoolinda-5199e
#
# Usage:
#   chmod +x setup-secrets.sh
#   ./setup-secrets.sh

echo "=== Setting Firebase Secrets for Multi-Tenant SaaS ==="
echo ""

echo "[1/3] Setting ASAAS_WEBHOOK_TOKEN"
echo "      → Get this from: Asaas Dashboard → Configurações → Integrações → Webhook"
echo "      → It's the 'Access Token' field shown when you configure the webhook URL."
firebase functions:secrets:set ASAAS_WEBHOOK_TOKEN

echo ""

echo "[2/3] Setting SUPER_ADMIN_UID"
echo "      → This is the Firebase Auth UID of the platform super-admin."
echo "      → Find it in Firebase Console → Authentication → Users"
echo "      → Only this user can call createTenant() and migrateToMultiTenant()"
firebase functions:secrets:set SUPER_ADMIN_UID

echo ""

echo "[3/3] Verifying existing secrets are still set..."
echo "      (STRIPE_SECRET, STRIPE_WEBHOOK_SECRET, STRIPE_PUBLISHABLE_KEY)"
echo "      → If any are missing, run: firebase functions:secrets:set <NAME>"
firebase functions:secrets:access STRIPE_SECRET > /dev/null 2>&1 && echo "  ✅ STRIPE_SECRET OK" || echo "  ⚠️  STRIPE_SECRET missing"
firebase functions:secrets:access STRIPE_WEBHOOK_SECRET > /dev/null 2>&1 && echo "  ✅ STRIPE_WEBHOOK_SECRET OK" || echo "  ⚠️  STRIPE_WEBHOOK_SECRET missing"

echo ""
echo "=== Done! Now deploy: firebase deploy --only functions ==="
