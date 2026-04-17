import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'invoice_screen.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final sales = provider.sales;
        final totalSales = sales.fold(0.0, (s, i) => s + i.totalAmount);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('المبيعات'),
              backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const InvoiceScreen(type: 'sale'))),
              icon: const Icon(Icons.add), label: const Text('فاتورة بيع'),
              backgroundColor: Colors.green),
            body: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.withValues(alpha: 0.05),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [
                    Text('${sales.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('عدد الفواتير', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                  Column(children: [
                    Text(formatCurrency(totalSales), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('إجمالي المبيعات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ]),
              ),
              Expanded(
                child: sales.isEmpty
                    ? const EmptyState(message: 'لا يوجد مبيعات', icon: Icons.point_of_sale)
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

  Widget _buildInvoiceCard(BuildContext context, Invoice inv, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.receipt, color: Colors.green.shade700, size: 20)),
        title: Row(children: [
          Expanded(child: Text(inv.contactName.isNotEmpty ? inv.contactName : 'بدون عميل',
            style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(formatCurrency(inv.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ]),
        subtitle: Row(children: [
          Text('${inv.items.length} أصناف', style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatDate(inv.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (inv.remaining > 0) ...[
            const Text(' | ', style: TextStyle(color: Colors.grey)),
            Text('متبقي: ${formatCurrency(inv.remaining)}', style: const TextStyle(fontSize: 11, color: Colors.red)),
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
