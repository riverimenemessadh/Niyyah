// lib/screens/goals_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';
import '../core/theme.dart';
import '../widgets/empty_state.dart';

class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  final GoalService _goalService = GoalService();
  List<Goal> _goals = [];
  List<Goal> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = [
    'All', 'Habits', 'Goals',
    'Salah', 'Quran', 'Fasting', 'Dhikr',
    'Sadaqah', 'Sunnah', 'Dua', 'Tawbah', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyFilter(_selectedFilter);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    try {
      final goals = await _goalService.getGoals();
      if (mounted) {
        setState(() {
          _goals = goals;
          _applyFilter(_selectedFilter);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load goals';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter(String filter) {
    _selectedFilter = filter;
    List<Goal> base;
    if (filter == 'All') {
      base = _goals;
    } else if (filter == 'Habits') {
      base = _goals.where((g) => g.type == 'habit').toList();
    } else if (filter == 'Goals') {
      base = _goals.where((g) => g.type == 'goal').toList();
    } else {
      base = _goals.where((g) => g.category == filter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      base = base.where((g) => g.title.toLowerCase().contains(_searchQuery)).toList();
    }
    _filtered = base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A7A6E)))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : RefreshIndicator(
                    color: const Color(0xFF1A7A6E),
                    onRefresh: _loadGoals,
                    child: CustomScrollView(
                      slivers: [
                        // Title
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: Text(
                              'My Habits & Goals',
                              style: GoogleFonts.nunito(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ),
                        // Search bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.nunito(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: GoogleFonts.nunito(
                                    color: const Color(0xFFAAAAAA),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Iconsax.search_normal,
                                    color: Color(0xFFAAAAAA),
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        // Filter chips
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 38,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _filters.length,
                              itemBuilder: (context, index) {
                                final f = _filters[index];
                                final isSelected = _selectedFilter == f;
                                return GestureDetector(
                                  onTap: () => setState(() => _applyFilter(f)),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF1A7A6E)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      f,
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF6B6B6B),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        // List or empty state
                        _filtered.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: const HabitsEmptyState(),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final goal = _filtered[index];
                                      return _goalCard(goal);
                                    },
                                    childCount: _filtered.length,
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
    final isHabit = goal.type == 'habit';
    final barColor = isHabit
        ? const Color(0xFF1A7A6E)
        : const Color(0xFFD4A843);
    final iconBg = isHabit
        ? const Color(0xFFE8F5F3)
        : const Color(0xFFFDF3DC);
    final iconColor = isHabit
        ? const Color(0xFF1A7A6E)
        : const Color(0xFFD4A843);
    final badgeColor = isHabit
        ? const Color(0xFFE8F5F3)
        : const Color(0xFFFDF3DC);
    final badgeTextColor = isHabit
        ? const Color(0xFF1A7A6E)
        : const Color(0xFFD4A843);

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/detail', arguments: goal)
          .then((_) => _loadGoals()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left color bar
              Container(
                width: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: categoryIcon(goal.category, iconColor),
                ),
              ),
              const SizedBox(width: 12),
              // Title + badges
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
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHabit ? 'Habit' : 'Goal',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            goal.category,
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
              // Right: streak or checkmark
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: isHabit
                    ? Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${goal.currentProgress}',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE8943A),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        goal.isCompleted
                            ? Iconsax.tick_circle5
                            : Iconsax.tick_circle,
                        color: goal.isCompleted
                            ? const Color(0xFF4CAF80)
                            : const Color(0xFFCCCCCC),
                        size: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}