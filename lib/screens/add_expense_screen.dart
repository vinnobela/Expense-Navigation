import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_theme.dart';

/// Dual-mode screen: Add (expense == null) or Edit (expense != null).
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
  bool    _isEditMode  = false;
  Expense? _original;
  bool    _initialized = false;

  // ── Resolve route args once ────────────────────────────────────────────────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments as AddExpenseArgs?;
    _original   = args?.expense;
    _isEditMode = _original != null;

    _titleController  = TextEditingController(
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

  // ── Validate & return result ───────────────────────────────────────────────
  void _save() {
    final title  = _titleController.text.trim();
    final rawAmt = _amountController.text.trim();

    String? titleErr;
    String? amountErr;

    if (title.isEmpty) titleErr = 'Title cannot be empty.';

    final parsed = double.tryParse(rawAmt);
    if (rawAmt.isEmpty)   amountErr = 'Amount cannot be empty.';
    else if (parsed == null) amountErr = 'Enter a valid number.';
    else if (parsed <= 0) amountErr = 'Amount must be greater than 0.';

    if (titleErr != null || amountErr != null) {
      setState(() {
        _titleError  = titleErr;
        _amountError = amountErr;
      });
      return;
    }

    Navigator.pop(context, {
      'id':     _isEditMode
          ? _original!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      'title':  title,
      'amount': parsed!,
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Diagonal background blob (top-right, coral/orange — identical to home screen)
          Positioned(
            top:  -70,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBackRow(),
                  const SizedBox(height: 12),
                  _buildEditBanner(),
                  const SizedBox(height: 24),
                  _buildFieldLabel('EXPENSE TITLE'),
                  const SizedBox(height: 8),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildFieldLabel('AMOUNT'),
                  const SizedBox(height: 8),
                  _buildAmountField(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                  const SizedBox(height: 10),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header — mirrors home screen layout ───────────────────────────────────
  Widget _buildBackRow() => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back arrow styled like home avatar chip
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: kHeroGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: _isEditMode ? 'Edit' : 'Add'),
                    const TextSpan(
                      text: '.',
                      style: TextStyle(color: kCoral),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ── Banner card — mirrors home screen hero card ────────────────────────────
  Widget _buildEditBanner() => Container(
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _isEditMode
                        ? Icons.drive_file_rename_outline
                        : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditMode ? 'Edit Expense' : 'New Expense',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isEditMode
                          ? 'Update the details below'
                          : 'Fill in the details below',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  // ── Field label ────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF555566),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  // ── Shared input decoration ────────────────────────────────────────────────
  InputDecoration _inputDec({
    required String hint,
    String?         errorText,
    required Widget prefixIcon,
    BoxConstraints? prefixIconConstraints,
  }) =>
      InputDecoration(
        hintText:              hint,
        hintStyle:             const TextStyle(color: Color(0xFF444455)),
        errorText:             errorText,
        filled:                true,
        fillColor:             kCard,
        prefixIcon:            prefixIcon,
        prefixIconConstraints: prefixIconConstraints,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: kCoral.withOpacity(0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kRed, width: 2),
        ),
      );

  // ── Title field ────────────────────────────────────────────────────────────
  Widget _buildTitleField() => TextField(
        controller: _titleController,
        autofocus:  !_isEditMode,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: _inputDec(
          hint:       'e.g. Coffee, Groceries, Rent…',
          errorText:  _titleError,
          prefixIcon: const Icon(Icons.label_outline, color: Color(0xFF444455)),
        ),
        onChanged: (_) {
          if (_titleError != null) setState(() => _titleError = null);
        },
      );

  // ── Amount field ───────────────────────────────────────────────────────────
  Widget _buildAmountField() => TextField(
        controller:   _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: _inputDec(
          hint:      'e.g. 150.00',
          errorText: _amountError,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Text(
              '₱',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kCoral,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
        ),
        onChanged: (_) {
          if (_amountError != null) setState(() => _amountError = null);
        },
      );

  // ── Save button ────────────────────────────────────────────────────────────
  Widget _buildSaveButton() => Container(
        decoration: BoxDecoration(
          gradient: kHeroGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kBg.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _save,
          icon:  const Icon(Icons.save_rounded, size: 18),
          label: Text(
            _isEditMode ? 'Save Changes' : 'Save Expense',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor:     Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );

  // ── Cancel button ──────────────────────────────────────────────────────────
  Widget _buildCancelButton() => OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF444455),
          side: const BorderSide(color: kCardBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text('Cancel', style: TextStyle(fontSize: 15)),
      );
}
