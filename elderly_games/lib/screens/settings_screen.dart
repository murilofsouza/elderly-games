import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../services/points_manager.dart';
import '../themes/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = AudioService.instance.isEnabled;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName = context.read<PointsManager>().user.name;
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Sound toggle ────────────────────────────────────────────────────────────

  void _toggleSound(bool value) {
    AudioService.instance.toggle();
    setState(() => _soundEnabled = AudioService.instance.isEnabled);
  }

  // ── Save name ───────────────────────────────────────────────────────────────

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.length < 2) return;
    context.read<PointsManager>().updateUserName(newName);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Nome atualizado com sucesso!',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── About dialog ────────────────────────────────────────────────────────────

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        title: const Text(
          'Sobre o App',
          style: TextStyle(
            fontSize: AppTheme.fontTitle,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AboutRow(label: 'Versão', value: '1.0.0'),
            SizedBox(height: 12),
            _AboutRow(label: 'Contato', value: 'contato@jogosnoidosos.com.br'),
            SizedBox(height: 12),
            Text(
              'Desenvolvido com carinho para proporcionar entretenimento e estimulação cognitiva.',
              style: TextStyle(
                fontSize: AppTheme.fontSmall,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // ── Sound section ───────────────────────────────────────────────
            _SectionHeader(label: 'Sons'),
            _SettingsTile(
              child: SwitchListTile(
                value: _soundEnabled,
                onChanged: _toggleSound,
                activeThumbColor: AppTheme.primaryColor,
                activeTrackColor: AppTheme.primaryLight,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                secondary: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: AppTheme.primaryColor,
                    size: 26,
                  ),
                ),
                title: const Text(
                  'Efeitos Sonoros',
                  style: TextStyle(
                    fontSize: AppTheme.fontBody,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  _soundEnabled ? 'Ligado' : 'Desligado',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSmall,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Account section ─────────────────────────────────────────────
            _SectionHeader(label: 'Conta'),
            _SettingsTile(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: AppTheme.secondaryColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Alterar Nome',
                          style: TextStyle(
                            fontSize: AppTheme.fontBody,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              fontSize: AppTheme.fontBody,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.person_rounded, size: 26),
                            ),
                            onSubmitted: (_) => _saveName(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(90, AppTheme.buttonHeight),
                          ),
                          onPressed: _saveName,
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── About section ───────────────────────────────────────────────
            _SectionHeader(label: 'Informações'),
            _SettingsTile(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                minVerticalPadding: 14,
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: AppTheme.primaryColor,
                    size: 26,
                  ),
                ),
                title: const Text(
                  'Sobre o App',
                  style: TextStyle(
                    fontSize: AppTheme.fontBody,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Versão 1.0.0',
                  style: TextStyle(
                    fontSize: AppTheme.fontSmall,
                    color: AppTheme.textSecondary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                onTap: _showAbout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: AppTheme.fontSmall,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Widget child;
  const _SettingsTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        child: child,
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: AppTheme.fontSmall,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppTheme.fontSmall,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
