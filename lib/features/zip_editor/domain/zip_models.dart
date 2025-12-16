
import 'dart:typed_data';

class ZipImage {

  const ZipImage({
    required this.name,
    required this.content,
  });
  final String name;
  final Uint8List content;
}

class ZipDirectory {

  const ZipDirectory({
    required this.name,
    required this.images,
  });
  final String name;
  final List<ZipImage> images;

  ZipDirectory copyWith({
    String? name,
    List<ZipImage>? images,
  }) {
    return ZipDirectory(
      name: name ?? this.name,
      images: images ?? this.images,
    );
  }
}
