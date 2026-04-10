import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final entries = provider.journalEntries;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('القيود المحاسبية'),
              backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('قيد جديد'),
              backgroundColor: Colors.deepPurple),
            body: entries.isEmpty
                ? const EmptyState(message: 'لا يوجد قيود محاسبية', icon: Icons.book)
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => _buildCard(context, entries[i], provider)),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, JournalEntry entry, AppProvider provider) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: entry.isBalanced ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(entry.isBalanced ? Icons.check : Icons.warning,
            color: entry.isBalanced ? Colors.green : Colors.red, size: 20)),
        title: Text(entry.description.isNotEmpty ? entry.description : 'قيد #${entry.id.substring(0, 6)}',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          Text(formatDate(entry.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Text('${entry.lines.length} بنود', style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: entry.isBalanced ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Text(entry.isBalanced ? 'متوازن' : 'غير متوازن',
              style: TextStyle(fontSize: 10, color: entry.isBalanced ? Colors.green : Colors.red)),
          ),
        ]),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.grey.shade100,
            child: const Row(children: [
              Expanded(flex: 3, child: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text('مدين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text('دائن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
            ]),
          ),
          ...entry.lines.map((line) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              Expanded(flex: 3, child: Text(line.account, style: const TextStyle(fontSize: 12))),
              Expanded(flex: 2, child: Text(line.debit > 0 ? formatCurrency(line.debit) : '-',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: line.debit > 0 ? Colors.red : Colors.grey))),
              Expanded(flex: 2, child: Text(line.credit > 0 ? formatCurrency(line.credit) : '-',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: line.credit > 0 ? Colors.green : Colors.grey))),
            ]),
          )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(children: [
              const Expanded(flex: 3, child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              Expanded(flex: 2, child: Text(formatCurrency(entry.totalDebit),
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red))),
              Expanded(flex: 2, child: Text(formatCurrency(entry.totalCredit),
                textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green))),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(
                onPressed: () => _showForm(context, provider, entry: entry),
                icon: const Icon(Icons.edit, size: 16), label: const Text('تعديل')),
              TextButton.icon(
                onPressed: () async {
                  if (await confirmDelete(context, 'القيد')) provider.deleteJournalEntry(entry.id);
                },
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                label: const Text('حذف', style: TextStyle(color: Colors.red))),
            ]),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {JournalEntry? entry}) {
    final descC = TextEditingController(text: entry?.description ?? '');
    List<JournalLine> lines = entry?.lines.map((l) => JournalLine(
      account: l.account, debit: l.debit, credit: l.credit, notes: l.notes)).toList()
      ?? [JournalLine(), JournalLine()];

    showDialog(context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final totalDebit = lines.fold(0.0, (s, l) => s + l.debit);
          final totalCredit = lines.fold(0.0, (s, l) => s + l.credit);
          final isBalanced = (totalDebit - totalCredit).abs() < 0.01;

          return Directionality(textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(entry == null ? 'قيد محاسبي جديد' : 'تعديل القيد'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                      controller: descC,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(labelText: 'وصف القيد'),
                    ),
                    const SizedBox(height: 12),
                    ...lines.asMap().entries.map((e) {
                      final i = e.key;
                      final line = e.value;
                      final accC = TextEditingController(text: line.account);
                      final debC = TextEditingController(text: line.debit > 0 ? line.debit.toString() : '');
                      final crdC = TextEditingController(text: line.credit > 0 ? line.credit.toString() : '');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8)),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: TextField(
                              controller: accC,
                              textDirection: TextDirection.rtl,
                              decoration: const InputDecoration(labelText: 'الحساب', isDense: true),
                              onChanged: (v) => line.account = v)),
                            if (lines.length > 2) IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                              onPressed: () => setDialogState(() => lines.removeAt(i))),
                          ]),
                          Row(children: [
                            Expanded(child: TextField(
                              controller: debC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'مدين', isDense: true),
                              onChanged: (v) => setDialogState(() {
                                line.debit = double.tryParse(v) ?? 0;
                                if (line.debit > 0) { line.credit = 0; crdC.clear(); }
                              }))),
                            const SizedBox(width: 8),
                            Expanded(child: TextField(
                              controller: crdC,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'دائن', isDense: true),
                              onChanged: (v) => setDialogState(() {
                                line.credit = double.tryParse(v) ?? 0;
                                if (line.credit > 0) { line.debit = 0; debC.clear(); }
                              }))),
                          ]),
                        ]),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setDialogState(() => lines.add(JournalLine())),
                      icon: const Icon(Icons.add), label: const Text('إضافة بند')),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('مدين: ${formatCurrency(totalDebit)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('دائن: ${formatCurrency(totalCredit)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ]),
                    if (!isBalanced && totalDebit > 0 && totalCredit > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.warning, color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Text('الفرق: ${formatCurrency((totalDebit - totalCredit).abs())}',
                            style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ]),
                      ),
                  ]),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    provider.saveJournalEntry(JournalEntry(
                      id: entry?.id ?? provider.generateId(),
                      description: descC.text, lines: lines,
                      date: entry?.date ?? DateTime.now(),
                      createdAt: entry?.createdAt ?? DateTime.now()));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: Text(entry == null ? 'إضافة' : 'حفظ')),
              ],
            ));
        }));
  }
}
