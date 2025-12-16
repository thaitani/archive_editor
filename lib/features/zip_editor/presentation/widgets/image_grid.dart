
import 'package:archive_editor/features/zip_editor/domain/zip_models.dart';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {

  const ImageGrid({
    required this.directory, super.key,
  });
  final ZipDirectory directory;

  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                image.content,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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
        );
      },
    );
  }
}
