class StripeConfig {
  /// Chave pública do Stripe.
  ///
  /// Em produção, use --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  /// Caso contrário, usará o valor padrão (Test Mode).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51SYcoM5uVLC6EX3m78P74UhblBFyRfK4kilvUS8rO94CbvXrQYmsg1ApO9r3Sf0YuCELV3TcKE06b3HOfvCJkN7I00reQwOwau',
  );
}
