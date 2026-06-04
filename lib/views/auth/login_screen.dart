import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kid_manager/background/auth_runtime_manager.dart';
import 'package:kid_manager/core/demo_feature_flags.dart';
import 'package:kid_manager/core/responsive.dart';
import 'package:kid_manager/core/validators.dart';
import 'package:kid_manager/helpers/json_helper.dart';
import 'package:kid_manager/helpers/mail_helper.dart';
import 'package:kid_manager/models/auth/auth_models.dart';
import 'package:kid_manager/models/login_session.dart';
import 'package:kid_manager/models/notifications/dialog_type.dart';
import 'package:kid_manager/models/user/user_types.dart';
import 'package:kid_manager/services/storage_service.dart';
import 'package:kid_manager/utils/runtime_l10n.dart';
import 'package:kid_manager/viewmodels/app_management_vm.dart';
import 'package:kid_manager/viewmodels/auth_vm.dart';
import 'package:kid_manager/viewmodels/otp_vm.dart';
import 'package:kid_manager/viewmodels/user_vm.dart';
import 'package:kid_manager/views/auth/dialog/phone_auth_dialog.dart';
import 'package:kid_manager/views/auth/forgot_pass_screen.dart';
import 'package:kid_manager/views/auth/otp_screen.dart';
import 'package:kid_manager/views/auth/signup_screen.dart';
import 'package:kid_manager/widgets/app/app_button.dart';
import 'package:kid_manager/widgets/app/app_notification_dialog.dart';
import 'package:kid_manager/widgets/auth/auth_text_field.dart';
import 'package:kid_manager/widgets/common/loading_view.dart';
import 'package:kid_manager/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kid_manager/core/storage_keys.dart';

import '../../core/alert_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool rememberPassword = false;

  String _resolveLoginErrorMessage(AppLocalizations l10n, String? errorKey) {
    switch (errorKey) {
      case 'accountNotFound':
        return l10n.accountNotFound;
      case 'accountNotActivated':
        return l10n.accountNotActivated;
      default:
        return l10n.authInvalidCredentials;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadRememberedLogin();
    });
  }

  Future<void> _onLoginPressed() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final l10n = AppLocalizations.of(context);
    final storage = context.read<StorageService>();
    final authVM = context.read<AuthVM>();
    final userVM = context.read<UserVm>();

    // Validate
    if (email.isEmpty || password.isEmpty) {
      AlertService.showSnack(l10n.authEnterAllInfo, isError: true);
      return;
    }

    if (!Validators.isValidEmail(email)) {
      AlertService.showSnack(l10n.emailInvalid, isError: true);
      return;
    }

    try {
      final cred = await authVM.login(email, password);
      if (!mounted) return;

      final uid = cred.user!.uid;

      // 🔥 lưu UID không cần await
      unawaited(storage.setString(StorageKeys.uid, uid));

      // Load profile
      final profile = await userVM.loadProfile(uid: uid, caller: 'LoginScreen');
      if (!mounted) return;
      if (profile == null) {
        await _showError(l10n.authUserProfileLoadFailed);
        return;
      }

      final role = profile.role;
      final parentId = role == UserRole.parent
          ? uid
          : (profile.parentUid ?? '').trim();

      // 🔥 lưu storage song song
      unawaited(
        Future.wait([
          storage.setString(StorageKeys.role, profile.roleKey),
          storage.setString(StorageKeys.displayName, profile.name),
          if (parentId.isNotEmpty)
            storage.setString(StorageKeys.parentId, parentId)
          else
            storage.remove(StorageKeys.parentId),
          if (profile.managedChildIds.isNotEmpty)
            storage.setStringList(
              StorageKeys.managedChildIds,
              profile.managedChildIds
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toSet()
                  .toList(),
            )
          else
            storage.remove(StorageKeys.managedChildIds),
        ]),
      );

      // remember login
      if (rememberPassword) {
        final session = LoginSession(email: email, uid: uid, remember: true);
        unawaited(
          storage.setString(
            StorageKeys.login_preference,
            JsonHelper.encode(session.toJson()),
          ),
        );
      } else {
        unawaited(storage.remove(StorageKeys.login_preference));
      }

      // xử lý role
      if (role == UserRole.child) {
        if (parentId.isEmpty) {
          await _showError(l10n.authUserProfileLoadFailed);
          return;
        }

        AuthRuntimeManager.start(parentId: parentId, displayName: profile.name);

        if (DemoFeatureFlags.appUsageEnabled) {
          final appVM = context.read<AppManagementVM>();
          await appVM.loadAndSeedApp();
          if (!mounted) return;
        }
      } else {
        unawaited(AuthRuntimeManager.stop());
      }

      FocusManager.instance.primaryFocus?.unfocus();
    } catch (e, st) {
      debugPrint('Login error: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;
      await _handleLoginError(e);
    }
  }

  Future<void> _handleLoginError(Object e) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final storage = context.read<StorageService>();
    final authVM = context.read<AuthVM>();

    if (authVM.error == "accountNotActivated") {
      final pending = await _getPendingOtp(storage);
      if (!mounted) return;

      if (pending != null) {
        final proceed = await _askVerifyNow(context);
        if (!mounted) return;

        if (proceed == true) {
          final otpVM = context.read<OtpVM>();

          await otpVM.requestFreshOtp(
            email: pending.email,
            type: MailType.verifyEmail,
          );
          if (!mounted) return;

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OtpScreen(email: pending.email, purpose: pending.purpose),
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    await NotificationDialog.show(
      context,
      type: DialogType.error,
      title: l10n.updateErrorTitle,
      message: _resolveLoginErrorMessage(l10n, authVM.error ?? e.toString()),
    );
  }

  Future<PendingOtp?> _getPendingOtp(StorageService storage) async {
    final raw = storage.getString(StorageKeys.pendingOtp);
    if (raw == null) return null;

    try {
      return PendingOtp.fromJson(JsonHelper.decode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<bool?> _askVerifyNow(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tài khoản chưa kích hoạt"),
        content: const Text("Bạn có muốn nhập OTP ngay không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Để sau"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xác thực ngay"),
          ),
        ],
      ),
    );
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    final l10n = runtimeL10n();
    await NotificationDialog.show(
      context,
      type: DialogType.error,
      title: l10n.updateErrorTitle,
      message: message,
    );
  }

  Future<void> _loadRememberedLogin() async {
    final storage = context.read<StorageService>();
    final raw = storage.getString(StorageKeys.login_preference);
    if (raw == null) return;

    try {
      final map = JsonHelper.decode(raw);
      final session = LoginSession.fromJson(map);

      if (!session.remember) return;
      if (!mounted) return;

      setState(() {
        _emailCtrl.text = session.email;
        rememberPassword = true;
      });
    } catch (e) {
      debugPrint('Failed to load login session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthVM>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final horizontalPadding = context.adaptiveHorizontalPadding(
      compact: 16,
      regular: 24,
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxContentWidth = constraints.maxWidth > 420
                      ? 420.0
                      : constraints.maxWidth;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    height: 203.40,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/icons/Illustration.svg',
                                        width: 203.40,
                                        height: 203.40,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 21),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 266,
                                    ),
                                    child: Text(
                                      l10n.authWelcomeBackTitle,
                                      textAlign: TextAlign.center,
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontSize: 24,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        height: 1.42,
                                        letterSpacing: -0.19,
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 266,
                                    ),
                                    child: Text(
                                      l10n.authLoginNowSubtitle,
                                      textAlign: TextAlign.center,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 21),
                              AuthTextField(
                                controller: _emailCtrl,
                                hintText: l10n.authEnterEmailHint,
                                keyboardType: TextInputType.emailAddress,
                                prefixSvg: 'assets/icons/user.svg',
                              ),
                              const SizedBox(height: 1),
                              AuthTextField(
                                controller: _passwordCtrl,
                                hintText: l10n.authEnterPasswordHint,
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                isPassword: true,
                                prefixSvg: 'assets/icons/lock.svg',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            rememberPassword =
                                                !rememberPassword;
                                          });
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                color: rememberPassword
                                                    ? colorScheme.primary
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  width: 2,
                                                  color: rememberPassword
                                                      ? colorScheme.primary
                                                      : colorScheme.outline,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                              child: rememberPassword
                                                  ? Icon(
                                                      Icons.check,
                                                      size: 12,
                                                      color:
                                                          colorScheme.onPrimary,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                l10n.authRememberPassword,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.5,
                                                      letterSpacing: -0.12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            l10n.authForgotPassword,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontSize: 12,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  letterSpacing: -0.12,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24.17),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 360,
                                ),
                                child: AppButton(
                                  height: 60,
                                  text: l10n.authLoginButton,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  onPressed: _onLoginPressed,
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 17),
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withValues(
                                        alpha: 0.4,
                                      ),
                                      thickness: 0.83,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      l10n.authOr,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontSize: 13,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: colorScheme.outline.withValues(
                                        alpha: 0.4,
                                      ),
                                      thickness: 0.83,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 17),
                              Row(
                                children: [
                                  Expanded(
                                    child: _socialBtn(
                                      'assets/icons/google.svg',
                                      () => vm.loginWithGoogle(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _socialBtn(
                                      'assets/icons/facebook.svg',
                                      () => vm.loginWithFacebook(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _socialBtn(
                                      'assets/icons/apple.svg',
                                      () => vm.loginWithApple(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _socialBtn(
                                      'assets/icons/mobile.svg',
                                      () => PhoneAuthDialog.showPhoneDialog(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    l10n.authNoAccount,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l10n.authSignUpInline,
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (vm.loading) const LoadingOverlay(),
      ],
    );
  }

  Widget _socialBtn(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEFF0F6)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: SvgPicture.asset(iconPath, width: 18, height: 18)),
      ),
    );
  }
}
