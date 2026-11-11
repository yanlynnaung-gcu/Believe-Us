import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_auth_tab_switcher.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_google_sign_in_button.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_login_header.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_login_sign_in_tab.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_login_sign_up_tab.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _activeTabIndex = 0;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  String _selectedRole = 'BOYFRIEND';
  DateTime? _selectedBirthday;
  File? _pickedAvatarFile;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BelieveColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final file = await ref.read(mediaPickerServiceProvider).pickAndCropImage(
      context: context,
      cropType: CropType.circleAvatar,
      title: 'Choose Profile Photo ✨',
    );
    if (file != null) {
      setState(() => _pickedAvatarFile = file);
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _selectedBirthday ?? DateTime(now.year - 22, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: now,
      helpText: 'Select Your Birthday 🎂',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BelieveColors.primary,
              onPrimary: Colors.white,
              onSurface: BelieveColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  void _onLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );
    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      _showError(err ?? 'Login failed. Please check your credentials.');
    }
  }

  void _onRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty) {
      _showError('Please enter your romantic name or nickname.');
      return;
    }
    if (_selectedBirthday == null) {
      _showError('Please select your birthday date.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      email: email,
      password: password,
      displayName: name,
      role: _selectedRole,
      birthday: _selectedBirthday,
      avatarFile: _pickedAvatarFile,
    );

    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      _showError(err ?? 'Registration failed. Please try again.');
    }
  }

  void _onGoogleSignIn() async {
    final success = await ref.read(authControllerProvider.notifier).signInWithGoogle(
      role: _selectedRole,
      birthday: _selectedBirthday,
    );
    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      if (err != null) _showError(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const WdLoginHeader(),
              WdAuthTabSwitcher(
                activeIndex: _activeTabIndex,
                onTabSelected: (idx) => setState(() => _activeTabIndex = idx),
                tabs: const ['Sign In 💕', 'Sign Up ✨'],
              ),
              SizedBox(height: 18.h),
              if (_activeTabIndex == 0)
                WdLoginSignInTab(
                  emailController: _loginEmailController,
                  passwordController: _loginPasswordController,
                  isLoading: authState.isLoading,
                  onLogin: _onLogin,
                )
              else
                WdLoginSignUpTab(
                  nameController: _regNameController,
                  emailController: _regEmailController,
                  passwordController: _regPasswordController,
                  selectedRole: _selectedRole,
                  selectedBirthday: _selectedBirthday,
                  pickedAvatarFile: _pickedAvatarFile,
                  isLoading: authState.isLoading,
                  onRoleChanged: (role) => setState(() => _selectedRole = role),
                  onPickAvatar: _pickAvatar,
                  onPickBirthday: _pickBirthday,
                  onRegister: _onRegister,
                ),
              SizedBox(height: 18.h),
              WdGoogleSignInButton(
                isLoading: authState.isLoading,
                onGoogleSignIn: _onGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
