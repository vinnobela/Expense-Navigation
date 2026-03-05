import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';

/// Dual-mode screen: Add (expense == null) or Edit (expense != null).
///
/// Returns Map<String, dynamic> on Save, null on Cancel.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  String? _titleError;
  String? _amountError;

  bool _isEditMode = false;
  Expense? _original;
  bool _initialized = false;

  // ── Resolve route args once ──────────────────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as AddExpenseArgs?;
    _original   = args?.expense;
    _isEditMode = _original != null;

    _titleController = TextEditingController(
        text: _isEditMode ? _original!.title : '');
    _amountController = TextEditingController(
        text: _isEditMode ? _original!.amount.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Validate and return result ───────────────
  void _save() {
    final title  = _titleController.text.trim();
    final rawAmt = _amountController.text.trim();

    String? titleErr;
    String? amountErr;

    if (title.isEmpty) {
      titleErr = 'Title cannot be empty.';
    }

    final parsed = double.tryParse(rawAmt);
    if (rawAmt.isEmpty) {
      amountErr = 'Amount cannot be empty.';
    } else if (parsed == null) {
      amountErr = 'Enter a valid number.';
    } else if (parsed <= 0) {
      amountErr = 'Amount must be greater than 0.';
    }

    if (titleErr != null || amountErr != null) {
      setState(() {
        _titleError  = titleErr;
        _amountError = amountErr;
      });
      return;
    }

    // Pop with result map
    Navigator.pop(context, {
      'id': _isEditMode
          ? _original!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      'title':  title,
      'amount': parsed!,
    });
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 28),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 12),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────
  AppBar _buildAppBar() => AppBar(
        title: Text(
          _isEditMode ? 'Edit Expense' : 'Add Expense',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      );

  // ── Header card ──────────────────────────────
  Widget _buildHeaderCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              _isEditMode ? Icons.drive_file_rename_outline : Icons.add_circle_outline,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Edit Expense' : 'New Expense',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  _isEditMode
                      ? 'Update the details below'
                      : 'Fill in the details below',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      );

  // ── Shared input decoration ──────────────────
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    String? errorText,
    required Widget prefixIcon,
    BoxConstraints? prefixIconConstraints,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kPrimary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kRed, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kRed, width: 2)),
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIconConstraints,
      );

  // ── Title field ──────────────────────────────
  Widget _buildTitleField() => TextField(
        controller: _titleController,
        autofocus: !_isEditMode,
        decoration: _inputDecoration(
          label: 'Expense title',
          hint: 'e.g. Coffee, Groceries, Rent…',
          errorText: _titleError,
          prefixIcon: const Icon(Icons.label_outline, color: kPrimary),
        ),
        onChanged: (_) {
          if (_titleError != null) setState(() => _titleError = null);
        },
      );

  // ── Amount field ─────────────────────────────
  Widget _buildAmountField() => TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(
          label: 'Amount',
          hint: 'e.g. 150.00',
          errorText: _amountError,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Text(
              '₱',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimary),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
        ),
        onChanged: (_) {
          if (_amountError != null) setState(() => _amountError = null);
        },
      );

  // ── Save button ──────────────────────────────
  Widget _buildSaveButton() => Container(
        decoration: BoxDecoration(
          gradient: kGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded),
          label: Text(
            _isEditMode ? 'Save Changes' : 'Save Expense',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  // ── Cancel button — returns null ─────────────
  Widget _buildCancelButton() => OutlinedButton(
        onPressed: () => Navigator.pop(context), // null → no update
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimary,
          side: const BorderSide(color: kPrimary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Cancel', style: TextStyle(fontSize: 15)),
      );
}