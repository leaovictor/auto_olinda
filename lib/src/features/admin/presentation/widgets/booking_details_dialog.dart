import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/booking_with_details.dart';
import '../../../booking/domain/booking.dart';
import '../../data/admin_repository.dart';
import '../../../../shared/utils/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsDialog extends ConsumerWidget {
  final BookingWithDetails bookingData;

  const BookingDetailsDialog({super.key, required this.bookingData});

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted)
        AppToast.error(context, message: 'Erro ao abrir discador');
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted)
        AppToast.error(context, message: 'Erro ao abrir WhatsApp');
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    BookingStatus newStatus,
  ) async {
    // Basic confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Alteração'),
        content: Text('Mudar status para ${newStatus.name.toUpperCase()}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .updateBookingStatus(
              bookingData.booking.id,
              newStatus,
              actorId: 'admin', // Ideally get current user ID
            );
        if (context.mounted) {
          Navigator.pop(context);
          AppToast.success(context, message: 'Status atualizado!');
        }
      } catch (e) {
        if (context.mounted) AppToast.error(context, message: 'Erro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = bookingData.booking;
    final user = bookingData.user;
    final vehicle = bookingData.vehicle;
    final services = bookingData.services;

    return AlertDialog(
      title: const Text('Detalhes do Agendamento'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Info
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person),
              title: Text(user?.displayName ?? 'Cliente Desconhecido'),
              subtitle: user?.phoneNumber != null
                  ? Row(
                      children: [
                        Text(user!.phoneNumber!),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.chat,
                            color: Colors.green,
                            size: 20,
                          ),
                          onPressed: () =>
                              _openWhatsApp(context, user.phoneNumber!),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.phone,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () =>
                              _makePhoneCall(context, user.phoneNumber!),
                        ),
                      ],
                    )
                  : const Text('Sem telefone'),
            ),
            const Divider(),

            // Vehicle Info
            if (vehicle != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.directions_car),
                title: Text('${vehicle.brand} ${vehicle.model}'),
                subtitle: Text('Placa: ${vehicle.plate}'),
              ),

            // Services
            if (services.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Serviços:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...services.map((s) => Text('• ${s.title}')),
            ],

            const SizedBox(height: 16),
            const Text(
              'Status Atual:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(booking.status)),
              ),
              child: Text(
                booking.status.name.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(booking.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Quick Status Actions
        if (booking.status == BookingStatus.scheduled)
          FilledButton(
            onPressed: () =>
                _updateStatus(context, ref, BookingStatus.confirmed),
            child: const Text('Confirmar'),
          ),
        if (booking.status == BookingStatus.confirmed)
          FilledButton(
            onPressed: () => _updateStatus(context, ref, BookingStatus.washing),
            child: const Text('Iniciar Lavagem'),
          ),
        if (booking.status == BookingStatus.washing)
          FilledButton(
            onPressed: () =>
                _updateStatus(context, ref, BookingStatus.finished),
            child: const Text('Finalizar'),
          ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.scheduled:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkIn:
        return Colors.purple;
      case BookingStatus.washing:
        return Colors.blue[700]!;
      case BookingStatus.vacuuming:
        return Colors.teal;
      case BookingStatus.drying:
        return Colors.cyan;
      case BookingStatus.polishing:
        return Colors.amber;
      case BookingStatus.finished:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.grey;
    }
  }
}
