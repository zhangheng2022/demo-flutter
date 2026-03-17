/// 手机部位枚举
enum PhoneSide {
  front,  // 正面
  back,   // 背面
  left,   // 左侧面
  right,  // 右侧面
}

/// 手机部位信息
class PhoneSideInfo {
  final PhoneSide side;
  final String label;
  final String description;
  final String imagePath;

  const PhoneSideInfo({
    required this.side,
    required this.label,
    required this.description,
    required this.imagePath,
  });
}

/// 手机拍照会话
class PhoneCaptureSession {
  final String sessionId;
  final DateTime createdAt;
  final Map<PhoneSide, String?> capturedPhotos; // side -> filePath
  final PhoneSide currentStep;
  final bool isCompleted;

  PhoneCaptureSession({
    required this.sessionId,
    required this.createdAt,
    required this.capturedPhotos,
    required this.currentStep,
    required this.isCompleted,
  });

  /// 获取已完成的拍照数量
  int get completedCount => capturedPhotos.values.where((p) => p != null).length;

  /// 获取总步骤数
  int get totalSteps => PhoneSide.values.length;

  /// 获取完成进度（0.0 - 1.0）
  double get progress => completedCount / totalSteps;

  /// 检查是否所有部位都已拍照
  bool get isAllCaptured => completedCount == totalSteps;

  /// 获取下一个需要拍照的部位
  PhoneSide? getNextSide() {
    for (final side in PhoneSide.values) {
      if (capturedPhotos[side] == null) {
        return side;
      }
    }
    return null;
  }
}
