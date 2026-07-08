import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/goal.dart';
import '../services/goal_service.dart';
import '../core/theme.dart';

class CreateEditGoalScreen extends StatefulWidget {
  final Goal? goal;
  const CreateEditGoalScreen({super.key, this.goal});

  @override
  State<CreateEditGoalScreen> createState() => _CreateEditGoalScreenState();
}

class _CreateEditGoalScreenState extends State<CreateEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final GoalService _goalService = GoalService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();

  String _type = 'habit';
  String _category = 'Salah';
  DateTime? _deadline;
  bool _isLoading = false;
  int _descLength = 0;

  final List<String> _categories = [
    'Salah',
    'Quran',
    'Fasting',
    'Dhikr',
    'Sadaqah',
    'Sunnah',
    'Dua',
    'Tawbah',
    'Other',
  ];

  bool get _isEditing => widget.goal != null;

  // ── Colors ────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF1A7A6E);
  static const _primaryDark = Color(0xFF14584F);
  static const _bg = Color(0xFFF7F2F0);
  static const _fieldFill = Color(0xFFF0EBE8);
  static const _labelColor = Color(0xFF6B6B6B);
  static const _textColor = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final g = widget.goal!;
      _titleController.text = g.title;
      _descriptionController.text = g.description ?? '';
      _descLength = _descriptionController.text.length;
      _targetValueController.text =
          g.targetValue > 0 ? g.targetValue.toString() : '';
      _type = g.type;
      _category = g.category;
      if (g.deadline != null) {
        _deadline = DateTime.tryParse(g.deadline!);
      }
    }
    _descriptionController.addListener(() {
      setState(() => _descLength = _descriptionController.text.length);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final body = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'type': _type,
      'category': _category,
      'target_value':
          _type == 'habit' && _targetValueController.text.isNotEmpty
              ? int.parse(_targetValueController.text)
              : null,
      'deadline': _deadline?.toIso8601String().split('T').first,
    };

    try {
      if (_isEditing) {
        await _goalService.updateGoal(widget.goal!.id, body);
      } else {
        await _goalService.createGoal(body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  /// Small uppercase section label
  Widget _sectionLabel(String text, {String? sub}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _labelColor,
              letterSpacing: 0.9,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(width: 6),
            Text(
              sub,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _labelColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// White rounded card wrapper
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /// Styled text input field
  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLengthEnforcement:
          maxLength != null ? MaxLengthEnforcement.enforced : null,
      buildCounter: maxLength != null
          ? (_, {required currentLength, required isFocused, maxLength}) =>
              null
          : null,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 15,
          color: const Color(0xFFAAAAAA),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final remaining = 150 - _descLength;
    final appBarTitle = _isEditing
        ? 'Edit'
        : (_type == 'habit' ? 'New Habit' : 'New Goal');

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Custom AppBar ──────────────────────────────────────────
          _buildAppBar(appBarTitle),

          // ── Form content ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Type + Title + Description + Category
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type toggle
                          _sectionLabel('TYPE'),
                          _buildTypeToggle(),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFF0EBE8)),
                          const SizedBox(height: 20),

                          // Title
                          _sectionLabel('TITLE'),
                          _styledField(
                            controller: _titleController,
                            hint: 'e.g. Pray Fajr on time',
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Title is required'
                                    : null,
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFF0EBE8)),
                          const SizedBox(height: 20),

                          // Description
                          _sectionLabel('DESCRIPTION', sub: '(optional)'),
                          _styledField(
                            controller: _descriptionController,
                            hint: 'Add a short note about this...',
                            maxLines: 3,
                            maxLength: 150,
                            validator: (v) {
                              if (v != null && v.length > 150) {
                                return 'Max 150 characters';
                              }
                              return null;
                            },
                          ),
                          // Live char counter
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '$_descLength / 150',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: remaining <= 0
                                      ? Colors.red
                                      : remaining <= 20
                                          ? Colors.orange
                                          : _labelColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFF0EBE8)),
                          const SizedBox(height: 20),

                          // Category
                          _sectionLabel('CATEGORY'),
                          _buildCategoryDropdown(),
                        ],
                      ),
                    ),

                    // Card 2: Streak target (habits only)
                    if (_type == 'habit') ...[
                      const SizedBox(height: 12),
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('STREAK TARGET (DAYS)'),
                            _styledField(
                              controller: _targetValueController,
                              hint: '30',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Icon(
                                  Iconsax.medal_star,
                                  size: 18,
                                  color: _labelColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Card 3: Deadline
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('DEADLINE', sub: '(optional)'),
                          _buildDeadlineRow(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing ? 'Save Changes' : 'Create',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Custom AppBar ─────────────────────────────────────────────────────
  Widget _buildAppBar(String title) {
    return Container(
      width: double.infinity,
      color: _primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
          child: Row(
            children: [
              // Back arrow
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Iconsax.arrow_left,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Type toggle (Habit / Goal) ────────────────────────────────────────
  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _toggleOption('habit', 'Habit'),
          _toggleOption('goal', 'Goal'),
        ],
      ),
    );
  }

  Widget _toggleOption(String value, String label) {
    final isSelected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : _labelColor,
            ),
          ),
        ),
      ),
    );
  }

  // ── Category dropdown ─────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, size: 16, color: _labelColor),
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
          items: _categories.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Row(
                children: [
                  categoryIcon(c, _labelColor, size: 16),
                  const SizedBox(width: 10),
                  Text(c),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ),
    );
  }

  // ── Deadline row ──────────────────────────────────────────────────────
  Widget _buildDeadlineRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.calendar, size: 18, color: _labelColor),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: _pickDeadline,
              child: Text(
                _deadline == null
                    ? 'No deadline'
                    : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _deadline == null ? const Color(0xFFAAAAAA) : _textColor,
                ),
              ),
            ),
          ),
          // Clear button if deadline is set, add button if not
          _deadline != null
              ? GestureDetector(
                  onTap: () => setState(() => _deadline = null),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, size: 16, color: _labelColor),
                  ),
                )
              : GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.add, size: 16, color: _labelColor),
                  ),
                ),
        ],
      ),
    );
  }
}