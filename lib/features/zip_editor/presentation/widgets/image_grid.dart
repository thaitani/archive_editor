import 'package:archive_editor/features/zip_editor/application/zip_editor_provider.dart';
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageGrid extends ConsumerWidget {
  const ImageGrid({
    required this.directory,
    super.key,
  });
  final ZipDirectory directory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (directory.images.isEmpty) {
      return const Center(
        child: Text('No images in this folder'),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: directory.images.length,
      itemBuilder: (context, index) {
        final image = directory.images[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      InteractiveViewer(
                        minScale: 0.1,
                        maxScale: 5,
                        clipBehavior: Clip.none,
                        child: Image.memory(
                          image.content,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  image.content,
                  fit: BoxFit.cover,
                  color: image.isIncluded
                      ? null
                      : Colors.white.withValues(alpha: 0.7),
                  colorBlendMode: image.isIncluded ? null : BlendMode.lighten,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Checkbox(
                    value: image.isIncluded,
                    onChanged: (value) {
                      ref.read(zipEditorProvider.notifier).toggleImageInclusion(
                            directory.name,
                            image.name,
                          );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      image.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
