import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class AccountStatementScreen extends StatefulWidget {
  final String? contactId;
  final String? contactName;
  const AccountStatementScreen({super.key, this.contactId, this.contactName});
  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  String? _selectedId;
  String _selectedName = '';

  @override
  void initState() {
    super.initState();
    _selectedId = widget.contactId;
    _selectedName = widget.contactName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final entries = _selectedId != null ? provider.getAccountStatement(_selectedId!) : <AccountEntry>[];
        final totalDebit = entries.fold(0.0, (s, e) => s + e.debit);
        final totalCredit = entries.fold(0.0, (s, e) => s + e.credit);
        final balance = entries.isNotEmpty ? entries.last.balance : 0.0;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('كشف حساب'),
              backgroundColor: Colors.brown, foregroundColor: Colors.white),
            body: Column(children: [
              // Contact selector
              Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => _selectContact(context, provider),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown.shade200),
                      borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.person, color: Colors.brown.shade400),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        _selectedName.isEmpty ? 'اختر حساب عميل أو مورد...' : _selectedName,
                        style: TextStyle(fontSize: 15, color: _selectedName.isEmpty ? Colors.grey : null,
                          fontWeight: _selectedName.isEmpty ? null : FontWeight.bold))),
                      const Icon(Icons.arrow_drop_down),
                    ]),
                  ),
                ),
              ),
              // Summary
              if (_selectedId != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Column(children: [
                      Text(formatCurrency(totalDebit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const Text('مدين', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                    Column(children: [
                      Text(formatCurrency(totalCredit), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const Text('دائن', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                    Column(children: [
                      Text(formatCurrency(balance), style: TextStyle(fontWeight: FontWeight.bold,
                        color: balance >= 0 ? Colors.red : Colors.green)),
                      const Text('الرصيد', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ]),
                  ]),
                ),
              const SizedBox(height: 8),
              // Table header
              if (_selectedId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey.shade200,
                  child: const Row(children: [
                    Expanded(flex: 2, child: Text('البيان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(child: Text('مدين', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                    Expanded(child: Text('دائن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                    Expanded(child: Text('الرصيد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                  ]),
                ),
              // Entries
              Expanded(
                child: _selectedId == null
                    ? const EmptyState(message: 'اختر حساب لعرض كشف الحساب', icon: Icons.account_balance)
                    : entries.isEmpty
                        ? const EmptyState(message: 'لا توجد حركات', icon: Icons.receipt_long)
                        : ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (_, i) => _buildEntryRow(entries[i])),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildEntryRow(AccountEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.description, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(formatDate(entry.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ])),
        Expanded(child: Text(entry.debit > 0 ? formatCurrency(entry.debit) : '-',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: entry.debit > 0 ? Colors.red : Colors.grey))),
        Expanded(child: Text(entry.credit > 0 ? formatCurrency(entry.credit) : '-',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: entry.credit > 0 ? Colors.green : Colors.grey))),
        Expanded(child: Text(formatCurrency(entry.balance),
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
            color: entry.balance >= 0 ? Colors.red : Colors.green))),
      ]),
    );
  }

  void _selectContact(BuildContext context, AppProvider provider) {
    showModalBottomSheet(context: context,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: DefaultTabController(length: 2,
          child: Column(children: [
            const TabBar(tabs: [Tab(text: 'العملاء'), Tab(text: 'الموردين')]),
            Expanded(child: TabBarView(children: [
              ListView.builder(
                itemCount: provider.clients.length,
                itemBuilder: (_, i) {
                  final c = provider.clients[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade100,
                      child: Text(c.name[0], style: TextStyle(color: Colors.blue.shade700))),
                    title: Text(c.name),
                    subtitle: Text('رصيد: ${formatCurrency(c.balance)}'),
                    onTap: () {
                      setState(() { _selectedId = c.id; _selectedName = c.name; });
                      Navigator.pop(context);
                    });
                }),
              ListView.builder(
                itemCount: provider.suppliers.length,
                itemBuilder: (_, i) {
                  final s = provider.suppliers[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.orange.shade100,
                      child: Text(s.name[0], style: TextStyle(color: Colors.orange.shade700))),
                    title: Text(s.name),
                    subtitle: Text('رصيد: ${formatCurrency(s.balance)}'),
                    onTap: () {
                      setState(() { _selectedId = s.id; _selectedName = s.name; });
                      Navigator.pop(context);
                    });
                }),
            ])),
          ]))));
  }
}
