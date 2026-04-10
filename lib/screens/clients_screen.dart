import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'account_statement_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final clients = provider.clients
            .where((c) => c.name.contains(_search) || c.phone.contains(_search))
            .toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('العملاء'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('إضافة عميل'),
            ),
            body: Column(
              children: [
                SearchField(hint: 'بحث عن عميل...', onChanged: (v) => setState(() => _search = v)),
                Expanded(
                  child: clients.isEmpty
                      ? const EmptyState(message: 'لا يوجد عملاء', icon: Icons.people_outline)
                      : ListView.builder(
                          itemCount: clients.length,
                          itemBuilder: (_, i) => _buildClientCard(context, clients[i], provider),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientCard(BuildContext context, Client client, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(client.name.isNotEmpty ? client.name[0] : '?', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
        ),
        title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (client.phone.isNotEmpty) Text(client.phone, style: const TextStyle(fontSize: 12)),
            if (client.address.isNotEmpty) Text(client.address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatCurrency(client.balance), style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13,
              color: client.balance >= 0 ? Colors.green : Colors.red)),
            const Text('الرصيد', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        onTap: () => _showForm(context, provider, client: client),
        onLongPress: () async {
          final action = await showModalBottomSheet<String>(
            context: context,
            builder: (_) => Directionality(
              textDirection: TextDirection.rtl,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('تعديل'),
                  onTap: () => Navigator.pop(context, 'edit')),
                ListTile(leading: const Icon(Icons.account_balance, color: Colors.brown), title: const Text('كشف حساب'),
                  onTap: () => Navigator.pop(context, 'statement')),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('حذف'),
                  onTap: () => Navigator.pop(context, 'delete')),
              ]),
            ),
          );
          if (!context.mounted) return;
          if (action == 'edit') _showForm(context, provider, client: client);
          if (action == 'statement') {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => AccountStatementScreen(contactId: client.id, contactName: client.name)));
          }
          if (action == 'delete') {
            if (await confirmDelete(context, client.name)) provider.deleteClient(client.id);
          }
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Client? client}) {
    final nameC = TextEditingController(text: client?.name ?? '');
    final phoneC = TextEditingController(text: client?.phone ?? '');
    final addressC = TextEditingController(text: client?.address ?? '');
    final balanceC = TextEditingController(text: client?.balance.toString() ?? '0');
    final notesC = TextEditingController(text: client?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(client == null ? 'إضافة عميل' : 'تعديل عميل',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                AppTextField(label: 'الاسم *', controller: nameC,
                  validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
                AppTextField(label: 'الهاتف', controller: phoneC, keyboardType: TextInputType.phone),
                AppTextField(label: 'العنوان', controller: addressC),
                AppTextField(label: 'الرصيد الافتتاحي', controller: balanceC, keyboardType: TextInputType.number),
                AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final c = Client(
                        id: client?.id ?? provider.generateId(),
                        name: nameC.text, phone: phoneC.text,
                        address: addressC.text,
                        balance: double.tryParse(balanceC.text) ?? 0,
                        notes: notesC.text,
                        createdAt: client?.createdAt ?? DateTime.now(),
                      );
                      provider.saveClient(c);
                      Navigator.pop(context);
                    },
                    child: Text(client == null ? 'إضافة' : 'حفظ'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
