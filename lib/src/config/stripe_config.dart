class StripeConfig {
  /// Chave pública do Stripe.
  ///
  /// Em produção, use --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
  /// Caso contrário, usará o valor padrão (Test Mode).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_live_51SrPueGtVxuEofbfv4pmZvIqOwIMRrChbiVMGE7DjqrtdWGBgS9pxFZYd0HVQiNhW2tIgKYEPL3YdFkzQVWCkyZp004OcUn0Lj',
  );
}
