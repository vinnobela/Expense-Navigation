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
  // ── Seed data (minimum 3 items) ──────────────
  final List<Expense> _expenses = [
    Expense(id: '1', title: 'Groceries',        amount: 850.00),
    Expense(id: '2', title: 'Electricity Bill',  amount: 1240.00),
    Expense(id: '3', title: 'Coffee',            amount: 150.00),
  ];

  // ── Navigation: Add ──────────────────────────
  Future<void> _openAddScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
        settings: const RouteSettings(
          arguments: AddExpenseArgs(), // null expense → Add mode
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _expenses.add(Expense.fromMap(result)));
      _showSnackBar(
        '✅  Added: ${result['title']}  •  ₱${(result['amount'] as double).toStringAsFixed(2)}',
        kGreen,
      );
    }
  }

  // ── Navigation: Edit (Option A — reuse AddExpenseScreen) ──
  Future<void> _openEditScreen(int index) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddExpenseScreen(),
        settings: RouteSettings(
          arguments: AddExpenseArgs(expense: _expenses[index]), // pre-filled
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _expenses[index].title  = result['title']  as String;
        _expenses[index].amount = result['amount'] as double;
      });
      _showSnackBar('✏️  Updated: ${_expenses[index].title}', kPrimaryDark);
    }
  }

  // ── Delete with confirmation dialog ──────────
  // Future<void> _deleteExpense(int index) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: const Text('Delete Expense',
  //           style: TextStyle(fontWeight: FontWeight.bold)),
  //       content: Text('Remove "${_expenses[index].title}"?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: kRed,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //           ),
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && mounted) {
  //     final title = _expenses[index].title;
  //     setState(() => _expenses.removeAt(index));
  //     _showSnackBar('🗑️  Deleted: $title', kRed);
  //   }
  // }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  double get _total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_expenses.isNotEmpty) _buildTotalCard(),
          Expanded(
            child: _expenses.isEmpty ? _buildEmptyState() : _buildList(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(),
    );
  }

  // ── AppBar ───────────────────────────────────
  AppBar _buildAppBar() => AppBar(
        title: const Text(
          '💸 Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      );

  // ── Total summary card ───────────────────────
  Widget _buildTotalCard() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: kGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '₱${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  // ── Empty state ──────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kAccent, kCard],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.receipt_long, size: 60, color: kPrimaryDark),
            ),
            const SizedBox(height: 20),
            const Text(
              'No expenses yet!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to add one.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );

  // ── Expense list ─────────────────────────────
  Widget _buildList() => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final expense = _expenses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => _openEditScreen(index),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kAccent, kCard],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '₱',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryDark),
                ),
              ),
              title: Text(
                expense.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '₱${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: kGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.drive_file_rename_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.drive_file_rename_outline, color: kPrimaryDark),
                tooltip: 'Edit',
                onPressed: () => _openEditScreen(index),
              ),
            ),
          );
        },
      );

  // ── FAB ──────────────────────────────────────
  Widget _buildFAB() => Container(
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openAddScreen,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text(
            'Add Expense',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      );
}
