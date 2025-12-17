import 'dart:typed_data';

class ZipImage {
  const ZipImage({
    required this.name,
    required this.content,
    this.isIncluded = true,
  });
  final String name;
  final Uint8List content;
  final bool isIncluded;

  ZipImage copyWith({
    String? name,
    Uint8List? content,
    bool? isIncluded,
  }) {
    return ZipImage(
      name: name ?? this.name,
      content: content ?? this.content,
      isIncluded: isIncluded ?? this.isIncluded,
    );
  }
}

class ZipDirectory {
  const ZipDirectory({
    required this.id,
    required this.name,
    required this.images,
  });

  final String id;
  final String name;
  final List<ZipImage> images;

  ZipDirectory copyWith({
    String? id,
    String? name,
    List<ZipImage>? images,
  }) {
    return ZipDirectory(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
    );
  }
}
