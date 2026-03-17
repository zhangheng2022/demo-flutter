import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/gallery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/phone_capture_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/scan_results_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/camera', builder: (context, state) => const CameraScreen()),
    GoRoute(
      path: '/gallery',
      builder: (context, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/phone-capture',
      builder: (context, state) => const PhoneCaptureScreen(),
    ),
    GoRoute(
      path: '/scanner',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/scan-results',
      builder: (context, state) => const ScanResultsScreen(),
    ),
  ],
);
