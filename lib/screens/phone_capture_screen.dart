import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相机权限被拒绝')),
      );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentSideInfo = sideInfoMap[captureSession.currentStep]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('手机轮廓拍照'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(phoneCaptureProvider.notifier).resetSession();
            context.pop();
          },
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
                  // 相机预览
                  CameraPreview(cameraController),
                  // 手机轮廓叠加层
                  PhoneOutlineOverlay(
                    side: captureSession.currentStep,
                    isHighlighted: true,
                  ),
                  // 顶部：步骤指示器
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: CaptureStepIndicator(
                      capturedPhotos: captureSession.capturedPhotos,
                      currentStep: captureSession.currentStep,
                    ),
                  ),
                  // 中间：当前步骤提示
                  Positioned(
                    top: 120,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '请拍摄手机${currentSideInfo.label}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // 底部：控制按钮
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
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
                              Icons.camera,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 完成按钮（仅在所有部位都拍照后显示）
                        if (captureSession.isAllCaptured)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: SizedBox(
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
                          ),
                      ],
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

  Future<void> _takePicture(
    CameraController controller,
    PhoneSide side,
  ) async {
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
          final nextSideInfo = ref.read(phoneSideInfoProvider)[session.currentStep];
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
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
}
