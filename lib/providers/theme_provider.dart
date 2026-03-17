import 'package:flutter_riverpod/legacy.dart';

enum ImageQuality { high, medium, low }

final imageQualityProvider = StateProvider<ImageQuality>(
  (ref) => ImageQuality.high,
);

final themeProvider = StateProvider<bool>(
  (ref) => false,
); // false = light, true = dark
