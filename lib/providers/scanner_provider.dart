import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// 扫码结果模型
class ScanResult {
  final String code;
  final DateTime scannedAt;
  final String? format;

  ScanResult({required this.code, required this.scannedAt, this.format});
}

/// 扫码配置
class ScannerConfig {
  final bool enableVibration;
  final bool enableSound;
  final bool enableAutoCapture;
  final Duration autoCaptureDuration;

  const ScannerConfig({
    this.enableVibration = true,
    this.enableSound = true,
    this.enableAutoCapture = false,
    this.autoCaptureDuration = const Duration(milliseconds: 500),
  });
}

/// 扫码状态
class ScannerState {
  final List<ScanResult> scannedCodes;
  final bool isScanning;
  final String? lastError;
  final ScannerConfig config;

  const ScannerState({
    this.scannedCodes = const [],
    this.isScanning = false,
    this.lastError,
    this.config = const ScannerConfig(),
  });

  ScannerState copyWith({
    List<ScanResult>? scannedCodes,
    bool? isScanning,
    String? lastError,
    ScannerConfig? config,
  }) {
    return ScannerState(
      scannedCodes: scannedCodes ?? this.scannedCodes,
      isScanning: isScanning ?? this.isScanning,
      lastError: lastError,
      config: config ?? this.config,
    );
  }
}

/// 扫码状态管理
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(const ScannerState());

  /// 添加扫码结果
  void addScanResult(String code, {String? format}) {
    final result = ScanResult(
      code: code,
      scannedAt: DateTime.now(),
      format: format,
    );

    state = state.copyWith(
      scannedCodes: [...state.scannedCodes, result],
      lastError: null,
    );
  }

  /// 清空扫码结果
  void clearResults() {
    state = state.copyWith(scannedCodes: []);
  }

  /// 删除指定的扫码结果
  void removeScanResult(int index) {
    if (index >= 0 && index < state.scannedCodes.length) {
      final updatedCodes = List<ScanResult>.from(state.scannedCodes);
      updatedCodes.removeAt(index);
      state = state.copyWith(scannedCodes: updatedCodes);
    }
  }

  /// 设置扫码状态
  void setScanning(bool isScanning) {
    state = state.copyWith(isScanning: isScanning);
  }

  /// 设置错误信息
  void setError(String? error) {
    state = state.copyWith(lastError: error);
  }

  /// 更新扫码配置
  void updateConfig(ScannerConfig config) {
    state = state.copyWith(config: config);
  }

  /// 重置状态
  void reset() {
    state = const ScannerState();
  }
}

/// 扫码 Provider
final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((
  ref,
) {
  return ScannerNotifier();
});

/// 获取最后一个扫码结果
final lastScanResultProvider = Provider<ScanResult?>((ref) {
  final state = ref.watch(scannerProvider);
  return state.scannedCodes.isEmpty ? null : state.scannedCodes.last;
});

/// 获取扫码结果数量
final scanResultCountProvider = Provider<int>((ref) {
  return ref.watch(scannerProvider).scannedCodes.length;
});
