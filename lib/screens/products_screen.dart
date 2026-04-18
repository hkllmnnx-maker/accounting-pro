import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/pdf_service.dart';
import '../widgets/common_widgets.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _search = '';
  String _filter = 'all'; // all, low, out, zero_margin

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final allProducts = provider.products;
        final lowStockCount = allProducts.where((p) => p.quantity > 0 && p.quantity < 5).length;
        final outOfStockCount = allProducts.where((p) => p.quantity <= 0).length;

        final products = allProducts.where((p) {
          final matchSearch = p.name.contains(_search) ||
              p.category.contains(_search) ||
              p.barcode.contains(_search);
          if (!matchSearch) return false;
          if (_filter == 'low' && !(p.quantity > 0 && p.quantity < 5)) return false;
          if (_filter == 'out' && p.quantity > 0) return false;
          if (_filter == 'zero_margin' && (p.sellPrice - p.buyPrice) > 0) return false;
          return true;
        }).toList();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('المنتجات والمخزون'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.insights),
                  tooltip: 'لوحة KPI',
                  onPressed: () => _showKpiDashboard(context, allProducts, provider),
                ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'تصدير تقرير PDF',
                  onPressed: () => _exportInventoryPdf(provider, allProducts),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
            ),
            body: Column(children: [
              SearchField(hint: 'بحث عن منتج...', onChanged: (v) => setState(() => _search = v)),
              // KPI Cards row
              _buildKpiRow(allProducts),
              if (lowStockCount > 0 || outOfStockCount > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تنبيه: $lowStockCount منتج مخزون منخفض، $outOfStockCount منتج نافد',
                        style: const TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ]),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _filterChip('all', 'الكل', Colors.blue),
                    const SizedBox(width: 8),
                    _filterChip('low', 'مخزون منخفض', Colors.orange),
                    const SizedBox(width: 8),
                    _filterChip('out', 'نافد', Colors.red),
                    const SizedBox(width: 8),
                    _filterChip('zero_margin', 'بدون هامش ربح', Colors.deepPurple),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: products.isEmpty
                    ? EmptyState(
                        message: allProducts.isEmpty ? 'لا يوجد منتجات' : 'لا توجد نتائج',
                        icon: Icons.inventory_2)
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (_, i) => _buildCard(context, products[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildKpiRow(List<Product> allProducts) {
    final totalQty = allProducts.fold(0, (s, p) => s + p.quantity);
    final stockCost = allProducts.fold(0.0, (s, p) => s + (p.buyPrice * p.quantity));
    final stockValue = allProducts.fold(0.0, (s, p) => s + (p.sellPrice * p.quantity));
    final potentialProfit = stockValue - stockCost;
    final margin = stockValue > 0 ? (potentialProfit / stockValue) * 100 : 0.0;

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          _kpiCard('المنتجات', '${allProducts.length}', Icons.inventory_2, Colors.teal),
          _kpiCard('إجمالي الكمية', '$totalQty', Icons.numbers, Colors.blue),
          _kpiCard('تكلفة المخزون', formatCurrency(stockCost), Icons.payments, Colors.orange),
          _kpiCard('قيمة المخزون', formatCurrency(stockValue), Icons.account_balance, Colors.green),
          _kpiCard('ربح متوقع', formatCurrency(potentialProfit), Icons.trending_up, Colors.indigo),
          _kpiCard('هامش الربح', '${margin.toStringAsFixed(1)}%', Icons.percent, Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 18),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
              overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showKpiDashboard(BuildContext context, List<Product> products, AppProvider provider) {
    // Group by category
    final Map<String, List<Product>> byCat = {};
    for (var p in products) {
      byCat.putIfAbsent(p.category.isEmpty ? 'بدون تصنيف' : p.category, () => []).add(p);
    }
    // Top 5 by value
    final sortedByValue = [...products]
      ..sort((a, b) => (b.sellPrice * b.quantity).compareTo(a.sellPrice * a.quantity));
    final top5 = sortedByValue.take(5).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollCtrl) => Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollCtrl,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('لوحة مؤشرات الأداء (KPI)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                _sectionTitle('أعلى 5 منتجات بالقيمة', Icons.emoji_events, Colors.amber),
                ...top5.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final value = p.sellPrice * p.quantity;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _rankColor(i).withValues(alpha: 0.2),
                        child: Text('${i + 1}',
                            style: TextStyle(color: _rankColor(i), fontWeight: FontWeight.bold)),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('الكمية: ${p.quantity} ${p.unit}'),
                      trailing: Text('${formatCurrency(value)} ${provider.currency}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                _sectionTitle('توزيع المنتجات حسب الفئة', Icons.category, Colors.blue),
                ...byCat.entries.map((e) {
                  final catValue = e.value.fold(0.0, (s, p) => s + (p.sellPrice * p.quantity));
                  final catQty = e.value.fold(0, (s, p) => s + p.quantity);
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.15),
                        child: const Icon(Icons.category, color: Colors.blue),
                      ),
                      title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${e.value.length} منتج • $catQty قطعة'),
                      trailing: Text(formatCurrency(catValue),
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _rankColor(int i) {
    switch (i) {
      case 0: return Colors.amber;
      case 1: return Colors.grey;
      case 2: return Colors.brown;
      default: return Colors.blueGrey;
    }
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _filterChip(String value, String label, Color color) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: color.withValues(alpha: 0.3),
      labelStyle: TextStyle(
          color: selected ? color : null,
          fontWeight: selected ? FontWeight.bold : null),
    );
  }

  Widget _buildCard(BuildContext context, Product product, AppProvider provider) {
    final isOut = product.quantity <= 0;
    final isLow = product.quantity > 0 && product.quantity < 5;
    final badgeColor = isOut ? Colors.red : (isLow ? Colors.orange : Colors.teal);
    final badgeLabel = isOut ? 'نافد' : (isLow ? 'مخزون منخفض' : '');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: badgeColor.withValues(alpha: 0.15),
          child: Icon(Icons.inventory_2, color: badgeColor, size: 20)),
        title: Row(children: [
          Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (badgeLabel.isNotEmpty) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(badgeLabel, style: TextStyle(fontSize: 9, color: badgeColor))),
        ]),
        subtitle: Row(children: [
          Text('شراء: ${formatCurrency(product.buyPrice)}', style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(fontSize: 11, color: Colors.grey)),
          Text('بيع: ${formatCurrency(product.sellPrice)}', style: const TextStyle(fontSize: 11, color: Colors.green)),
          const Text(' | ', style: TextStyle(fontSize: 11, color: Colors.grey)),
          Text(product.category, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${product.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
            color: badgeColor)),
          Text(product.unit.isNotEmpty ? product.unit : 'قطعة', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        onTap: () => _showForm(context, provider, product: product),
        onLongPress: () async {
          if (await confirmDelete(context, product.name)) provider.deleteProduct(product.id);
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Product? product}) {
    final nameC = TextEditingController(text: product?.name ?? '');
    final catC = TextEditingController(text: product?.category ?? '');
    final buyC = TextEditingController(text: product?.buyPrice.toString() ?? '0');
    final sellC = TextEditingController(text: product?.sellPrice.toString() ?? '0');
    final qtyC = TextEditingController(text: product?.quantity.toString() ?? '0');
    final unitC = TextEditingController(text: product?.unit ?? '');
    final barC = TextEditingController(text: product?.barcode ?? '');
    final notesC = TextEditingController(text: product?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(key: formKey, child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(product == null ? 'إضافة منتج' : 'تعديل منتج',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppTextField(label: 'اسم المنتج *', controller: nameC,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              Row(children: [
                Expanded(child: AppTextField(label: 'التصنيف', controller: catC)),
                const SizedBox(width: 8),
                Expanded(child: AppTextField(label: 'الوحدة', controller: unitC)),
              ]),
              Row(children: [
                Expanded(child: AppTextField(label: 'سعر الشراء', controller: buyC, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: AppTextField(label: 'سعر البيع', controller: sellC, keyboardType: TextInputType.number)),
              ]),
              Row(children: [
                Expanded(child: AppTextField(label: 'الكمية', controller: qtyC, keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: AppTextField(label: 'الباركود', controller: barC)),
              ]),
              AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  provider.saveProduct(Product(
                    id: product?.id ?? provider.generateId(),
                    name: nameC.text, category: catC.text,
                    buyPrice: double.tryParse(buyC.text) ?? 0,
                    sellPrice: double.tryParse(sellC.text) ?? 0,
                    quantity: int.tryParse(qtyC.text) ?? 0,
                    unit: unitC.text, barcode: barC.text, notes: notesC.text,
                    createdAt: product?.createdAt ?? DateTime.now()));
                  Navigator.pop(context);
                },
                child: Text(product == null ? 'إضافة' : 'حفظ'))),
            ]))))));
  }

  Future<void> _exportInventoryPdf(AppProvider provider, List<Product> products) async {
    try {
      final doc = await PdfService.generateInventoryReport(
        companyName: provider.companyName,
        currency: provider.currency,
        products: products,
      );
      await PdfService.printInvoice(doc, 'Inventory-Report');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
