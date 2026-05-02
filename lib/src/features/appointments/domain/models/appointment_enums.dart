enum AppointmentStatus {
  scheduled,    // Agendado, aguardando
  confirmed,    // Confirmado
  inProgress,   // Em andamento
  completed,    // Concluído
  cancelled,    // Cancelado
  noShow,       // Não compareceu
}

enum AppointmentPaymentStatus {
  pending,      // Aguardando pagamento
  paid,         // Pago
  partiallyPaid, // Parcialmente pago
  refunded,     // Reembolsado
  failed,       // Falhou
}
