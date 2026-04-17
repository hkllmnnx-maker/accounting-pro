import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'invoice_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _query = '';
  String _filter = 'all'; // all, paid, unpaid

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final allSales = provider.sales;
        final sales = allSales.where((inv) {
          // Search filter
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            if (!inv.contactName.toLowerCase().contains(q) &&
                !inv.id.toLowerCase().contains(q) &&
                !inv.notes.toLowerCase().contains(q)) {
              return false;
            }
          }
          // Payment filter
          if (_filter == 'paid' && inv.remaining > 0.01) return false;
          if (_filter == 'unpaid' && inv.remaining <= 0.01) return false;
          return true;
        }).toList();

        final totalSales = sales.fold(0.0, (s, i) => s + i.totalAmount);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('المبيعات'),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const InvoiceScreen(type: 'sale'))),
              icon: const Icon(Icons.add),
              label: const Text('فاتورة بيع'),
              backgroundColor: Colors.green,
            ),
            body: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.withValues(alpha: 0.05),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [
                    Text('${sales.length}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('عدد الفواتير', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                  Column(children: [
                    Text(formatCurrency(totalSales),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('إجمالي المبيعات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ]),
              ),
              SearchField(
                hint: 'بحث عن اسم العميل أو رقم الفاتورة...',
                onChanged: (v) => setState(() => _query = v),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  _filterChip('all', 'الكل', Colors.blue),
                  const SizedBox(width: 8),
                  _filterChip('paid', 'مدفوعة', Colors.green),
                  const SizedBox(width: 8),
                  _filterChip('unpaid', 'غير مدفوعة', Colors.red),
                ]),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: sales.isEmpty
                    ? EmptyState(
                        message: allSales.isEmpty ? 'لا يوجد مبيعات' : 'لا توجد نتائج',
                        icon: Icons.point_of_sale)
                    : ListView.builder(
                        itemCount: sales.length,
                        itemBuilder: (_, i) => _buildInvoiceCard(context, sales[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _filterChip(String value, String label, Color color) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: color.withValues(alpha: 0.3),
      labelStyle: TextStyle(color: selected ? color : null, fontWeight: selected ? FontWeight.bold : null),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice inv, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Icon(Icons.receipt, color: Colors.green.shade700, size: 20)),
        title: Row(children: [
          Expanded(
              child: Text(inv.contactName.isNotEmpty ? inv.contactName : 'بدون عميل',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(formatCurrency(inv.totalAmount),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ]),
        subtitle: Row(children: [
          Text('${inv.items.length} أصناف', style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatDate(inv.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (inv.remaining > 0) ...[
            const Text(' | ', style: TextStyle(color: Colors.grey)),
            Text('متبقي: ${formatCurrency(inv.remaining)}',
                style: const TextStyle(fontSize: 11, color: Colors.red)),
          ],
        ]),
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => InvoiceScreen(type: 'sale', invoice: inv))),
        onLongPress: () async {
          if (await confirmDelete(context, 'فاتورة #${inv.id.substring(0, 6)}')) {
            provider.deleteSale(inv.id);
          }
        },
      ),
    );
  }
}
