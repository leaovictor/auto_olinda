class StripeConfig {
  /// Chave pública do Stripe.
  ///
  /// Em produção, use --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  /// Caso contrário, usará o valor padrão (Test Mode).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SrPueGtVxuEofbfQzwtETOS2Q8r0FVD6AO1GzeSzACBH9ciimkq9QV3wa1GaclQoZU5TaDt59VW8TkaNiao0NjR00iGefzN83',
  );
}
