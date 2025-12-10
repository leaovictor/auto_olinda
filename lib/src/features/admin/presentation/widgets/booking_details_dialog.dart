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

            // Photo Gallery
            if (booking.beforePhotos.isNotEmpty ||
                booking.afterPhotos.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Fotos do Serviço:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Before Photos
              if (booking.beforePhotos.isNotEmpty) ...[
                Text(
                  '📷 Antes (${booking.beforePhotos.length})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: booking.beforePhotos
                      .map((url) => _buildPhotoThumbnail(context, url))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // After Photos
              if (booking.afterPhotos.isNotEmpty) ...[
                Text(
                  '✨ Depois (${booking.afterPhotos.length})',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: booking.afterPhotos
                      .map((url) => _buildPhotoThumbnail(context, url))
                      .toList(),
                ),
              ],
            ],
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

  Widget _buildPhotoThumbnail(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => _showFullScreenPhoto(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 100,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 80,
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: InteractiveViewer(child: Image.network(url))),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
