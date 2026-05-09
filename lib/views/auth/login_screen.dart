import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toastification/toastification.dart';
import '../../components/forms/text_input.dart';
import '../../components/forms/password_input.dart';
import '../../components/forms/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/constants.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../bookmarks/bookmarks_screen.dart';
import 'lost_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _storage = FlutterSecureStorage();

  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final baseUrl = await _storage.read(key: 'baseUrl');
    final authToken = await _storage.read(key: 'authToken');
    if (!mounted) return;
    if (baseUrl != null && baseUrl.isNotEmpty &&
        authToken != null && authToken.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const BookmarksScreen()),
      );
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _onLostTap() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LostScreen()));
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    final error = await AuthController().login(
      baseUrl: _baseUrlController.text.trim(),
      token: _tokenController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const BookmarksScreen()),
      );
      return;
    }

    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: const Text('Login Failed'),
      description: Text(error),
      autoCloseDuration: const Duration(seconds: 4),
      style: ToastificationStyle.fillColored,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BrandHeader(),
                    const SizedBox(height: 32),
                    _LoginCard(
                      formKey: _formKey,
                      baseUrlController: _baseUrlController,
                      tokenController: _tokenController,
                      isLoading: _isLoading,
                      onSubmit: _onSubmit,
                      onLostTap: _onLostTap,
                    ),
                    const SizedBox(height: 32),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'lib/images/logos/logo.png',
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          '(Open Source Edition)',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          slogan,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.baseUrlController,
    required this.tokenController,
    required this.isLoading,
    required this.onSubmit,
    required this.onLostTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController baseUrlController;
  final TextEditingController tokenController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onLostTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Welcome back',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect to your OpenBookList instance.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextInput(
              label: 'Base URL',
              controller: baseUrlController,
              hint: 'https://obl.example.com',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.link),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Base URL is required';
                }
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme) {
                  return 'Enter a valid URL (e.g. https://…)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PasswordInput(
              label: 'Auth Token',
              controller: tokenController,
              hint: 'Paste your personal access token',
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.key),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Auth token is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Sign In',
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
            Center(child: _LostHint(onTap: onLostTap)),
          ],
        ),
      ),
    );
  }
}

class _LostHint extends StatefulWidget {
  const _LostHint({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LostHint> createState() => _LostHintState();
}

class _LostHintState extends State<_LostHint> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = widget.onTap;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        children: [
          const TextSpan(text: 'What is this? '),
          TextSpan(
            text: 'I am lost',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
            recognizer: _recognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Website — icon, bigger, darker
        GestureDetector(
          onTap: () => _launch(websiteUrl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                size: 18,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 6),
              Text(
                websiteUrl,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  decorationColor: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Made by
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Made by  ',
              style: AppTextStyles.regular.copyWith(color: AppColors.textMuted),
            ),
            GestureDetector(
              onTap: () => _launch(makerUrl),
              child: Text(
                makerName,
                style: AppTextStyles.regular.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
