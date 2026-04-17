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
    return InkWell(
      onTap: () => _editItem(index, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                '${item.quantity} × ${formatCurrency(item.price)}'
                '${item.discount > 0 ? ' - خصم ${formatCurrency(item.discount)}' : ''}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ]),
          ),
          Text(formatCurrency(item.total), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.edit, size: 16, color: Colors.blue),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => setState(() => _items.removeAt(index)),
          ),
        ]),
      ),
    );
  }

  void _editItem(int index, InvoiceItem item) {
    final qtyC = TextEditingController(text: item.quantity.toString());
    final priceC = TextEditingController(text: item.price.toString());
    final discC = TextEditingController(text: item.discount.toString());
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(item.productName),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            AppTextField(label: 'الكمية', controller: qtyC, keyboardType: TextInputType.number),
            AppTextField(label: 'السعر', controller: priceC, keyboardType: TextInputType.number),
            AppTextField(label: 'الخصم', controller: discC, keyboardType: TextInputType.number),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item.quantity = int.tryParse(qtyC.text) ?? item.quantity;
                  item.price = double.tryParse(priceC.text) ?? item.price;
                  item.discount = double.tryParse(discC.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
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
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = contacts.where((c) {
            final name = isSale ? (c as Client).name : (c as Supplier).name;
            return name.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          'اختر ${isSale ? "عميل" : "مورد"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('جديد'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _addNewContact(context, provider);
                        },
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'بحث...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      onChanged: (v) => setModalState(() => searchQuery = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(searchQuery.isEmpty
                                    ? 'لا يوجد ${isSale ? "عملاء" : "موردين"}'
                                    : 'لا توجد نتائج'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final c = filtered[i];
                              final name = isSale ? (c as Client).name : (c as Supplier).name;
                              final id = isSale ? (c as Client).id : (c as Supplier).id;
                              final phone = isSale ? (c as Client).phone : (c as Supplier).phone;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isSale
                                      ? Colors.blue.shade100
                                      : Colors.orange.shade100,
                                  child: Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: TextStyle(
                                      color: isSale ? Colors.blue.shade700 : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                                title: Text(name),
                                subtitle: phone.isNotEmpty ? Text(phone) : null,
                                onTap: () {
                                  setState(() {
                                    _contactId = id;
                                    _contactName = name;
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addNewContact(BuildContext context, AppProvider provider) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('إضافة ${isSale ? "عميل" : "مورد"} سريع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'الاسم *', controller: nameC),
              AppTextField(label: 'الهاتف', controller: phoneC, keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.trim().isEmpty) return;
                final id = provider.generateId();
                if (isSale) {
                  provider.saveClient(Client(id: id, name: nameC.text.trim(), phone: phoneC.text.trim()));
                } else {
                  provider.saveSupplier(Supplier(id: id, name: nameC.text.trim(), phone: phoneC.text.trim()));
                }
                setState(() {
                  _contactId = id;
                  _contactName = nameC.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('حفظ واختيار'),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(BuildContext context, AppProvider provider) {
    final products = provider.products;
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = products.where((p) {
            final q = searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q) ||
                p.barcode.toLowerCase().contains(q);
          }).toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('اختر منتج',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'بحث بالاسم أو الفئة أو الباركود...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      onChanged: (v) => setModalState(() => searchQuery = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('لا توجد منتجات'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final p = filtered[i];
                              final outOfStock = isSale && p.quantity <= 0;
                              final lowStock = isSale && p.quantity > 0 && p.quantity < 5;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: outOfStock
                                      ? Colors.red.shade100
                                      : lowStock
                                          ? Colors.orange.shade100
                                          : Colors.teal.shade100,
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: outOfStock
                                        ? Colors.red
                                        : lowStock
                                            ? Colors.orange
                                            : Colors.teal,
                                  ),
                                ),
                                title: Text(p.name),
                                subtitle: Row(
                                  children: [
                                    Text('سعر: ${formatCurrency(isSale ? p.sellPrice : p.buyPrice)}'),
                                    const Text(' | '),
                                    Text(
                                      'مخزون: ${p.quantity}',
                                      style: TextStyle(
                                        color: outOfStock
                                            ? Colors.red
                                            : lowStock
                                                ? Colors.orange
                                                : null,
                                        fontWeight: outOfStock || lowStock ? FontWeight.bold : null,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onTap: () {
                                  setState(() => _items.add(InvoiceItem(
                                        productId: p.id,
                                        productName: p.name,
                                        quantity: 1,
                                        price: isSale ? p.sellPrice : p.buyPrice,
                                      )));
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save(AppProvider provider) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف صنفاً واحداً على الأقل'), backgroundColor: Colors.red));
      return;
    }
    if (_contactName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اختر ${isSale ? "عميل" : "مورد"} أولاً'), backgroundColor: Colors.red));
      return;
    }
    // تحذير عند تجاوز المخزون في البيع
    if (isSale && widget.invoice == null) {
      final Map<String, int> required = {};
      for (var it in _items) {
        required[it.productId] = (required[it.productId] ?? 0) + it.quantity;
      }
      final List<String> warnings = [];
      for (var entry in required.entries) {
        final p = provider.products.firstWhere(
          (x) => x.id == entry.key,
          orElse: () => Product(id: '', name: ''),
        );
        if (p.id.isNotEmpty && p.quantity < entry.value) {
          warnings.add('${p.name}: متاح ${p.quantity} - مطلوب ${entry.value}');
        }
      }
      if (warnings.isNotEmpty) {
        showDialog(
          context: context,
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تحذير: الكمية في المخزون غير كافية'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: warnings.map((w) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• $w'),
                )).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _doSave(provider);
                  },
                  child: const Text('متابعة رغم ذلك'),
                ),
              ],
            ),
          ),
        );
        return;
      }
    }
    _doSave(provider);
  }

  void _doSave(AppProvider provider) {
    final inv = Invoice(
      id: widget.invoice?.id ?? provider.generateId(),
      type: widget.type, contactId: _contactId, contactName: _contactName,
      items: _items, discount: discount, tax: taxRate, paid: paid,
      notes: _notesC.text, date: DateTime.now(),
      createdAt: widget.invoice?.createdAt ?? DateTime.now(),
    );
    if (isSale) {
      provider.saveSale(inv, oldInvoice: widget.invoice);
    } else {
      provider.savePurchase(inv, oldInvoice: widget.invoice);
    }
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
