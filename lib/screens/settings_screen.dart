import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/gallery_provider.dart';
import '../utils/file_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageQuality = ref.watch(imageQualityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '图像质量',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ImageQuality>(
                  segments: const [
                    ButtonSegment(label: Text('高'), value: ImageQuality.high),
                    ButtonSegment(label: Text('中'), value: ImageQuality.medium),
                    ButtonSegment(label: Text('低'), value: ImageQuality.low),
                  ],
                  selected: {imageQuality},
                  onSelectionChanged: (selected) {
                    ref.read(imageQualityProvider.notifier).state = selected.first;
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  '存储',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('清空所有照片'),
                  subtitle: const Text('删除所有已保存的照片'),
                  trailing: const Icon(Icons.delete),
                  onTap: () => _showClearConfirmation(context, ref),
                ),
                const SizedBox(height: 32),
                const Text(
                  '关于',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const ListTile(
                  title: Text('相机应用'),
                  subtitle: Text('版本 1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空所有照片'),
        content: const Text('确定要删除所有照片吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await FileManager.clearAllPhotos();
              if (dialogContext.mounted) {
                // ignore: unused_result
                ref.refresh(galleryPhotosProvider);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('所有照片已删除')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
