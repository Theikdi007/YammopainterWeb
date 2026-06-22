import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes/app_routes.dart';
import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();

  final RxBool isLoading = false.obs;
  final RxBool loggedIn = false.obs;
  final RxString email = ''.obs;

  StreamSubscription<AuthState>? _authSub;

  @override
  void onInit() {
    loggedIn.value = _service.isLoggedIn;
    email.value = _service.currentEmail;

    // In real mode, react to auth changes so the UI stays in sync with the
    // Supabase session (token refresh, sign-out from another tab, etc.).
    if (SupabaseConfig.isReady) {
      _authSub = SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        loggedIn.value = session != null;
        email.value = session?.user.email ?? '';
        switch (data.event) {
          case AuthChangeEvent.signedIn:
            if (Get.currentRoute != AppRoutes.home) {
              Get.offAllNamed<void>(AppRoutes.home);
            }
          case AuthChangeEvent.signedOut:
            if (Get.currentRoute != AppRoutes.login) {
              Get.offAllNamed<void>(AppRoutes.login);
            }
          default:
            break;
        }
      });
    }
    super.onInit();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  Future<void> signIn(String emailInput, String password) async {
    isLoading.value = true;
    try {
      await _service.signIn(emailInput, password);
      loggedIn.value = true;
      email.value = _service.currentEmail;
      Get.offAllNamed<void>(AppRoutes.home);
    } catch (e) {
      showError(friendlyError(e), title: 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String emailInput, String password) async {
    isLoading.value = true;
    try {
      await _service.signUp(emailInput, password);
      loggedIn.value = _service.isLoggedIn;
      email.value = _service.currentEmail;
      showSuccess('Account created. You are signed in.');
      Get.offAllNamed<void>(AppRoutes.home);
    } catch (e) {
      showError(friendlyError(e), title: 'Sign up failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordReset(String emailInput) async {
    isLoading.value = true;
    try {
      await _service.sendPasswordReset(emailInput);
      showSuccess('Password reset link sent to $emailInput.');
      Get.back<void>();
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    loggedIn.value = false;
    email.value = '';
    Get.offAllNamed<void>(AppRoutes.login);
  }
}
