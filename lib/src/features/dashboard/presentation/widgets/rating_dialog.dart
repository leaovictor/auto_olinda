import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/booking/data/booking_repository.dart';
import '../../../../shared/utils/app_toast.dart';

/// Modal dialog for rating a completed car wash service
class RatingDialog extends ConsumerStatefulWidget {
  final String bookingId;
  final String userId;
  final String? vehicleModel;

  const RatingDialog({
    super.key,
    required this.bookingId,
    required this.userId,
    this.vehicleModel,
  });

  /// Show the rating dialog
  static Future<bool?> show(
    BuildContext context, {
    required String bookingId,
    required String userId,
    String? vehicleModel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        bookingId: bookingId,
        userId: userId,
        vehicleModel: vehicleModel,
      ),
    );
  }

  @override
  ConsumerState<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<RatingDialog> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      AppToast.warning(context, message: 'Selecione uma avaliação');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(bookingRepositoryProvider)
          .markAsRated(
            widget.bookingId,
            _rating,
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );

      // Force refresh of the bookings list
      ref.invalidate(userBookingsProvider(widget.userId));

      if (mounted) {
        AppToast.success(context, message: 'Obrigado pela sua avaliação!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, message: 'Erro ao enviar avaliação: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lavagem Finalizada!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.vehicleModel != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.vehicleModel!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Como foi a sua experiência?',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starIndex),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starIndex <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingLabel(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Comment Field
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Deixe um comentário (opcional)',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Depois'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submitRating,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enviar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingLabel() {
    switch (_rating) {
      case 1:
        return 'Muito ruim 😞';
      case 2:
        return 'Ruim 😕';
      case 3:
        return 'Regular 😐';
      case 4:
        return 'Bom 🙂';
      case 5:
        return 'Excelente! 🤩';
      default:
        return 'Toque nas estrelas';
    }
  }
}
