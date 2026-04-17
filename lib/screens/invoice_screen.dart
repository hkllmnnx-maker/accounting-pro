import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../services/pdf_service.dart';

class InvoiceScreen extends StatefulWidget {
  final String type;
  final Invoice? invoice;
  const InvoiceScreen({super.key, required this.type, this.invoice});
  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _contactId = '';
  String _contactName = '';
  final List<InvoiceItem> _items = [];
  final _discountC = TextEditingController(text: '0');
  final _taxC = TextEditingController(text: '15');
  final _paidC = TextEditingController(text: '0');
  final _notesC = TextEditingController();

  bool get isSale => widget.type == 'sale';

  @override
  void initState() {
    super.initState();
    if (widget.invoice != null) {
      _contactId = widget.invoice!.contactId;
      _contactName = widget.invoice!.contactName;
      _items.addAll(widget.invoice!.items);
      _discountC.text = widget.invoice!.discount.toString();
      _taxC.text = widget.invoice!.tax.toString();
      _paidC.text = widget.invoice!.paid.toString();
      _notesC.text = widget.invoice!.notes;
    }
  }

  double get subtotal => _items.fold(0, (s, i) => s + i.total);
  double get discount => double.tryParse(_discountC.text) ?? 0;
  double get taxRate => double.tryParse(_taxC.text) ?? 0;
  double get taxAmount => subtotal * (taxRate / 100);
  double get totalAmount => subtotal - discount + taxAmount;
  double get paid => double.tryParse(_paidC.text) ?? 0;
  double get remaining => totalAmount - paid;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isSale ? 'فاتورة بيع' : 'فاتورة شراء'),
          backgroundColor: isSale ? Colors.green.shade700 : Colors.orange.shade700,
          foregroundColor: Colors.white,
          actions: [
            if (widget.invoice != null) ...[
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'طباعة',
                onPressed: () => _printInvoice(provider),
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'مشاركة',
                onPressed: () => _shareInvoice(provider),
              ),
            ],
            IconButton(icon: const Icon(Icons.save), onPressed: () => _save(provider)),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Contact Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isSale ? 'العميل' : 'المورد', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectContact(context, provider),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          Icon(Icons.person, color: Colors.grey.shade400),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_contactName.isEmpty ? 'اختر ${isSale ? "عميل" : "مورد"}...' : _contactName,
                            style: TextStyle(color: _contactName.isEmpty ? Colors.grey : null))),
                          const Icon(Icons.arrow_drop_down),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              // Items
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('الأصناف', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => _addItem(context, provider),
                        icon: const Icon(Icons.add, size: 18), label: const Text('إضافة صنف')),
                    ]),
                    if (_items.isEmpty)
                      const Padding(padding: EdgeInsets.all(20),
                        child: Center(child: Text('لا يوجد أصناف', style: TextStyle(color: Colors.grey))))
                    else
                      ..._items.asMap().entries.map((entry) => _buildItemRow(entry.key, entry.value)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              // Totals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    Row(children: [
                      Expanded(child: AppTextField(label: 'الخصم', controller: _discountC,
                        keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: AppTextField(label: 'الضريبة %', controller: _taxC,
                        keyboardType: TextInputType.number)),
                    ]),
                    AppTextField(label: 'المبلغ المدفوع', controller: _paidC,
                      keyboardType: TextInputType.number),
                    AppTextField(label: 'ملاحظات', controller: _notesC, maxLines: 2),
                    const Divider(),
                    _totalRow('المجموع الفرعي', subtotal),
                    _totalRow('الخصم', -discount, color: Colors.red),
                    _totalRow('الضريبة (${taxRate.toStringAsFixed(0)}%)', taxAmount),
                    const Divider(),
                    _totalRow('الإجمالي', totalAmount, isBold: true, size: 16),
                    _totalRow('المدفوع', paid, color: Colors.green),
                    _totalRow('المتبقي', remaining, color: remaining > 0 ? Colors.red : Colors.green, isBold: true),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _save(provider),
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الفاتورة', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSale ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white),
                )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${item.quantity} x ${formatCurrency(item.price)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ),
        Text(formatCurrency(item.total), style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red),
          onPressed: () => setState(() => _items.removeAt(index))),
      ]),
    );
  }

  Widget _totalRow(String label, double value, {Color? color, bool isBold = false, double size = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : null)),
        Text(formatCurrency(value), style: TextStyle(fontSize: size, color: color,
          fontWeight: isBold ? FontWeight.bold : null)),
      ]),
    );
  }

  void _selectContact(BuildContext context, AppProvider provider) {
    final contacts = isSale ? provider.clients : provider.suppliers;
    showModalBottomSheet(context: context,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(12),
            child: Text('اختر ${isSale ? "عميل" : "مورد"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (_, i) {
              final c = contacts[i];
              final name = isSale ? (c as Client).name : (c as Supplier).name;
              final id = isSale ? (c as Client).id : (c as Supplier).id;
              return ListTile(
                title: Text(name),
                onTap: () {
                  setState(() { _contactId = id; _contactName = name; });
                  Navigator.pop(context);
                },
              );
            },
          )),
        ])));
  }

  void _addItem(BuildContext context, AppProvider provider) {
    final products = provider.products;
    showModalBottomSheet(context: context,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: Column(children: [
          const Padding(padding: EdgeInsets.all(12),
            child: Text('اختر منتج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          Expanded(child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text('سعر: ${formatCurrency(isSale ? p.sellPrice : p.buyPrice)} | مخزون: ${p.quantity}'),
                trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                onTap: () {
                  setState(() => _items.add(InvoiceItem(
                    productId: p.id, productName: p.name, quantity: 1,
                    price: isSale ? p.sellPrice : p.buyPrice)));
                  Navigator.pop(context);
                },
              );
            },
          )),
        ])));
  }

  void _save(AppProvider provider) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف صنفاً واحداً على الأقل'), backgroundColor: Colors.red));
      return;
    }
    final inv = Invoice(
      id: widget.invoice?.id ?? provider.generateId(),
      type: widget.type, contactId: _contactId, contactName: _contactName,
      items: _items, discount: discount, tax: taxRate, paid: paid,
      notes: _notesC.text, date: DateTime.now(),
      createdAt: widget.invoice?.createdAt ?? DateTime.now(),
    );
    if (isSale) { provider.saveSale(inv); } else { provider.savePurchase(inv); }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ ${isSale ? "فاتورة البيع" : "فاتورة الشراء"}'),
        backgroundColor: Colors.green));
  }

  Invoice _currentInvoice(AppProvider provider) {
    return Invoice(
      id: widget.invoice?.id ?? provider.generateId(),
      type: widget.type,
      contactId: _contactId,
      contactName: _contactName,
      items: _items,
      discount: discount,
      tax: taxRate,
      paid: paid,
      notes: _notesC.text,
      date: widget.invoice?.date ?? DateTime.now(),
      createdAt: widget.invoice?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _printInvoice(AppProvider provider) async {
    try {
      final inv = _currentInvoice(provider);
      final doc = await PdfService.generateInvoicePdf(
        invoice: inv,
        companyName: provider.companyName,
        companyPhone: provider.companyPhone,
        companyAddress: provider.companyAddress,
        currency: provider.currency,
      );
      await PdfService.printInvoice(doc,
          '${isSale ? "Sale" : "Purchase"}-${inv.id.substring(0, inv.id.length > 8 ? 8 : inv.id.length)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الطباعة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _shareInvoice(AppProvider provider) async {
    try {
      final inv = _currentInvoice(provider);
      final doc = await PdfService.generateInvoicePdf(
        invoice: inv,
        companyName: provider.companyName,
        companyPhone: provider.companyPhone,
        companyAddress: provider.companyAddress,
        currency: provider.currency,
      );
      await PdfService.shareInvoice(doc,
          '${isSale ? "Sale" : "Purchase"}-${inv.id.substring(0, inv.id.length > 8 ? 8 : inv.id.length)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في المشاركة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
