import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/point_transaction.dart';
import '../services/game_registry.dart';
import '../services/points_manager.dart';
import '../themes/app_theme.dart';
import '../widgets/game_card.dart';
import '../widgets/points_display.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _GamesTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.games_rounded),
            activeIcon: Icon(Icons.games_rounded),
            label: 'Jogos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ── Games Tab ─────────────────────────────────────────────────────────────────

class _GamesTab extends StatelessWidget {
  const _GamesTab();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Em breve!',
          style: TextStyle(
            fontSize: AppTheme.fontBody,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PointsManager>();
    final freeGames = GameRegistry.freeGames;
    final paidGames = GameRegistry.paidGames;

    return CustomScrollView(
      slivers: [
        // ── Green header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting,',
                            style: TextStyle(
                              fontSize: AppTheme.fontBody,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            manager.user.name,
                            style: const TextStyle(
                              fontSize: AppTheme.fontHeading,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PointsDisplay(
                      totalPoints: manager.totalPoints,
                      currentPoints: manager.currentPoints,
                      dailyStreak: manager.dailyStreak,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Section: Jogos Gratuitos ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: _SectionTitle(
            icon: Icons.star_rounded,
            iconColor: AppTheme.secondaryColor,
            title: 'Jogos Gratuitos',
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final game = freeGames[index];
              return GameCard(
                game: game,
                isUnlocked: true,
                onTap: () => Navigator.pushNamed(
                  context,
                  game.routeName,
                  arguments: game,
                ),
              );
            },
            childCount: freeGames.length,
          ),
        ),

        // ── Section: Em Breve ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _SectionTitle(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppTheme.textSecondary,
            title: 'Em Breve',
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final game = paidGames[index];
              return GameCard(
                game: game,
                isUnlocked: false,
                onTap: () => _showComingSoon(context),
              );
            },
            childCount: paidGames.length,
          ),
        ),

        // ── Bottom spacing ────────────────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  Future<List<PointTransaction>>? _transactionsFuture;

  // Cached to detect changes and re-fetch the transaction list.
  int? _cachedCurrentPoints;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PointsManager>();

    // Re-fetch whenever available points change (covers earn AND spend events).
    if (_cachedCurrentPoints != manager.currentPoints) {
      _cachedCurrentPoints = manager.currentPoints;
      _transactionsFuture = manager.getRecentTransactions(limit: 10);
    }
    final user = manager.user;
    final initial = user.name.isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, size: 28),
            tooltip: 'Configurações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ────────────────────────────────────────────────────────
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: AppTheme.fontHero,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // ── Stat cards ────────────────────────────────────────────────────
            _StatCard(
              icon: Icons.emoji_events_rounded,
              iconColor: AppTheme.pointsColor,
              label: 'Total de Pontos',
              value: manager.totalPoints.toString(),
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.stars_rounded,
              iconColor: AppTheme.primaryColor,
              label: 'Pontos Disponíveis',
              value: manager.currentPoints.toString(),
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: Colors.deepOrange,
              label: 'Sequência Diária',
              value: '${manager.dailyStreak} dias',
            ),
            const SizedBox(height: 28),

            // ── Recent Activity ───────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atividade Recente',
                style: const TextStyle(
                  fontSize: AppTheme.fontTitle,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<PointTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  );
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Nenhuma atividade ainda.\nJogue para ganhar pontos!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppTheme.fontBody,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }
                return Column(
                  children: transactions
                      .map((t) => _TransactionTile(transaction: t))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontBody,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontTitle,
              color: iconColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final PointTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isGain = transaction.amount > 0;
    final amountText =
        '${isGain ? '+' : ''}${transaction.amount} pts';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 12,
        leading: Icon(
          isGain ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
          color: isGain ? AppTheme.successColor : AppTheme.errorColor,
          size: 32,
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(
            fontSize: AppTheme.fontSmall,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: Text(
          amountText,
          style: TextStyle(
            fontSize: AppTheme.fontBody,
            fontWeight: FontWeight.w800,
            color: isGain ? AppTheme.successColor : AppTheme.errorColor,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontTitle,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

