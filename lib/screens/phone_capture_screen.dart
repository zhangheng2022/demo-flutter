import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../providers/camera_provider.dart';
import '../providers/phone_capture_provider.dart';
import '../models/phone_capture_model.dart';
import '../widgets/phone_outline_overlay.dart';
import '../widgets/capture_step_indicator.dart';
import '../utils/permissions.dart';

class PhoneCaptureScreen extends ConsumerStatefulWidget {
  const PhoneCaptureScreen({super.key});

  @override
  ConsumerState<PhoneCaptureScreen> createState() => _PhoneCaptureScreenState();
}

class _PhoneCaptureScreenState extends ConsumerState<PhoneCaptureScreen> {
  late Future<bool> _permissionFuture;
  bool _isInitialized = false;
  double _cameraZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermission();
    // 启动新的拍照会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(phoneCaptureProvider.notifier).startNewSession();
    });
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
  Widget build(BuildContext context) {
    final cameraController = ref.watch(cameraControllerProvider);
    final cameras = ref.watch(availableCamerasProvider);
    final captureSession = ref.watch(phoneCaptureProvider);
    final sideInfoMap = ref.watch(phoneSideInfoProvider);

    if (captureSession == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSideInfo = sideInfoMap[captureSession.currentStep]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('拍摄${currentSideInfo.label}'),
        backgroundColor: Colors.transparent,
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
                  // 相机预览（铺满整个页面）
                  Positioned.fill(child: CameraPreview(cameraController)),
                  // 手机轮廓叠加层
                  PhoneOutlineOverlay(
                    side: captureSession.currentStep,
                    isHighlighted: true,
                  ),
                  // 底部：步骤指示器、预览图和控制按钮
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 预览图
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  final sides = [
                                    PhoneSide.front,
                                    PhoneSide.back,
                                    PhoneSide.left,
                                    PhoneSide.right,
                                    PhoneSide.bottom,
                                  ];
                                  final side = sides[index];
                                  final photoPath =
                                      captureSession.capturedPhotos[side];
                                  final sideInfo = sideInfoMap[side]!;

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Stack(
                                      children: [
                                        // 预览图
                                        GestureDetector(
                                          onTapDown: (_) {
                                            // 点击预览图时显示全屏预览
                                            if (photoPath != null) {
                                              _showFullScreenPreview(
                                                context,
                                                photoPath,
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    captureSession
                                                            .currentStep ==
                                                        side
                                                    ? Colors.green
                                                    : Colors.grey,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                            child: photoPath != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: Image.file(
                                                      File(photoPath),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      sideInfo.label,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        // 删除按钮
                                        if (photoPath != null)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                ref
                                                    .read(
                                                      phoneCaptureProvider
                                                          .notifier,
                                                    )
                                                    .updatePhotoForSide(
                                                      side,
                                                      null,
                                                    );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 拍照按钮
                            Center(
                              child: FloatingActionButton(
                                heroTag: 'capture_phone',
                                onPressed: () => _takePicture(
                                  cameraController,
                                  captureSession.currentStep,
                                ),
                                backgroundColor: Colors.white,
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // 完成按钮（仅在所有部位都拍照后显示）
                            if (captureSession.isAllCaptured)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _completeCapture(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text(
                                    '完成拍照',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  Future<void> _takePicture(CameraController controller, PhoneSide side) async {
    try {
      final filePath = await ref
          .read(cameraControllerProvider.notifier)
          .takePicture();

      if (filePath != null && mounted) {
        // 更新拍照会话
        ref
            .read(phoneCaptureProvider.notifier)
            .updatePhotoForSide(side, filePath);

        // 显示简短的 Toast 提示
        final session = ref.read(phoneCaptureProvider);
        if (session != null && !session.isCompleted) {
          final nextSideInfo = ref.read(
            phoneSideInfoProvider,
          )[session.currentStep];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已保存，现在拍摄${nextSideInfo?.label}'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('拍照失败: $e')));
      }
    }
  }

  void _completeCapture() {
    final session = ref.read(phoneCaptureProvider);
    if (session != null && session.isAllCaptured) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('拍照完成'),
          content: const Text('所有部位拍照已完成！'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(phoneCaptureProvider.notifier).resetSession();
                context.pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      );
    }
  }

  void _showFullScreenPreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: _FullScreenImagePreview(imagePath: imagePath),
      ),
    );
  }
}

class _FullScreenImagePreview extends StatefulWidget {
  final String imagePath;

  const _FullScreenImagePreview({required this.imagePath});

  @override
  State<_FullScreenImagePreview> createState() =>
      _FullScreenImagePreviewState();
}

class _FullScreenImagePreviewState extends State<_FullScreenImagePreview> {
  late TransformationController _transformationController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 全屏图片预览
        InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          onInteractionEnd: (details) {
            setState(() {
              _scale = _transformationController.value.getMaxScaleOnAxis();
            });
          },
          child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
        ),
        // 关闭按钮
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
        ),
        // 缩放提示
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '缩放: ${(_scale * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
