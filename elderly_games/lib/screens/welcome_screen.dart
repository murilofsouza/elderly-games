import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../services/points_manager.dart';
import '../services/storage_service.dart';
import '../themes/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  final StorageService storage;

  const WelcomeScreen({super.key, required this.storage});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Capture before any async gap — never use BuildContext after await.
    final manager = context.read<PointsManager>();

    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
    );

    // updateUser notifies listeners immediately (before the storage await),
    // so HomeScreen will see the real name the moment it mounts.
    await manager.updateUser(profile);
    await widget.storage.completeOnboarding();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── Icon ────────────────────────────────────────────────────
                SizedBox(
                  width: 64,
                  height: 64,
                  child: SvgPicture.asset(
                    'assets/images/logo/polie_icon_blue.svg',
                  ),
                ),
                const SizedBox(height: 48),

                // ── Title ───────────────────────────────────────────────────
                const Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.fontHero,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Subtitle ────────────────────────────────────────────────
                const Text(
                  'Vamos jogar e se divertir?\nPrimeiro, como podemos te chamar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.fontBody,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Name field ──────────────────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ '\-]")),
                  ],
                  style: const TextStyle(
                    fontSize: AppTheme.fontBody,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_rounded, size: 26),
                    hintText: 'Ex: Maria, Jose...',
                    labelText: 'Seu nome',
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length < 2) {
                      return 'Por favor, insira pelo menos 2 caracteres.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 40),

                // ── CTA button ──────────────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 26),
                  label: Text(
                    _loading ? 'Aguarde...' : 'Comecar a Jogar!',
                    style: const TextStyle(
                      fontSize: AppTheme.fontBody,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
