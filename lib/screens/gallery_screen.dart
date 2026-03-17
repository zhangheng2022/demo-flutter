import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../providers/gallery_provider.dart';
import '../utils/file_manager.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(galleryPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: photos.when(
        data: (photoList) {
          if (photoList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无照片'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photoList.length,
            itemBuilder: (context, index) {
              final photoPath = photoList[index];
              return GestureDetector(
                onTap: () => _showPhotoDetail(context, photoPath),
                onLongPress: () => _deletePhoto(context, ref, photoPath),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(photoPath)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePhoto(BuildContext context, WidgetRef ref, String photoPath) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除照片'),
        content: const Text('确定要删除这张照片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await FileManager.deletePhoto(photoPath);
              if (dialogContext.mounted) {
                // ignore: unused_result
                ref.refresh(galleryPhotosProvider);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
