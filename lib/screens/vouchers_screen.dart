import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});
  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabC;

  @override
  void initState() { super.initState(); _tabC = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final receipts = provider.vouchers.where((v) => v.type == 'receipt').toList();
        final payments = provider.vouchers.where((v) => v.type == 'payment').toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('سندات القبض والصرف'),
              backgroundColor: Colors.indigo, foregroundColor: Colors.white,
              bottom: TabBar(controller: _tabC, indicatorColor: Colors.white,
                labelColor: Colors.white, unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'سندات القبض (${receipts.length})'),
                  Tab(text: 'سندات الصرف (${payments.length})'),
                ]),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add), label: const Text('سند جديد')),
            body: TabBarView(controller: _tabC, children: [
              _buildList(context, receipts, provider, 'receipt'),
              _buildList(context, payments, provider, 'payment'),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<Voucher> vouchers, AppProvider provider, String type) {
    if (vouchers.isEmpty) {
      return EmptyState(
        message: type == 'receipt' ? 'لا يوجد سندات قبض' : 'لا يوجد سندات صرف',
        icon: Icons.receipt);
    }
    final total = vouchers.fold(0.0, (s, v) => s + v.amount);
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        color: (type == 'receipt' ? Colors.green : Colors.red).withValues(alpha: 0.05),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('الإجمالي: ${formatCurrency(total)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: type == 'receipt' ? Colors.green : Colors.red)),
        ]),
      ),
      Expanded(child: ListView.builder(
        itemCount: vouchers.length,
        itemBuilder: (_, i) => _buildCard(context, vouchers[i], provider))),
    ]);
  }

  Widget _buildCard(BuildContext context, Voucher voucher, AppProvider provider) {
    final isReceipt = voucher.type == 'receipt';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isReceipt ? Colors.green : Colors.red).withValues(alpha: 0.15),
          child: Icon(isReceipt ? Icons.arrow_downward : Icons.arrow_upward,
            color: isReceipt ? Colors.green : Colors.red, size: 20)),
        title: Text(voucher.contactName.isNotEmpty ? voucher.contactName : 'غير محدد',
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(children: [
          Text(voucher.paymentMethod.isNotEmpty ? voucher.paymentMethod : 'نقدي',
            style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatDate(voucher.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        trailing: Text(formatCurrency(voucher.amount),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14,
            color: isReceipt ? Colors.green : Colors.red)),
        onTap: () => _showForm(context, provider, voucher: voucher),
        onLongPress: () async {
          if (await confirmDelete(context, isReceipt ? "سند قبض" : "سند صرف")) {
            provider.deleteVoucher(voucher.id);
          }
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Voucher? voucher}) {
    String type = voucher?.type ?? 'receipt';
    String contactType = voucher?.contactType ?? 'client';
    String contactId = voucher?.contactId ?? '';
    String contactName = voucher?.contactName ?? '';
    final amountC = TextEditingController(text: voucher?.amount.toString() ?? '0');
    String paymentMethod = voucher?.paymentMethod ?? 'نقدي';
    final notesC = TextEditingController(text: voucher?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Form(key: formKey, child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(voucher == null ? 'سند جديد' : 'تعديل سند',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Type selection
                Row(children: [
                  Expanded(child: ChoiceChip(label: const Text('سند قبض'), selected: type == 'receipt',
                    selectedColor: Colors.green.shade100,
                    onSelected: (_) => setModalState(() => type = 'receipt'))),
                  const SizedBox(width: 8),
                  Expanded(child: ChoiceChip(label: const Text('سند صرف'), selected: type == 'payment',
                    selectedColor: Colors.red.shade100,
                    onSelected: (_) => setModalState(() => type = 'payment'))),
                ]),
                const SizedBox(height: 12),
                // Contact type
                Row(children: [
                  Expanded(child: ChoiceChip(label: const Text('عميل'), selected: contactType == 'client',
                    onSelected: (_) => setModalState(() { contactType = 'client'; contactId = ''; contactName = ''; }))),
                  const SizedBox(width: 8),
                  Expanded(child: ChoiceChip(label: const Text('مورد'), selected: contactType == 'supplier',
                    onSelected: (_) => setModalState(() { contactType = 'supplier'; contactId = ''; contactName = ''; }))),
                ]),
                const SizedBox(height: 12),
                // Contact selection
                InkWell(
                  onTap: () {
                    final contacts = contactType == 'client' ? provider.clients : provider.suppliers;
                    showModalBottomSheet(context: ctx,
                      builder: (_) => Directionality(textDirection: TextDirection.rtl,
                        child: ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (_, i) {
                            final c = contacts[i];
                            final n = contactType == 'client' ? (c as Client).name : (c as Supplier).name;
                            final cid = contactType == 'client' ? (c as Client).id : (c as Supplier).id;
                            return ListTile(title: Text(n), onTap: () {
                              setModalState(() { contactId = cid; contactName = n; });
                              Navigator.pop(ctx);
                            });
                          })));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(contactName.isEmpty ? 'اختر الحساب...' : contactName)),
                      const Icon(Icons.arrow_drop_down),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(label: 'المبلغ *', controller: amountC, keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty || (double.tryParse(v) ?? 0) <= 0 ? 'أدخل مبلغ صحيح' : null),
                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                  items: ['نقدي', 'تحويل بنكي', 'شيك', 'بطاقة'].map((m) =>
                    DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setModalState(() => paymentMethod = v ?? 'نقدي'),
                ),
                const SizedBox(height: 12),
                AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    provider.saveVoucher(Voucher(
                      id: voucher?.id ?? provider.generateId(),
                      type: type, contactId: contactId, contactName: contactName,
                      contactType: contactType, amount: double.tryParse(amountC.text) ?? 0,
                      paymentMethod: paymentMethod, notes: notesC.text,
                      date: voucher?.date ?? DateTime.now(),
                      createdAt: voucher?.createdAt ?? DateTime.now()));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'receipt' ? Colors.green : Colors.red,
                    foregroundColor: Colors.white),
                  child: Text(voucher == null ? 'إضافة' : 'حفظ'))),
              ])))))));
  }
}
