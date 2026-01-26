import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StrikeBanner extends StatelessWidget {
  final DateTime strikeUntil;

  const StrikeBanner({super.key, required this.strikeUntil});

  @override
  Widget build(BuildContext context) {
    // Only show if strike is in the future
    if (DateTime.now().isAfter(strikeUntil)) {
      return const SizedBox.shrink();
    }

    final formattedDate = DateFormat('dd/MM HH:mm').format(strikeUntil);
    // Determine if it's within 24h (just show time) or more (show day)
    // Actually formattedDate 'dd/MM HH:mm' covers both well.

    return Container(
      width: double.infinity,
      color: Colors.red.shade700,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.block, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bloqueio de agendamento ativo até $formattedDate',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
