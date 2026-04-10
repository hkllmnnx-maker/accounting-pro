import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedCategory = 'الكل';
  final _categories = ['الكل', 'إيجار', 'مرافق', 'صيانة', 'نقل', 'رواتب', 'أخرى'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        var expenses = provider.expenses;
        if (_selectedCategory != 'الكل') {
          expenses = expenses.where((e) => e.category == _selectedCategory).toList();
        }
        final total = expenses.fold(0.0, (s, e) => s + e.amount);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('المصاريف'),
              backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add), label: const Text('إضافة مصروف'),
              backgroundColor: Colors.red),
            body: Column(children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.withValues(alpha: 0.05),
                child: Column(children: [
                  Text(formatCurrency(total),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  const Text('إجمالي المصاريف', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: _categories.map((c) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        selected: _selectedCategory == c,
                        onSelected: (v) => setState(() => _selectedCategory = c),
                        selectedColor: Colors.red.shade100,
                      ),
                    )).toList()),
                  ),
                ]),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const EmptyState(message: 'لا يوجد مصاريف', icon: Icons.money_off)
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (_, i) => _buildCard(context, expenses[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'إيجار': return Icons.home;
      case 'مرافق': return Icons.electrical_services;
      case 'صيانة': return Icons.build;
      case 'نقل': return Icons.local_shipping;
      case 'رواتب': return Icons.people;
      default: return Icons.receipt_long;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'إيجار': return Colors.purple;
      case 'مرافق': return Colors.blue;
      case 'صيانة': return Colors.orange;
      case 'نقل': return Colors.teal;
      case 'رواتب': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  Widget _buildCard(BuildContext context, Expense expense, AppProvider provider) {
    final catColor = _getCategoryColor(expense.category);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.15),
          child: Icon(_getCategoryIcon(expense.category), color: catColor, size: 20)),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: catColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(expense.category, style: TextStyle(fontSize: 10, color: catColor))),
          const SizedBox(width: 6),
          Text(formatDate(expense.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        trailing: Text(formatCurrency(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        onTap: () => _showForm(context, provider, expense: expense),
        onLongPress: () async {
          if (await confirmDelete(context, expense.title)) provider.deleteExpense(expense.id);
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Expense? expense}) {
    final titleC = TextEditingController(text: expense?.title ?? '');
    final amountC = TextEditingController(text: expense?.amount.toString() ?? '0');
    final notesC = TextEditingController(text: expense?.notes ?? '');
    String category = expense?.category ?? 'أخرى';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Form(key: formKey, child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(expense == null ? 'إضافة مصروف' : 'تعديل مصروف',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                AppTextField(label: 'الوصف *', controller: titleC,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
                AppTextField(label: 'المبلغ', controller: amountC, keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: ['إيجار', 'مرافق', 'صيانة', 'نقل', 'رواتب', 'أخرى']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModalState(() => category = v ?? 'أخرى'),
                ),
                const SizedBox(height: 12),
                AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    provider.saveExpense(Expense(
                      id: expense?.id ?? provider.generateId(),
                      title: titleC.text, category: category,
                      amount: double.tryParse(amountC.text) ?? 0,
                      notes: notesC.text, date: expense?.date ?? DateTime.now(),
                      createdAt: expense?.createdAt ?? DateTime.now()));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: Text(expense == null ? 'إضافة' : 'حفظ'))),
              ])))))));
  }
}
