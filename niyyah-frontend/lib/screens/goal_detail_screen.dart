import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';
import '../core/theme.dart';
import '../widgets/mosque_silhouette.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Goal _goal;
  final GoalService _goalService = GoalService();
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
    _fetchGoal();
  }

  Future<void> _fetchGoal() async {
    try {
      final goals = await _goalService.getGoals();
      final fresh = goals.firstWhere((g) => g.id == _goal.id);
      if (mounted) setState(() => _goal = fresh);
    } catch (_) {}
  }

  Future<void> _logHabit() async {
    setState(() => _isActionLoading = true);
    try {
      final updated = await _goalService.logHabit(_goal.id);
      if (!mounted) return;
      setState(() => _goal = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged! Streak updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _markComplete() async {
    setState(() => _isActionLoading = true);
    try {
      final updated = await _goalService.completeGoal(_goal.id);
      if (!mounted) return;
      setState(() => _goal = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Goal marked as complete!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete ${_goal.type == 'habit' ? 'Habit' : 'Goal'}',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to delete "${_goal.title}"? This cannot be undone.',
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
      await _goalService.deleteGoal(_goal.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHabit = _goal.type == 'habit';
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final alreadyLoggedToday = _goal.lastLoggedDate == todayString;

    // Habit = teal, Goal = gold
    final heroColor = isHabit
        ? const Color(0xFF1A7A6E)
        : const Color(0xFFC49A2A);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F0),
      body: Column(
        children: [
          // ── Hero header ──────────────────────────────────────────────
          _buildHero(isHabit, heroColor),

          // ── Scrollable content ───────────────────────────────────────
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -32, 0),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F2F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    // ── Stats card ─────────────────────────────────────
                    if (isHabit) _buildHabitStatsCard(),
                    if (!isHabit) _buildGoalStatusCard(),

                    const SizedBox(height: 12),

                    // ── Details card (deadline + category) ────────────
                    _buildDetailsCard(),

                    const SizedBox(height: 20),

                    // ── Main action button ─────────────────────────────
                    if (isHabit) _buildLogButton(alreadyLoggedToday),
                    if (!isHabit && !_goal.isCompleted)
                      _buildMarkCompleteButton(),

                    const SizedBox(height: 12),

                    // ── Edit / Delete ──────────────────────────────────
                    _buildEditDeleteRow(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────────
  Widget _buildHero(bool isHabit, Color heroColor) {
    return Container(
      width: double.infinity,
      color: heroColor,
      child: Stack(
        children: [
          // Mosque silhouette at the bottom of the hero, same as home screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: MosqueSilhouette(opacity: 0.18),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              // Extra bottom padding so the white card overlaps nicely
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type badge + category
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHabit ? 'Habit' : 'Goal',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isHabit
                                ? const Color(0xFF1A7A6E)
                                : const Color(0xFFC49A2A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _goal.category,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    _goal.title,
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                  // Description
                  if (_goal.description != null &&
                      _goal.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _goal.description!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Habit stats card ──────────────────────────────────────────────────
  Widget _buildHabitStatsCard() {
    final progress = _goal.targetValue > 0
        ? (_goal.currentProgress / _goal.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final percent = (_goal.targetValue > 0)
        ? '${(progress * 100).toInt()}% of target reached'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT STREAK',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6B6B6B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_goal.currentProgress}',
                style: GoogleFonts.nunito(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE07B2A),
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'days',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1E),
                          ),
                        ),
                        if (_goal.targetValue > 0)
                          Text(
                            'Target: ${_goal.targetValue} days',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_goal.targetValue > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE8F5F3),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF1A7A6E)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              percent,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Goal status card ──────────────────────────────────────────────────
  Widget _buildGoalStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _goal.isCompleted
          ? Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E9E6B),
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF2E9E6B),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed!',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E9E6B),
                      ),
                    ),
                    Text(
                      'Alhamdulillah ✨',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCCCCCC),
                      width: 2.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.radio_button_unchecked,
                    color: Color(0xFFCCCCCC),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'In progress',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
    );
  }

  // ── Details card (deadline + category) ───────────────────────────────
  Widget _buildDetailsCard() {
    final deadlineText = _goal.deadline != null
        ? _goal.deadline!.split('T').first
        : 'No deadline';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _detailRow(Iconsax.calendar, 'Deadline', deadlineText),
          const Divider(height: 1, color: Color(0xFFF0EBE8)),
          _detailRow(Iconsax.category, 'Category', _goal.category),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }

  // ── Log Today button ──────────────────────────────────────────────────
  Widget _buildLogButton(bool alreadyLoggedToday) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_isActionLoading || alreadyLoggedToday) ? null : _logHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: alreadyLoggedToday
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF1A7A6E),
          foregroundColor: alreadyLoggedToday
              ? const Color(0xFF999999)
              : Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: const Color(0xFF999999),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isActionLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                alreadyLoggedToday ? 'Logged today ✓' : 'Log Today ✓',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // ── Mark as Complete button ───────────────────────────────────────────
  Widget _buildMarkCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isActionLoading ? null : _markComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E9E6B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isActionLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Mark as Complete',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  // ── Edit / Delete row ─────────────────────────────────────────────────
  Widget _buildEditDeleteRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/edit', arguments: _goal),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCCCCCC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(0, 56),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1C1E),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _delete,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE53935)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              minimumSize: const Size(0, 56),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE53935),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
