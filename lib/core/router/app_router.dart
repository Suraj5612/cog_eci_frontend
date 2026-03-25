import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ocr/screens/image_preview_screen.dart';
import '../../features/voter/screens/voter_details_screen.dart';
import '../../features/voter/screens/voter_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    GoRoute(
      path: '/preview',
      builder: (context, state) {
        final imagePath = state.extra as String;
        return ImagePreviewScreen(imagePath: imagePath);
      },
    ),

    GoRoute(
      path: '/voter-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        return VoterDetailsScreen(
          imagePath: extra['imagePath'],
          ocrData: extra['data'],
        );
      },
    ),

    GoRoute(
      path: '/voters',
      builder: (context, state) => const VoterListScreen(),
    ),
  ],
);
