import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoCount = ref.watch(photoCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('相机应用'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            const Text(
              '欢迎使用相机应用',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            _buildNavButton(
              context,
              label: '拍照',
              icon: Icons.camera,
              onPressed: () => context.push('/camera'),
            ),
            const SizedBox(height: 16),
            _buildNavButton(
              context,
              label: '手机轮廓拍照',
              icon: Icons.phone_android,
              onPressed: () => context.push('/phone-capture'),
            ),
            const SizedBox(height: 16),
            _buildNavButton(
              context,
              label: '相册',
              icon: Icons.photo_library,
              onPressed: () => context.push('/gallery'),
            ),
            const SizedBox(height: 16),
            _buildNavButton(
              context,
              label: '设置',
              icon: Icons.settings,
              onPressed: () => context.push('/settings'),
            ),
            const SizedBox(height: 48),
            photoCount.when(
              data: (count) => Text(
                '照片数: $count',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => const Text('加载照片出错'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
