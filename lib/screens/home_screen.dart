import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';
import 'add_expense_screen.dart';

class ExpensesHomePage extends StatefulWidget {
  const ExpensesHomePage({super.key});

  @override
  State<ExpensesHomePage> createState() => _ExpensesHomePageState();
}

class _ExpensesHomePageState extends State<ExpensesHomePage> {
  // ── Seed data ─────────────────────────────────────────────────────────────
  final List<Expense> _expenses = [
    Expense(id: '1', title: 'Groceries',      amount: 850.00),
    Expense(id: '3', title: 'Coffee',          amount: 150.00),
  ];

  // ── Category metadata ─────────────────────────────────────────────────────
  // Cycles through 3 visual styles matching the redesign
  static const _catMeta = [
    {'icon': '₱', 'sub': '', 'color': kCatFoodColor},
    {'icon': '₱', 'sub': '', 'color': kCatFoodColor},
    {'icon': '₱', 'sub': '', 'color': kCatFoodColor},
  ];

  Map<String, dynamic> _meta(int index) => _catMeta[index % _catMeta.length];

  // ── Navigation: Add ───────────────────────────────────────────────────────
  Future<void> _openAddScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
        settings: const RouteSettings(arguments: AddExpenseArgs()),
      ),
    );
    if (result != null && mounted) {
      setState(() => _expenses.add(Expense.fromMap(result)));
      _showSnackBar(
        '✅ Added: ${result['title']} • ₱${(result['amount'] as double).toStringAsFixed(2)}',
        kCoral,
      );
    }
  }

  // ── Navigation: Edit ──────────────────────────────────────────────────────
  Future<void> _openEditScreen(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
        settings: RouteSettings(
          arguments: AddExpenseArgs(expense: _expenses[index]),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _expenses[index].title  = result['title']  as String;
        _expenses[index].amount = result['amount'] as double;
      });
      _showSnackBar('✏️ Updated: ${_expenses[index].title}', kTeal);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Delete with confirmation dialog ───────────────────────────────────────
  Future<void> _deleteExpense(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Remove "${_expenses[index].title}"?',
          style: const TextStyle(color: Color(0xFF555566)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF555566))),
          ),
          Container(
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: kRed, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final title = _expenses[index].title;
      setState(() => _expenses.removeAt(index));
      _showSnackBar('🗑️ Deleted: $title', kRed);
    }
  }

  double get _total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Diagonal background blob (top-right, coral/orange)
          Positioned(
            top: -70,
            right: -70,
            child: Transform.rotate(
              angle: 0.52,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: kHeroGradient,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (_expenses.isNotEmpty) _buildHeroCard(),
                _buildSectionLabel(),
                Expanded(
                  child: _expenses.isEmpty ? _buildEmptyState() : _buildList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: 'Spend'),
              TextSpan(
                text: '.',
                style: TextStyle(color: kCoral),
              ),
            ],
          ),
        ),
      );

  // ── Hero total card ───────────────────────────────────────────────────────
  Widget _buildHeroCard() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: kHeroGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kBg.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
  
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL EXPENSES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _heroTag('📅 March 2026'),
                      const SizedBox(width: 10),
                      _heroTag('${_expenses.length} items'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _heroTag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel() => const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Text(
          'RECENT',
          style: TextStyle(
            color: Color(0xFF555566),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );

  // ── Expense list ──────────────────────────────────────────────────────────
  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          final meta    = _meta(index);
          final color   = meta['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kCardBorder),
            ),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left colour bar
                  Container(width: 3, color: color),
                  Expanded(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      onTap: () => _openEditScreen(index),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          meta['icon'] as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₱${expense.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Edit button
                          GestureDetector(
                            onTap: () => _openEditScreen(index),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22232E),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: const Color(0xFF2E2F3D)),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 14,
                                color: Color(0xFF555566),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Delete button
                          GestureDetector(
                            onTap: () => _deleteExpense(index),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: kRed.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: kRed.withOpacity(0.25)),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: kRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: kHeroGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: kBg.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.receipt_long, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'No expenses yet!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to add one.',
              style: TextStyle(fontSize: 14, color: Color(0xFF555566)),
            ),
          ],
        ),
      );

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFAB() => Container(
        decoration: BoxDecoration(
          gradient: kHeroGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kBg.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openAddScreen,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.add, size: 16),
          ),
          label: const Text(
            'Add Expense',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
        ),
      );
}

