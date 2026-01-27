import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../booking/data/review_tag_repository.dart';
import '../../../booking/domain/review_tag.dart';
import '../../../../shared/utils/app_toast.dart';
import '../theme/admin_theme.dart';

/// Tela para gerenciar tags de avaliação
class AdminReviewTagsScreen extends ConsumerWidget {
  const AdminReviewTagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allReviewTagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tags de Avaliação'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: tagsAsync.when(
          data: (tags) => _buildTagsList(context, ref, tags),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: AdminTheme.gradientDanger[0],
                ),
                const SizedBox(height: 16),
                Text('Erro ao carregar tags', style: AdminTheme.bodyLarge),
                const SizedBox(height: 8),
                Text(error.toString(), style: AdminTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTagDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tag'),
        backgroundColor: AdminTheme.gradientPrimary[0],
      ),
    );
  }

  Widget _buildTagsList(
    BuildContext context,
    WidgetRef ref,
    List<ReviewTag> tags,
  ) {
    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_off, size: 64, color: AdminTheme.textMuted),
            const SizedBox(height: 16),
            Text('Nenhuma tag criada', style: AdminTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Clique no botão + para criar a primeira tag',
              style: AdminTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tags.length,
      onReorder: (oldIndex, newIndex) =>
          _handleReorder(context, ref, tags, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final tag = tags[index];
        return _buildTagCard(
          context,
          ref,
          tag,
          index,
        ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: -0.1);
      },
    );
  }

  Widget _buildTagCard(
    BuildContext context,
    WidgetRef ref,
    ReviewTag tag,
    int index,
  ) {
    return Container(
      key: ValueKey(tag.id),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(AdminTheme.radiusLG),
        border: Border.all(color: AdminTheme.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Icon(Icons.drag_handle, color: AdminTheme.textMuted, size: 24),
            const SizedBox(width: 12),
            // Emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tag.isActive
                    ? AdminTheme.gradientSuccess[0].withOpacity(0.1)
                    : AdminTheme.textMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(tag.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
        title: Text(
          tag.label,
          style: AdminTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: tag.isActive ? AdminTheme.textPrimary : AdminTheme.textMuted,
          ),
        ),
        subtitle: Text(
          tag.isActive ? 'Ativa • Ordem: ${tag.displayOrder}' : 'Inativa',
          style: AdminTheme.bodySmall.copyWith(
            color: tag.isActive
                ? AdminTheme.gradientSuccess[0]
                : AdminTheme.textMuted,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle active/inactive
            Switch(
              value: tag.isActive,
              onChanged: (value) => _toggleTagActive(context, ref, tag, value),
              activeThumbColor: AdminTheme.gradientSuccess[0],
            ),
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AdminTheme.gradientPrimary[0],
              onPressed: () => _showTagDialog(context, ref, tag: tag),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AdminTheme.gradientDanger[0],
              onPressed: () => _confirmDelete(context, ref, tag),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTagActive(
    BuildContext context,
    WidgetRef ref,
    ReviewTag tag,
    bool isActive,
  ) async {
    try {
      await ref
          .read(reviewTagRepositoryProvider)
          .toggleTagActive(tag.id, isActive);
      if (context.mounted) {
        AppToast.success(
          context,
          message: isActive ? 'Tag ativada' : 'Tag desativada',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao atualizar tag: $e');
      }
    }
  }

  Future<void> _handleReorder(
    BuildContext context,
    WidgetRef ref,
    List<ReviewTag> tags,
    int oldIndex,
    int newIndex,
  ) async {
    // Adjust newIndex if moving down (Flutter's ReorderableListView behavior)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Create a mutable copy of the list
    final reorderedTags = List<ReviewTag>.from(tags);
    final movedTag = reorderedTags.removeAt(oldIndex);
    reorderedTags.insert(newIndex, movedTag);

    // Calculate new displayOrder values for all tags
    final updates = <({String tagId, int displayOrder})>[];
    for (int i = 0; i < reorderedTags.length; i++) {
      final tag = reorderedTags[i];
      if (tag.displayOrder != i) {
        updates.add((tagId: tag.id, displayOrder: i));
      }
    }

    // Only update if there are changes
    if (updates.isEmpty) return;

    try {
      await ref.read(reviewTagRepositoryProvider).updateTagsOrder(updates);
      if (context.mounted) {
        AppToast.success(context, message: 'Ordem atualizada com sucesso');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao atualizar ordem: $e');
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ReviewTag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir a tag "${tag.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(reviewTagRepositoryProvider).deleteTag(tag.id);
                if (context.mounted) {
                  AppToast.success(
                    context,
                    message: 'Tag excluída com sucesso',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppToast.error(context, message: 'Erro ao excluir tag: $e');
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref, {ReviewTag? tag}) {
    final isEditing = tag != null;
    final labelController = TextEditingController(text: tag?.label ?? '');
    final emojiController = TextEditingController(text: tag?.emoji ?? '');
    final displayOrderController = TextEditingController(
      text: tag?.displayOrder.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Tag' : 'Nova Tag'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Tag',
                  hintText: 'Ex: Serviço Rápido',
                  border: OutlineInputBorder(),
                ),
                autofocus: !isEditing,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(
                  labelText: 'Emoji',
                  hintText: '⭐',
                  border: OutlineInputBorder(),
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: displayOrderController,
                decoration: const InputDecoration(
                  labelText: 'Ordem de Exibição',
                  hintText: '1',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => _saveTag(
              context,
              ref,
              tag,
              labelController.text,
              emojiController.text,
              int.tryParse(displayOrderController.text) ?? 0,
            ),
            child: Text(isEditing ? 'Salvar' : 'Criar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTag(
    BuildContext context,
    WidgetRef ref,
    ReviewTag? existingTag,
    String label,
    String emoji,
    int displayOrder,
  ) async {
    if (label.trim().isEmpty || emoji.trim().isEmpty) {
      AppToast.warning(context, message: 'Preencha todos os campos');
      return;
    }

    Navigator.pop(context);

    try {
      final repository = ref.read(reviewTagRepositoryProvider);

      if (existingTag != null) {
        // Update existing tag
        await repository.updateTag(
          existingTag.copyWith(
            label: label.trim(),
            emoji: emoji.trim(),
            displayOrder: displayOrder,
          ),
        );
        if (context.mounted) {
          AppToast.success(context, message: 'Tag atualizada com sucesso');
        }
      } else {
        // Create new tag
        await repository.createTag(
          ReviewTag(
            id: '', // Will be auto-generated
            label: label.trim(),
            emoji: emoji.trim(),
            isActive: true,
            displayOrder: displayOrder,
            createdAt: DateTime.now(),
          ),
        );
        if (context.mounted) {
          AppToast.success(context, message: 'Tag criada com sucesso');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, message: 'Erro ao salvar tag: $e');
      }
    }
  }
}
