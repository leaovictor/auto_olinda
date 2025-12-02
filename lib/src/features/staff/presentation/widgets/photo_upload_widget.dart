import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoUploadWidget extends ConsumerStatefulWidget {
  final String label;
  final List<String> photoUrls;
  final Function(File) onPhotoAdded;
  final Function(String) onPhotoRemoved;
  final bool isReadOnly;

  const PhotoUploadWidget({
    super.key,
    required this.label,
    required this.photoUrls,
    required this.onPhotoAdded,
    required this.onPhotoRemoved,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends ConsumerState<PhotoUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() => _isUploading = true);
        await widget.onPhotoAdded(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao tirar foto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.photoUrls.length + (widget.isReadOnly ? 0 : 1),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (!widget.isReadOnly && index == widget.photoUrls.length) {
                return _buildAddButton(theme);
              }
              return _buildPhotoItem(widget.photoUrls[index], theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isUploading ? null : _takePhoto,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: _isUploading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicionar',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPhotoItem(String url, ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
        if (!widget.isReadOnly)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onPhotoRemoved(url),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
