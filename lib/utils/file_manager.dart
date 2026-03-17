import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileManager {
  static Future<Directory> getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/photos');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir;
  }

  static Future<void> deletePhoto(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> clearAllPhotos() async {
    final photoDir = await getPhotosDirectory();
    final files = photoDir.listSync();

    for (var file in files) {
      if (file is File) {
        await file.delete();
      }
    }
  }

  static Future<int> getPhotoCount() async {
    final photoDir = await getPhotosDirectory();
    final files = photoDir.listSync();
    return files.whereType<File>().length;
  }
}
