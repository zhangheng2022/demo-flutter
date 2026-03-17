import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final galleryPhotosProvider = FutureProvider<List<String>>((ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  final photoDir = Directory('${appDir.path}/photos');

  if (!await photoDir.exists()) {
    return [];
  }

  final files = photoDir.listSync();
  final photos = files
      .whereType<File>()
      .where((f) => f.path.endsWith('.jpg'))
      .map((f) => f.path)
      .toList();

  photos.sort((a, b) => b.compareTo(a));
  return photos;
});

final photoCountProvider = FutureProvider<int>((ref) async {
  final photos = await ref.watch(galleryPhotosProvider.future);
  return photos.length;
});
