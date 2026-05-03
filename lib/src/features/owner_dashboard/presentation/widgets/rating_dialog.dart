import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blurred_overlay/blurred_overlay.dart';
import '../../../../features/appointments/data/booking_repository.dart';
import '../../../../features/appointments/data/review_tag_repository.dart';
import '../../../../features/appointments/domain/review_tag.dart';
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
    return showBlurredDialog<bool>(
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
  final Set<String> _selectedTagIds = {};
  bool _isSubmitting = false;

  static const int maxCommentLength = 280;

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
      final comment = _commentController.text.trim();
      await ref
          .read(bookingRepositoryProvider)
          .markAsRated(
            widget.bookingId,
            _rating,
            comment.isEmpty ? null : comment,
            _selectedTagIds.toList(),
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
    final tagsAsync = ref.watch(activeReviewTagsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 400),
        child: SingleChildScrollView(
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

                // Comment TextField
                TextField(
                  controller: _commentController,
                  maxLength: maxCommentLength,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deixe um comentário (opcional)',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.6,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    counterStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Tags Section
                tagsAsync.when(
                  data: (tags) {
                    if (tags.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecione tags (opcional):',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            final isSelected = _selectedTagIds.contains(tag.id);
                            return _buildTagChip(tag, isSelected, theme);
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),

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
      ),
    );
  }

  Widget _buildTagChip(ReviewTag tag, bool isSelected, ThemeData theme) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(tag.emoji), const SizedBox(width: 6), Text(tag.label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTagIds.add(tag.id);
          } else {
            _selectedTagIds.remove(tag.id);
          }
        });
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
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
