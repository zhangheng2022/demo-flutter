import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../providers/camera_provider.dart';
import '../providers/gallery_provider.dart';
import '../utils/permissions.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  late Future<bool> _permissionFuture;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermission();
  }

  Future<bool> _checkPermission() async {
    final hasPermission = await PermissionManager.requestCameraPermission();
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('相机权限被拒绝')));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
    }
    return hasPermission;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider);
    final cameras = ref.watch(availableCamerasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('相机'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<bool>(
        future: _permissionFuture,
        builder: (context, permissionSnapshot) {
          if (permissionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!permissionSnapshot.hasData || !permissionSnapshot.data!) {
            return const Center(child: Text('权限检查中...'));
          }

          return cameras.when(
            data: (cameraList) {
              if (cameraController == null) {
                // 初始化相机 - 只初始化一次
                if (!_isInitialized && cameraList.isNotEmpty && mounted) {
                  _isInitialized = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ref
                          .read(cameraControllerProvider.notifier)
                          .initializeCamera(cameraList[0]);
                    }
                  });
                }
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  CameraPreview(cameraController),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (cameraList.length > 1)
                          FloatingActionButton(
                            heroTag: 'switch_camera',
                            mini: true,
                            onPressed: () => _switchCamera(cameraList),
                            child: const Icon(Icons.flip_camera_android),
                          ),
                        FloatingActionButton(
                          heroTag: 'toggle_flash',
                          mini: true,
                          onPressed: () => ref
                              .read(cameraControllerProvider.notifier)
                              .toggleFlash(),
                          child: const Icon(Icons.flash_on),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        heroTag: 'take_picture',
                        onPressed: () => _takePicture(),
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.camera, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('错误: $error')),
          );
        },
      ),
    );
  }

  void _switchCamera(List<CameraDescription> cameras) {
    final currentIndex = ref.read(currentCameraIndexProvider);
    final nextIndex = (currentIndex + 1) % cameras.length;
    ref.read(currentCameraIndexProvider.notifier).state = nextIndex;
    ref
        .read(cameraControllerProvider.notifier)
        .switchCamera(cameras[nextIndex]);
  }

  Future<void> _takePicture() async {
    final filePath = await ref
        .read(cameraControllerProvider.notifier)
        .takePicture();
    if (filePath != null && mounted) {
      ref.invalidate(galleryPhotosProvider);
      _showPreview(filePath);
    }
  }

  void _showPreview(String filePath) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('照片已保存'),
        content: const Text('您的照片已保存到相册。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('重新拍摄'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) {
                context.pop();
              }
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
}
