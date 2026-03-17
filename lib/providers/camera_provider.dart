import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final availableCamerasProvider = FutureProvider<List<CameraDescription>>((
  ref,
) async {
  return await availableCameras();
});

final cameraControllerProvider =
    StateNotifierProvider<CameraControllerNotifier, CameraController?>((ref) {
      return CameraControllerNotifier(ref);
    });

class CameraControllerNotifier extends StateNotifier<CameraController?> {
  CameraControllerNotifier(this.ref) : super(null);

  final Ref ref;

  Future<void> initializeCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    state = controller;
  }

  Future<void> setZoomLevel(double zoom) async {
    if (state == null) return;
    try {
      final maxZoom = await state!.getMaxZoomLevel();
      final minZoom = await state!.getMinZoomLevel();
      final clampedZoom = zoom.clamp(minZoom, maxZoom);
      await state!.setZoomLevel(clampedZoom);
    } catch (e) {
      debugPrint('Error setting zoom: $e');
    }
  }

  Future<String?> takePicture() async {
    if (state == null) return null;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${appDir.path}/photos');

      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${photoDir.path}/$timestamp.jpg';

      final xFile = await state!.takePicture();
      await xFile.saveTo(filePath);

      return filePath;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  void switchCamera(CameraDescription camera) async {
    await state?.dispose();
    await initializeCamera(camera);
  }

  Future<void> toggleFlash() async {
    if (state == null) return;
    final current = state!.value.flashMode;
    final next = current == FlashMode.off ? FlashMode.auto : FlashMode.off;
    await state!.setFlashMode(next);
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final currentCameraIndexProvider = StateProvider<int>((ref) => 0);

final flashModeProvider = StateProvider<FlashMode>((ref) => FlashMode.auto);
