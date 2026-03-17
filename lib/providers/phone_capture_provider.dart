import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../models/phone_capture_model.dart';

/// 手机部位信息提供者
final phoneSideInfoProvider = Provider<Map<PhoneSide, PhoneSideInfo>>((ref) {
  return {
    PhoneSide.front: const PhoneSideInfo(
      side: PhoneSide.front,
      label: '正面',
      description: '请对准手机屏幕，确保整个屏幕在框内',
      imagePath: 'assets/phone_front.png',
    ),
    PhoneSide.back: const PhoneSideInfo(
      side: PhoneSide.back,
      label: '背面',
      description: '请对准手机背面，确保整个背面在框内',
      imagePath: 'assets/phone_back.png',
    ),
    PhoneSide.left: const PhoneSideInfo(
      side: PhoneSide.left,
      label: '左侧面',
      description: '请对准手机左侧边框，确保整个侧面在框内',
      imagePath: 'assets/phone_left.png',
    ),
    PhoneSide.right: const PhoneSideInfo(
      side: PhoneSide.right,
      label: '右侧面',
      description: '请对准手机右侧边框，确保整个侧面在框内',
      imagePath: 'assets/phone_right.png',
    ),
  };
});

/// 手机拍照会话状态管理
class PhoneCaptureNotifier extends StateNotifier<PhoneCaptureSession?> {
  PhoneCaptureNotifier() : super(null);

  /// 启动新的拍照会话
  void startNewSession() {
    state = PhoneCaptureSession(
      sessionId: const Uuid().v4(),
      createdAt: DateTime.now(),
      capturedPhotos: {
        PhoneSide.front: null,
        PhoneSide.back: null,
        PhoneSide.left: null,
        PhoneSide.right: null,
      },
      currentStep: PhoneSide.front,
      isCompleted: false,
    );
  }

  /// 更新指定部位的拍照
  void updatePhotoForSide(PhoneSide side, String? filePath) {
    if (state == null) return;

    final updatedPhotos = Map<PhoneSide, String?>.from(state!.capturedPhotos);
    updatedPhotos[side] = filePath;

    // 获取下一个未拍照的部位
    PhoneSide nextStep = side;
    for (final s in PhoneSide.values) {
      if (updatedPhotos[s] == null) {
        nextStep = s;
        break;
      }
    }

    final isCompleted = updatedPhotos.values.every((p) => p != null);

    state = PhoneCaptureSession(
      sessionId: state!.sessionId,
      createdAt: state!.createdAt,
      capturedPhotos: updatedPhotos,
      currentStep: nextStep,
      isCompleted: isCompleted,
    );
  }

  /// 重置会话
  void resetSession() {
    state = null;
  }
}

final phoneCaptureProvider =
    StateNotifierProvider<PhoneCaptureNotifier, PhoneCaptureSession?>((ref) {
      return PhoneCaptureNotifier();
    });
