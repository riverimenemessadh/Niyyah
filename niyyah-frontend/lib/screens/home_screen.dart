// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/goal.dart';
import '../services/auth_service.dart';
import '../services/goal_service.dart';
import '../widgets/mosque_silhouette.dart';
import '../core/theme.dart';
import '../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List<Goal> _habits = [];
  List<Goal> _goals = [];
  bool _isLoading = true;
  final _goalService = GoalService();
  final Set<int> _loggingIds = {};

  // Drawer state
  bool _profileExpanded = false;
  bool _isEditingName = false;
  final _nameController = TextEditingController();
  bool _isSavingName = false;
  final _drawerKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final user = await AuthService.getCurrentUser();
      final allGoals = await _goalService.getGoals();
      if (!mounted) return;
      setState(() {
        _userName = user?['name'] ?? '';
        _habits = allGoals
            .where((g) => g.type == 'habit' && !g.isCompleted)
            .toList();
        _goals = allGoals
            .where((g) => g.type == 'goal' && !g.isCompleted)
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logHabit(Goal habit) async {
    if (_loggingIds.contains(habit.id)) return;
    setState(() => _loggingIds.add(habit.id));
    try {
      final updated = await _goalService.logHabit(habit.id);
      if (!mounted) return;
      setState(() {
        final index = _habits.indexWhere((h) => h.id == habit.id);
        if (index != -1) _habits[index] = updated;
      });
    } catch (_) {}
    if (mounted) setState(() => _loggingIds.remove(habit.id));
  }

  Future<void> _completeGoal(Goal goal) async {
    try {
      await _goalService.completeGoal(goal.id);
      _loadData();
    } catch (_) {}
  }

  bool _alreadyLoggedToday(Goal habit) {
    if (habit.lastLoggedDate == null) return false;
    final today = DateTime.now();
    final logged = DateTime.tryParse(habit.lastLoggedDate!);
    if (logged == null) return false;
    return logged.year == today.year &&
        logged.month == today.month &&
        logged.day == today.day;
  }

  // ── Drawer actions ────────────────────────────────────────────────────

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    setState(() => _isSavingName = true);
    try {
      await AuthService.updateName(newName);
      if (!mounted) return;
      setState(() {
        _userName = newName;
        _isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: const Color(0xFF6B6B6B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF1A7A6E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Account',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will permanently delete your account and all your data. This cannot be undone.',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: const Color(0xFF6B6B6B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await AuthService.deleteAccount();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Drawer widget ─────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF14584F),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Row(
                  children: [
                    Text(
                      'نيّة',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD4A843),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Niyyah',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 8),

              // ── Profile accordion ──────────────────────────────────
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(
                      () => _profileExpanded = !_profileExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Iconsax.user,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 14),
                        Text(
                          'Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _profileExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Iconsax.arrow_down,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Profile expanded content ───────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _profileExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Edit Name
                      Text(
                        'EDIT NAME',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isEditingName
                          ? Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameController,
                                    autofocus: true,
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter new name',
                                      hintStyle: GoogleFonts.nunito(
                                        color: Colors.white
                                            .withValues(alpha: 0.4),
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor:
                                          Colors.white.withValues(alpha: 0.1),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _isSavingName ? null : _saveName,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4A843),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: _isSavingName
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.check,
                                            color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                _nameController.text = _userName;
                                setState(() => _isEditingName = true);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _userName,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Iconsax.edit_2,
                                      size: 14,
                                      color: Colors.white
                                          .withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),

                      // Delete Account
                      GestureDetector(
                        onTap: _deleteAccount,
                        child: Row(
                          children: [
                            const Icon(Iconsax.trash,
                                color: Color(0xFFFF6B6B), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Account',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),

              const Spacer(),

              // Divider
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.1),
              ),

              // ── Logout ─────────────────────────────────────────────
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _logout,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        const Icon(Iconsax.logout,
                            color: Color(0xFFFF6B6B), size: 20),
                        const SizedBox(width: 14),
                        Text(
                          'Logout',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      backgroundColor: const Color(0xFF1A7A6E),
      endDrawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              color: const Color(0xFF1A7A6E),
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F2F0),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel("TODAY'S HABITS"),
                          const SizedBox(height: 12),
                          _habits.isEmpty
                              ? const HabitsEmptyState()
                              : Column(
                                  children: _habits
                                      .map((h) => _habitCard(h))
                                      .toList(),
                                ),
                          const SizedBox(height: 24),
                          _sectionLabel("ACTIVE GOALS"),
                          const SizedBox(height: 12),
                          _goals.isEmpty
                              ? const GoalsEmptyState()
                              : Column(
                                  children: _goals
                                      .map((g) => _goalCard(g))
                                      .toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: const MosqueSilhouette(opacity: 0.18),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamualaikum,',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userName,
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Menu button — opens endDrawer ──────────────
                      GestureDetector(
                        onTap: () =>
                            _drawerKey.currentState?.openEndDrawer(),
                        child: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CustomPaint(
                                painter: _CrescentMenuPainter()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _summaryPill(
                        '${_habits.length} Active Habit${_habits.length == 1 ? '' : 's'}',
                      ),
                      const SizedBox(width: 10),
                      _summaryPill(
                        '${_goals.length} Goal${_goals.length == 1 ? '' : 's'}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF14584F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1C1C1E),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _habitCard(Goal habit) {
    final logged = _alreadyLoggedToday(habit);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/detail',
        arguments: habit,
      ).then((_) => _loadData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7A6E),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: categoryIcon(habit.category, const Color(0xFF1A7A6E)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        habit.title,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            habit.category,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: Color(0xFF6B6B6B),
                              fontSize: 12,
                            ),
                          ),
                          const Text('🔥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentProgress} day streak',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: logged
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Logged today',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        )
                      : Material(
                          color: const Color(0xFF1A7A6E),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _loggingIds.contains(habit.id)
                                ? null
                                : () => _logHabit(habit),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: _loggingIds.contains(habit.id)
                                  ? const SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Log today',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalCard(Goal goal) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/detail',
        arguments: goal,
      ).then((_) => _loadData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF3DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: categoryIcon(goal.category, const Color(0xFFD4A843)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        goal.title,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        goal.category,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Material(
                    color: const Color(0xFF1A7A6E),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _completeGoal(goal),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrescentMenuPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final moonCX = w * 0.42;
    final moonCY = h * 0.44;
    final moonR = w * 0.36;

    final outerCircle = Path()
      ..addOval(Rect.fromCircle(center: Offset(moonCX, moonCY), radius: moonR));
    final innerCircle = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(moonCX + moonR * 0.55, moonCY - moonR * 0.1),
          radius: moonR * 0.82,
        ),
      );
    final crescent = Path.combine(
      PathOperation.difference,
      outerCircle,
      innerCircle,
    );

    final fillPaint = Paint()
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crescent, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFD4A843)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.68, h * 0.25),
      Offset(w * 0.98, h * 0.25),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.68, h * 0.48),
      Offset(w * 0.98, h * 0.48),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.68, h * 0.71),
      Offset(w * 0.98, h * 0.71),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}