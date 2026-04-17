import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final products = provider.products
            .where((p) => p.name.contains(_search) || p.category.contains(_search) || p.barcode.contains(_search)).toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('المنتجات والمخزون'),
              backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add), label: const Text('إضافة منتج')),
            body: Column(children: [
              SearchField(hint: 'بحث عن منتج...', onChanged: (v) => setState(() => _search = v)),
              // Summary row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.teal.withValues(alpha: 0.05),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _statChip('المنتجات', '${products.length}', Colors.teal),
                  _statChip('إجمالي المخزون', '${products.fold(0, (s, p) => s + p.quantity)}', Colors.blue),
                  _statChip('قيمة المخزون', formatCurrency(products.fold(0.0, (s, p) => s + (p.sellPrice * p.quantity))), Colors.green),
                ]),
              ),
              Expanded(
                child: products.isEmpty
                    ? const EmptyState(message: 'لا يوجد منتجات', icon: Icons.inventory_2)
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

  Widget _statChip(String label, String value, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }

  Widget _buildCard(BuildContext context, Product product, AppProvider provider) {
    final isLow = product.quantity < 5;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLow ? Colors.red.shade100 : Colors.teal.shade100,
          child: Icon(Icons.inventory_2, color: isLow ? Colors.red : Colors.teal, size: 20)),
        title: Row(children: [
          Expanded(child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (isLow) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Text('مخزون منخفض', style: TextStyle(fontSize: 9, color: Colors.red))),
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
            color: isLow ? Colors.red : Colors.teal)),
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
}
