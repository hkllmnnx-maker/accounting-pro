import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'account_statement_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});
  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final suppliers = provider.suppliers
            .where((s) => s.name.contains(_search) || s.phone.contains(_search)).toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('الموردين'),
              backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add), label: const Text('إضافة مورد')),
            body: Column(
              children: [
                SearchField(hint: 'بحث عن مورد...', onChanged: (v) => setState(() => _search = v)),
                Expanded(
                  child: suppliers.isEmpty
                      ? const EmptyState(message: 'لا يوجد موردين', icon: Icons.local_shipping)
                      : ListView.builder(
                          itemCount: suppliers.length,
                          itemBuilder: (_, i) => _buildCard(context, suppliers[i], provider)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Supplier supplier, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Text(supplier.name.isNotEmpty ? supplier.name[0] : '?',
            style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold))),
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (supplier.phone.isNotEmpty) Text(supplier.phone, style: const TextStyle(fontSize: 12)),
          if (supplier.address.isNotEmpty) Text(supplier.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(formatCurrency(supplier.balance), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
            color: supplier.balance >= 0 ? Colors.red : Colors.green)),
          const Text('مستحق', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        onTap: () => _showForm(context, provider, supplier: supplier),
        onLongPress: () async {
          final action = await showModalBottomSheet<String>(context: context,
            builder: (_) => Directionality(textDirection: TextDirection.rtl,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('تعديل'),
                  onTap: () => Navigator.pop(context, 'edit')),
                ListTile(leading: const Icon(Icons.account_balance, color: Colors.brown), title: const Text('كشف حساب'),
                  onTap: () => Navigator.pop(context, 'statement')),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('حذف'),
                  onTap: () => Navigator.pop(context, 'delete')),
              ])));
          if (!context.mounted) return;
          if (action == 'edit') _showForm(context, provider, supplier: supplier);
          if (action == 'statement') {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => AccountStatementScreen(contactId: supplier.id, contactName: supplier.name)));
          }
          if (action == 'delete' && await confirmDelete(context, supplier.name)) provider.deleteSupplier(supplier.id);
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Supplier? supplier}) {
    final nameC = TextEditingController(text: supplier?.name ?? '');
    final phoneC = TextEditingController(text: supplier?.phone ?? '');
    final addressC = TextEditingController(text: supplier?.address ?? '');
    final balanceC = TextEditingController(text: supplier?.balance.toString() ?? '0');
    final notesC = TextEditingController(text: supplier?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(key: formKey, child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(supplier == null ? 'إضافة مورد' : 'تعديل مورد',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppTextField(label: 'الاسم *', controller: nameC,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              AppTextField(label: 'الهاتف', controller: phoneC, keyboardType: TextInputType.phone),
              AppTextField(label: 'العنوان', controller: addressC),
              AppTextField(label: 'الرصيد', controller: balanceC, keyboardType: TextInputType.number),
              AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  provider.saveSupplier(Supplier(
                    id: supplier?.id ?? provider.generateId(),
                    name: nameC.text, phone: phoneC.text, address: addressC.text,
                    balance: double.tryParse(balanceC.text) ?? 0, notes: notesC.text,
                    createdAt: supplier?.createdAt ?? DateTime.now()));
                  Navigator.pop(context);
                },
                child: Text(supplier == null ? 'إضافة' : 'حفظ'))),
            ]))))));
  }
}
