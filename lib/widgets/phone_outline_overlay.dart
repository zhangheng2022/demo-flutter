import 'package:flutter/material.dart';
import '../models/phone_capture_model.dart';

class PhoneOutlineOverlay extends StatelessWidget {
  final PhoneSide side;
  final bool isHighlighted;

  const PhoneOutlineOverlay({
    super.key,
    required this.side,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PhoneOutlinePainter(
        side: side,
        isHighlighted: isHighlighted,
      ),
      child: Container(),
    );
  }
}

class PhoneOutlinePainter extends CustomPainter {
  final PhoneSide side;
  final bool isHighlighted;

  PhoneOutlinePainter({
    required this.side,
    required this.isHighlighted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isHighlighted ? Colors.green.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final highlightPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 手机宽高比例（标准手机）
    final phoneWidth = size.width * 0.6;
    final phoneHeight = size.height * 0.85;
    final cornerRadius = 20.0;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: phoneWidth,
      height: phoneHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // 绘制手机轮廓
    canvas.drawRRect(rrect, paint);

    // 根据当前部位高亮显示
    switch (side) {
      case PhoneSide.front:
        // 正面：整个屏幕区域
        final screenRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: phoneWidth * 0.9,
          height: phoneHeight * 0.8,
        );
        canvas.drawRect(screenRect, highlightPaint);
        break;

      case PhoneSide.back:
        // 背面：整个背面
        canvas.drawRRect(rrect, highlightPaint);
        break;

      case PhoneSide.left:
        // 左侧面：左边框
        final leftEdge = rect.left;
        final leftRect = Rect.fromLTWH(
          leftEdge - 5,
          rect.top,
          10,
          rect.height,
        );
        canvas.drawRect(leftRect, highlightPaint);
        break;

      case PhoneSide.right:
        // 右侧面：右边框
        final rightEdge = rect.right;
        final rightRect = Rect.fromLTWH(
          rightEdge - 5,
          rect.top,
          10,
          rect.height,
        );
        canvas.drawRect(rightRect, highlightPaint);
        break;
    }

    // 绘制四个角的标记点
    _drawCornerMarkers(canvas, rrect);
  }

  void _drawCornerMarkers(Canvas canvas, RRect rrect) {
    final markerPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    const markerSize = 8.0;
    final rect = rrect.outerRect;
    final corners = [
      Offset(rect.topLeft.dx, rect.topLeft.dy),
      Offset(rect.topRight.dx, rect.topRight.dy),
      Offset(rect.bottomLeft.dx, rect.bottomLeft.dy),
      Offset(rect.bottomRight.dx, rect.bottomRight.dy),
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, markerSize, markerPaint);
    }
  }

  @override
  bool shouldRepaint(PhoneOutlinePainter oldDelegate) {
    return oldDelegate.side != side || oldDelegate.isHighlighted != isHighlighted;
  }
}
