import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'core/config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is optional — when missing or with placeholder values the app runs
  // in demo mode against in-memory data.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // ignore: app falls back to demo mode.
  }

  await SupabaseConfig.init();

  Get.put(ThemeController(), permanent: true);
  Get.put(AuthController(), permanent: true);

  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return GetMaterialApp(
      title: 'Yammo Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialRoute:
          auth.loggedIn.value ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
