import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/scanner_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  final Function(String)? onScanComplete;
  final String? title;
  final bool autoClose;

  const ScannerScreen({
    super.key,
    this.onScanComplete,
    this.title,
    this.autoClose = true,
  });

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late MobileScannerController controller;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isProcessing = false;

  // 扫描框尺寸
  static const double scanBoxWidth = 300;
  static const double scanBoxHeight = 60;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionTimeoutMs: 1000,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;

      // 只处理条形码格式（1D码）
      if (code != null && _isBarcodeFormat(barcode.format)) {
        _isProcessing = true;

        ref
            .read(scannerProvider.notifier)
            .addScanResult(code, format: barcode.format.name);

        widget.onScanComplete?.call(code);

        if (widget.autoClose && mounted) {
          Future.microtask(() {
            if (mounted) {
              Navigator.pop(context, code);
            }
          });
        }
        break;
      }
    }
  }

  /// 判断是否为条形码格式（1D码）
  bool _isBarcodeFormat(BarcodeFormat format) {
    final barcodeFormats = [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
    ];
    return barcodeFormats.contains(format);
  }

  Future<void> _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _switchCamera() async {
    await controller.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanBoxTop = (screenSize.height - scanBoxHeight) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '扫描条形码'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      '扫码出错: ${error.errorCode}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          ),
          // 半透明遮罩层 - 上方
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: scanBoxTop,
            child: Container(color: Colors.black.withValues(alpha: 1)),
          ),
          // 半透明遮罩层 - 下方
          Positioned(
            top: scanBoxTop + scanBoxHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(color: Colors.black.withValues(alpha: 1)),
          ),
          // 半透明遮罩层 - 左方
          Positioned(
            top: scanBoxTop,
            left: 0,
            width: (screenSize.width - scanBoxWidth) / 2,
            height: scanBoxHeight,
            child: Container(color: Colors.black.withValues(alpha: 1)),
          ),
          // 半透明遮罩层 - 右方
          Positioned(
            top: scanBoxTop,
            right: 0,
            width: (screenSize.width - scanBoxWidth) / 2,
            height: scanBoxHeight,
            child: Container(color: Colors.black.withValues(alpha: 1)),
          ),
          // 扫描框 - 300x60 的条形码扫描框
          Positioned(
            top: scanBoxTop,
            left: (screenSize.width - scanBoxWidth) / 2,
            width: scanBoxWidth,
            height: scanBoxHeight,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // 左上角
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 3),
                          left: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // 右上角
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.green, width: 3),
                          right: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // 左下角
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 3),
                          left: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                  // 右下角
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.green, width: 3),
                          right: BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 底部提示文字
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '将条形码放入框内',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 底部控制按钮
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'scanner_flash',
                  onPressed: _toggleFlash,
                  backgroundColor: _isFlashOn ? Colors.yellow : Colors.grey,
                  child: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'scanner_camera',
                  onPressed: _switchCamera,
                  backgroundColor: Colors.blue,
                  child: const Icon(
                    Icons.flip_camera_android,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
