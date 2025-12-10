
# ⚠️ Ação Necessária: Configurar Segredos

Para que o código funcione em produção, você precisa definir a chave pública do Stripe como um segredo no Firebase Functions.

Execute este comando no terminal:

```bash
firebase functions:secrets:set STRIPE_PUBLISHABLE_KEY
```

Quando solicitado, cole sua chave pública do Stripe (ex: `pk_live_...` para produção ou `pk_test_...` para testes).
