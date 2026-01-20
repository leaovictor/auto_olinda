class StripeConfig {
  /// Chave pública do Stripe.
  ///
  /// Em produção, use --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  /// Caso contrário, usará o valor padrão (Test Mode).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SrPuqK8JyPQ2HlY7uGniLZ7zqZbW8xB5u0fDfHf7y5lMchW3M288Vtpvtsbd3zE7LKWENQc46NhoSiCHrI4rUGE005pMjNqMF',
  );
}
