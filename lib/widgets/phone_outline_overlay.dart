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
      painter: PhoneOutlinePainter(side: side, isHighlighted: isHighlighted),
      child: Container(),
    );
  }
}

class PhoneOutlinePainter extends CustomPainter {
  final PhoneSide side;
  final bool isHighlighted;

  PhoneOutlinePainter({required this.side, required this.isHighlighted});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.35; // 改为靠近顶部

    // iPhone 16 宽高比例和设计参数
    final phoneWidth = size.width * 0.6;
    final phoneHeight = size.height * 0.65;
    final cornerRadius = 40.0; // iPhone 16 更大的圆角

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: phoneWidth,
      height: phoneHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // 根据当前部位绘制不同的轮廓
    switch (side) {
      case PhoneSide.front:
        _drawFrontView(canvas, rect, rrect, phoneWidth, phoneHeight);
        break;

      case PhoneSide.back:
        _drawBackView(canvas, rect, rrect, phoneWidth, phoneHeight);
        break;

      case PhoneSide.left:
        _drawLeftView(canvas, rect, rrect, phoneWidth, phoneHeight);
        break;

      case PhoneSide.right:
        _drawRightView(canvas, rect, rrect, phoneWidth, phoneHeight);
        break;

      case PhoneSide.bottom:
        _drawBottomView(canvas, rect, rrect, phoneWidth, phoneHeight);
        break;
    }
  }

  void _drawFrontView(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制手机轮廓（主边框）
    final mainOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(rrect, mainOutlinePaint);

    // 绘制手机轮廓阴影（增加深度感）
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(rrect, shadowPaint);

    // 绘制手机细节
    _drawScreenBorder(canvas, rect, phoneWidth, phoneHeight);
    _drawDynamicIsland(canvas, rect, phoneWidth, phoneHeight);
    _drawSpeaker(canvas, rect, phoneWidth, phoneHeight);
    _drawHomeIndicator(canvas, rect, phoneWidth, phoneHeight);
    _drawSideButtons(canvas, rect, phoneHeight);
    _drawMicrophone(canvas, rect, phoneWidth, phoneHeight);
  }

  void _drawBackView(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制手机轮廓（主边框）
    final mainOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(rrect, mainOutlinePaint);

    // 绘制手机轮廓阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(rrect, shadowPaint);

    // 绘制背面细节
    _drawCameraModule(canvas, rect, phoneWidth, phoneHeight);
    _drawAppleLogo(canvas, rect, phoneWidth, phoneHeight);
    _drawBackGlassArea(canvas, rect, phoneWidth, phoneHeight);
  }

  void _drawLeftView(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 侧面视图：从左侧看手机
    // 绘制侧面轮廓（更窄的矩形）
    final sideWidth = phoneWidth * 0.15;
    final sideHeight = phoneHeight;
    final sideLeft = rect.center.dx - sideWidth / 2;
    final sideTop = rect.top;

    final sideRect = Rect.fromLTWH(sideLeft, sideTop, sideWidth, sideHeight);
    final sideRRect = RRect.fromRectAndRadius(sideRect, Radius.circular(40.0));

    // 绘制侧面轮廓
    final mainOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(sideRRect, mainOutlinePaint);

    // 绘制手机轮廓阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(sideRRect, shadowPaint);

    // 绘制左侧细节
    _drawLeftSideDetails(canvas, sideRect, sideWidth, sideHeight);
  }

  void _drawRightView(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 侧面视图：从右侧看手机
    // 绘制侧面轮廓（更窄的矩形）
    final sideWidth = phoneWidth * 0.15;
    final sideHeight = phoneHeight;
    final sideLeft = rect.center.dx - sideWidth / 2;
    final sideTop = rect.top;

    final sideRect = Rect.fromLTWH(sideLeft, sideTop, sideWidth, sideHeight);
    final sideRRect = RRect.fromRectAndRadius(sideRect, Radius.circular(40.0));

    // 绘制侧面轮廓
    final mainOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(sideRRect, mainOutlinePaint);

    // 绘制手机轮廓阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(sideRRect, shadowPaint);

    // 绘制右侧细节
    _drawRightSideDetails(canvas, sideRect, sideWidth, sideHeight);
  }

  void _drawBottomView(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 底部视图：从下方看手机
    // 绘制底部轮廓（更窄的矩形）
    final bottomHeight = phoneHeight * 0.15;
    final bottomWidth = phoneWidth;
    final bottomLeft = rect.left;
    final bottomTop = rect.center.dy - bottomHeight / 2;

    final bottomRect = Rect.fromLTWH(bottomLeft, bottomTop, bottomWidth, bottomHeight);
    final bottomRRect = RRect.fromRectAndRadius(bottomRect, Radius.circular(40.0));

    // 绘制底部轮廓
    final mainOutlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(bottomRRect, mainOutlinePaint);

    // 绘制手机轮廓阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(bottomRRect, shadowPaint);

    // 绘制底部细节
    _drawBottomDetails(canvas, bottomRect, bottomWidth, bottomHeight);
  }

  void _drawBottomDetails(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制底部扬声器孔
    final speakerPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;

    final speakerWidth = phoneWidth * 0.25;
    final speakerHeight = phoneHeight * 0.15;
    final speakerLeft = rect.center.dx - speakerWidth / 2;
    final speakerTop = rect.center.dy - speakerHeight / 2;

    final speakerRect = Rect.fromLTWH(
      speakerLeft,
      speakerTop,
      speakerWidth,
      speakerHeight,
    );
    final speakerRRect = RRect.fromRectAndRadius(
      speakerRect,
      Radius.circular(speakerHeight / 2),
    );

    canvas.drawRRect(speakerRRect, speakerPaint);

    // 绘制充电口
    final chargingPaint = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..style = PaintingStyle.fill;

    final chargingWidth = phoneWidth * 0.15;
    final chargingHeight = phoneHeight * 0.25;
    final chargingLeft = rect.center.dx - chargingWidth / 2;
    final chargingTop = rect.center.dy - chargingHeight / 2;

    final chargingRect = Rect.fromLTWH(
      chargingLeft,
      chargingTop,
      chargingWidth,
      chargingHeight,
    );
    final chargingRRect = RRect.fromRectAndRadius(
      chargingRect,
      Radius.circular(4),
    );

    canvas.drawRRect(chargingRRect, chargingPaint);

    // 绘制充电口边框
    final chargingBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(chargingRRect, chargingBorderPaint);

    // 绘制底部边框线
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(rect, edgePaint);
  }

  void _drawScreenBorder(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final borderPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 屏幕边框（内部边界）
    final screenInset = phoneWidth * 0.05;
    final screenRect = Rect.fromLTRB(
      rect.left + screenInset,
      rect.top + screenInset,
      rect.right - screenInset,
      rect.bottom - screenInset,
    );
    canvas.drawRect(screenRect, borderPaint);
  }

  void _drawNotch(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final notchPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // 刘海尺寸
    final notchWidth = phoneWidth * 0.35;
    final notchHeight = phoneHeight * 0.1;
    final notchRadius = notchHeight / 2;

    final notchLeft = rect.center.dx - notchWidth / 2;
    final notchTop = rect.top + phoneHeight * 0.015;

    final notchRect = Rect.fromLTWH(
      notchLeft,
      notchTop,
      notchWidth,
      notchHeight,
    );
    final notchRRect = RRect.fromRectAndRadius(
      notchRect,
      Radius.circular(notchRadius),
    );

    canvas.drawRRect(notchRRect, notchPaint);

    // 绘制刘海边框
    final notchBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(notchRRect, notchBorderPaint);
  }

  void _drawCameraHole(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final holePaint = Paint()
      ..color = const Color(0xFF0a0a0a)
      ..style = PaintingStyle.fill;

    // 摄像头孔洞
    final holeRadius = phoneWidth * 0.025;
    final holeCenterX = rect.center.dx;
    final holeCenterY = rect.top + phoneHeight * 0.065;

    canvas.drawCircle(Offset(holeCenterX, holeCenterY), holeRadius, holePaint);

    // 绘制孔洞边框
    final holeBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(
      Offset(holeCenterX, holeCenterY),
      holeRadius,
      holeBorderPaint,
    );
  }

  void _drawDynamicIsland(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final islandPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // iPhone 16 Dynamic Island - 更小更精致的胶囊形
    final islandWidth = phoneWidth * 0.22;
    final islandHeight = phoneHeight * 0.045;
    final islandRadius = islandHeight / 2;

    final islandLeft = rect.center.dx - islandWidth / 2;
    final islandTop = rect.top + phoneHeight * 0.012;

    final islandRect = Rect.fromLTWH(
      islandLeft,
      islandTop,
      islandWidth,
      islandHeight,
    );
    final islandRRect = RRect.fromRectAndRadius(
      islandRect,
      Radius.circular(islandRadius),
    );

    canvas.drawRRect(islandRRect, islandPaint);

    // 绘制 Dynamic Island 边框
    final islandBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(islandRRect, islandBorderPaint);
  }

  void _drawCameraModule(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // iPhone 16 后置摄像头模块（方形）
    final moduleSize = phoneWidth * 0.28;
    final moduleLeft = rect.left + phoneWidth * 0.08;
    final moduleTop = rect.top + phoneHeight * 0.06;

    // 摄像头模块背景
    final modulePaint = Paint()
      ..color = const Color(0xFF1a1a1a)
      ..style = PaintingStyle.fill;

    final moduleRect = Rect.fromLTWH(
      moduleLeft,
      moduleTop,
      moduleSize,
      moduleSize,
    );
    final moduleRRect = RRect.fromRectAndRadius(
      moduleRect,
      Radius.circular(12),
    );
    canvas.drawRRect(moduleRRect, modulePaint);

    // 摄像头模块边框
    final moduleBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(moduleRRect, moduleBorderPaint);

    // 绘制两个摄像头孔洞
    final cameraRadius = phoneWidth * 0.038;
    final camera1X = moduleLeft + moduleSize * 0.35;
    final camera1Y = moduleTop + moduleSize * 0.35;
    final camera2X = moduleLeft + moduleSize * 0.65;
    final camera2Y = moduleTop + moduleSize * 0.65;

    final cameraPaint = Paint()
      ..color = const Color(0xFF0a0a0a)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(camera1X, camera1Y), cameraRadius, cameraPaint);
    canvas.drawCircle(Offset(camera2X, camera2Y), cameraRadius, cameraPaint);

    // 摄像头孔洞边框
    final cameraBorderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawCircle(
      Offset(camera1X, camera1Y),
      cameraRadius,
      cameraBorderPaint,
    );
    canvas.drawCircle(
      Offset(camera2X, camera2Y),
      cameraRadius,
      cameraBorderPaint,
    );
  }

  void _drawSpeaker(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final speakerPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;

    // 扬声器孔
    final speakerWidth = phoneWidth * 0.25;
    final speakerHeight = phoneHeight * 0.008;
    final speakerLeft = rect.center.dx - speakerWidth / 2;
    final speakerTop = rect.top + phoneHeight * 0.025;

    final speakerRect = Rect.fromLTWH(
      speakerLeft,
      speakerTop,
      speakerWidth,
      speakerHeight,
    );
    final speakerRRect = RRect.fromRectAndRadius(
      speakerRect,
      Radius.circular(speakerHeight / 2),
    );

    canvas.drawRRect(speakerRRect, speakerPaint);
  }

  void _drawMicrophone(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final micPaint = Paint()
      ..color = const Color(0xFF222222)
      ..style = PaintingStyle.fill;

    // 底部麦克风孔
    final micWidth = phoneWidth * 0.15;
    final micHeight = phoneHeight * 0.006;
    final micLeft = rect.center.dx - micWidth / 2;
    final micTop = rect.bottom - phoneHeight * 0.035;

    final micRect = Rect.fromLTWH(micLeft, micTop, micWidth, micHeight);
    final micRRect = RRect.fromRectAndRadius(
      micRect,
      Radius.circular(micHeight / 2),
    );

    canvas.drawRRect(micRRect, micPaint);
  }

  void _drawHomeIndicator(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    final indicatorPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.fill;

    // Home Indicator（底部导航条）
    final indicatorWidth = phoneWidth * 0.35;
    final indicatorHeight = phoneHeight * 0.012;
    final indicatorLeft = rect.center.dx - indicatorWidth / 2;
    final indicatorTop = rect.bottom - phoneHeight * 0.05;

    final indicatorRect = Rect.fromLTWH(
      indicatorLeft,
      indicatorTop,
      indicatorWidth,
      indicatorHeight,
    );
    final indicatorRRect = RRect.fromRectAndRadius(
      indicatorRect,
      Radius.circular(indicatorHeight / 2),
    );

    canvas.drawRRect(indicatorRRect, indicatorPaint);
  }

  void _drawSideButtons(Canvas canvas, Rect rect, double phoneHeight) {
    final buttonPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;

    const buttonWidth = 2.5;
    final buttonHeight = phoneHeight * 0.12;
    const buttonSpacing = 18.0;

    // 左侧按键
    final leftX = rect.left - 3.5;
    final topButtonY = rect.top + phoneHeight * 0.25;
    final middleButtonY = topButtonY + buttonHeight + buttonSpacing;
    final bottomButtonY = middleButtonY + buttonHeight + buttonSpacing;

    // 绘制左侧三个按键
    canvas.drawRect(
      Rect.fromLTWH(leftX, topButtonY, buttonWidth, buttonHeight),
      buttonPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(leftX, middleButtonY, buttonWidth, buttonHeight),
      buttonPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(leftX, bottomButtonY, buttonWidth, buttonHeight),
      buttonPaint,
    );

    // 右侧按键（通常只有一个）
    final rightX = rect.right + 1;
    final rightButtonY = rect.top + phoneHeight * 0.35;
    canvas.drawRect(
      Rect.fromLTWH(rightX, rightButtonY, buttonWidth, buttonHeight * 1.2),
      buttonPaint,
    );
  }

  void _drawAppleLogo(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制 Apple Logo
    final logoPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final logoSize = phoneWidth * 0.08;
    final logoCenterX = rect.center.dx;
    final logoCenterY = rect.center.dy - phoneHeight * 0.15;

    // 简化的 Apple Logo（圆形）
    canvas.drawCircle(Offset(logoCenterX, logoCenterY), logoSize, logoPaint);
  }

  void _drawBackGlassArea(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制背面玻璃区域的边框
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final glassInset = phoneWidth * 0.08;
    final glassRect = Rect.fromLTRB(
      rect.left + glassInset,
      rect.top + glassInset,
      rect.right - glassInset,
      rect.bottom - glassInset,
    );

    canvas.drawRect(glassRect, glassPaint);
  }

  void _drawLeftSideDetails(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制左侧视图的细节
    // 绘制音量按键
    final buttonPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;

    const buttonWidth = 2.0;
    final buttonHeight = phoneHeight * 0.08;
    const buttonSpacing = 10.0;

    final buttonX = rect.left + phoneWidth * 0.3;
    final topButtonY = rect.top + phoneHeight * 0.25;
    final bottomButtonY = topButtonY + buttonHeight + buttonSpacing;

    // 绘制两个音量按键
    canvas.drawRect(
      Rect.fromLTWH(buttonX, topButtonY, buttonWidth, buttonHeight),
      buttonPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(buttonX, bottomButtonY, buttonWidth, buttonHeight),
      buttonPaint,
    );

    // 绘制侧面边框线
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(rect, edgePaint);
  }

  void _drawRightSideDetails(
    Canvas canvas,
    Rect rect,
    double phoneWidth,
    double phoneHeight,
  ) {
    // 绘制右侧视图的细节
    // 绘制电源按键
    final buttonPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;

    const buttonWidth = 2.0;
    final buttonHeight = phoneHeight * 0.12;

    final buttonX = rect.left + phoneWidth * 0.3;
    final buttonY = rect.top + phoneHeight * 0.35;

    // 绘制电源按键
    canvas.drawRect(
      Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight),
      buttonPaint,
    );

    // 绘制侧面边框线
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(rect, edgePaint);
  }

  @override
  bool shouldRepaint(PhoneOutlinePainter oldDelegate) {
    return oldDelegate.side != side ||
        oldDelegate.isHighlighted != isHighlighted;
  }
}
