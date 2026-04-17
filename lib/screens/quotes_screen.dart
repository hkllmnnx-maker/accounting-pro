import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});
  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabC;

  @override
  void initState() { super.initState(); _tabC = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final quotes = provider.quotes.where((q) => q.type == 'quote').toList();
        final orders = provider.quotes.where((q) => q.type == 'order').toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('العروض والطلبات'),
              backgroundColor: Colors.pink, foregroundColor: Colors.white,
              bottom: TabBar(controller: _tabC, indicatorColor: Colors.white,
                labelColor: Colors.white, unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'عروض الأسعار (${quotes.length})'),
                  Tab(text: 'الطلبات (${orders.length})'),
                ]),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('إنشاء جديد'),
              backgroundColor: Colors.pink),
            body: TabBarView(controller: _tabC, children: [
              _buildList(context, quotes, provider),
              _buildList(context, orders, provider),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<Quote> items, AppProvider provider) {
    if (items.isEmpty) {
      return const EmptyState(message: 'لا يوجد عناصر', icon: Icons.request_quote);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildCard(context, items[i], provider));
  }

  Widget _buildCard(BuildContext context, Quote quote, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: Icon(quote.type == 'quote' ? Icons.request_quote : Icons.shopping_bag,
            color: Colors.pink.shade700, size: 20)),
        title: Row(children: [
          Expanded(child: Text(quote.contactName.isNotEmpty ? quote.contactName : 'غير محدد',
            style: const TextStyle(fontWeight: FontWeight.bold))),
          StatusBadge(status: quote.status),
        ]),
        subtitle: Row(children: [
          Text('${quote.items.length} أصناف', style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatCurrency(quote.totalAmount),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.pink.shade700)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatDate(quote.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        onTap: () => _showForm(context, provider, quote: quote),
        onLongPress: () async {
          final action = await showModalBottomSheet<String>(context: context,
            builder: (_) => Directionality(textDirection: TextDirection.rtl,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text('تعديل'),
                  onTap: () => Navigator.pop(context, 'edit')),
                if (quote.status == 'pending') ...[
                  ListTile(leading: const Icon(Icons.check, color: Colors.green), title: const Text('قبول'),
                    onTap: () => Navigator.pop(context, 'approve')),
                  ListTile(leading: const Icon(Icons.close, color: Colors.red), title: const Text('رفض'),
                    onTap: () => Navigator.pop(context, 'reject')),
                ],
                if (quote.status == 'approved' && quote.type == 'quote')
                  ListTile(leading: const Icon(Icons.transform, color: Colors.blue), title: const Text('تحويل لفاتورة'),
                    onTap: () => Navigator.pop(context, 'convert')),
                ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text('حذف'),
                  onTap: () => Navigator.pop(context, 'delete')),
              ])));
          if (!context.mounted) return;
          if (action == 'edit') _showForm(context, provider, quote: quote);
          if (action == 'approve') {
            final updated = Quote(id: quote.id, type: quote.type, contactId: quote.contactId,
              contactName: quote.contactName, items: quote.items, discount: quote.discount,
              tax: quote.tax, status: 'approved', notes: quote.notes, date: quote.date,
              validUntil: quote.validUntil, createdAt: quote.createdAt);
            provider.saveQuote(updated);
          }
          if (action == 'reject') {
            final updated = Quote(id: quote.id, type: quote.type, contactId: quote.contactId,
              contactName: quote.contactName, items: quote.items, discount: quote.discount,
              tax: quote.tax, status: 'rejected', notes: quote.notes, date: quote.date,
              validUntil: quote.validUntil, createdAt: quote.createdAt);
            provider.saveQuote(updated);
          }
          if (action == 'convert') {
            final inv = Invoice(id: provider.generateId(), type: 'sale',
              contactId: quote.contactId, contactName: quote.contactName,
              items: quote.items, discount: quote.discount, tax: quote.tax);
            provider.saveSale(inv);
            final updated = Quote(id: quote.id, type: quote.type, contactId: quote.contactId,
              contactName: quote.contactName, items: quote.items, discount: quote.discount,
              tax: quote.tax, status: 'converted', notes: quote.notes, date: quote.date,
              validUntil: quote.validUntil, createdAt: quote.createdAt);
            provider.saveQuote(updated);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحويل العرض إلى فاتورة بيع'), backgroundColor: Colors.green));
            }
          }
          if (action == 'delete' && await confirmDelete(context, quote.type == 'quote' ? 'العرض' : 'الطلب')) {
            provider.deleteQuote(quote.id);
          }
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Quote? quote}) {
    String type = quote?.type ?? 'quote';
    String contactId = quote?.contactId ?? '';
    String contactName = quote?.contactName ?? '';
    List<InvoiceItem> items = quote?.items.map((i) => InvoiceItem(
      productId: i.productId, productName: i.productName,
      quantity: i.quantity, price: i.price, discount: i.discount)).toList() ?? [];
    final discountC = TextEditingController(text: quote?.discount.toString() ?? '0');
    final taxC = TextEditingController(text: quote?.tax.toString() ?? '15');
    final notesC = TextEditingController(text: quote?.notes ?? '');

    showDialog(context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final subtotal = items.fold(0.0, (s, i) => s + i.total);
          final disc = double.tryParse(discountC.text) ?? 0;
          final taxRate = double.tryParse(taxC.text) ?? 0;
          final total = subtotal - disc + (subtotal * taxRate / 100);

          return Directionality(textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(quote == null ? 'إنشاء جديد' : 'تعديل'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Type
                    Row(children: [
                      Expanded(child: ChoiceChip(label: const Text('عرض سعر'), selected: type == 'quote',
                        selectedColor: Colors.pink.shade100,
                        onSelected: (_) => setDialogState(() => type = 'quote'))),
                      const SizedBox(width: 8),
                      Expanded(child: ChoiceChip(label: const Text('طلب'), selected: type == 'order',
                        selectedColor: Colors.blue.shade100,
                        onSelected: (_) => setDialogState(() => type = 'order'))),
                    ]),
                    const SizedBox(height: 12),
                    // Contact
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(context: ctx,
                          builder: (_) => Directionality(textDirection: TextDirection.rtl,
                            child: ListView.builder(
                              itemCount: provider.clients.length,
                              itemBuilder: (_, i) {
                                final c = provider.clients[i];
                                return ListTile(title: Text(c.name), onTap: () {
                                  setDialogState(() { contactId = c.id; contactName = c.name; });
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
                          Expanded(child: Text(contactName.isEmpty ? 'اختر عميل...' : contactName)),
                          const Icon(Icons.arrow_drop_down),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Items
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('الأصناف', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(context: ctx,
                            builder: (_) => Directionality(textDirection: TextDirection.rtl,
                              child: ListView.builder(
                                itemCount: provider.products.length,
                                itemBuilder: (_, i) {
                                  final p = provider.products[i];
                                  return ListTile(
                                    title: Text(p.name),
                                    subtitle: Text('سعر: ${formatCurrency(p.sellPrice)}'),
                                    onTap: () {
                                      setDialogState(() => items.add(InvoiceItem(
                                        productId: p.id, productName: p.name,
                                        quantity: 1, price: p.sellPrice)));
                                      Navigator.pop(ctx);
                                    });
                                })));
                        },
                        icon: const Icon(Icons.add, size: 16), label: const Text('إضافة')),
                    ]),
                    ...items.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        Expanded(child: Text('${e.value.productName} (${e.value.quantity} × ${formatCurrency(e.value.price)})',
                          style: const TextStyle(fontSize: 12))),
                        Text(formatCurrency(e.value.total), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close, size: 14, color: Colors.red),
                          onPressed: () => setDialogState(() => items.removeAt(e.key))),
                      ]),
                    )),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextField(controller: discountC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الخصم', isDense: true))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: taxC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الضريبة %', isDense: true))),
                    ]),
                    const SizedBox(height: 8),
                    TextField(controller: notesC, textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(labelText: 'ملاحظات', isDense: true)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(formatCurrency(total), style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16, color: Colors.pink.shade700)),
                      ]),
                    ),
                  ]),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    provider.saveQuote(Quote(
                      id: quote?.id ?? provider.generateId(),
                      type: type, contactId: contactId, contactName: contactName,
                      items: items, discount: double.tryParse(discountC.text) ?? 0,
                      tax: double.tryParse(taxC.text) ?? 0,
                      status: quote?.status ?? 'pending', notes: notesC.text,
                      date: quote?.date ?? DateTime.now(),
                      createdAt: quote?.createdAt ?? DateTime.now()));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  child: Text(quote == null ? 'إنشاء' : 'حفظ')),
              ],
            ));
        }));
  }
}
