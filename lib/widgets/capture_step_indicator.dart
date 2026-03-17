import 'package:flutter/material.dart';
import '../models/phone_capture_model.dart';

class CaptureStepIndicator extends StatelessWidget {
  final Map<PhoneSide, String?> capturedPhotos;
  final PhoneSide currentStep;

  const CaptureStepIndicator({
    super.key,
    required this.capturedPhotos,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: PhoneSide.values.map((side) {
          final isCompleted = capturedPhotos[side] != null;
          final isCurrent = side == currentStep;

          return _buildStepItem(
            label: _getSideLabel(side),
            isCompleted: isCompleted,
            isCurrent: isCurrent,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepItem({
    required String label,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      icon = Icons.check;
    } else if (isCurrent) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      icon = Icons.camera;
    } else {
      backgroundColor = Colors.grey;
      textColor = Colors.white;
      icon = Icons.circle_outlined;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getSideLabel(PhoneSide side) {
    switch (side) {
      case PhoneSide.front:
        return '正面';
      case PhoneSide.back:
        return '背面';
      case PhoneSide.left:
        return '左侧';
      case PhoneSide.right:
        return '右侧';
    }
  }
}
