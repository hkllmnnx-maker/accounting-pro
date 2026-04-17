import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'invoice_screen.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final purchases = provider.purchases;
        final totalPurchases = purchases.fold(0.0, (s, i) => s + i.totalAmount);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('المشتريات'),
              backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => const InvoiceScreen(type: 'purchase'))),
              icon: const Icon(Icons.add), label: const Text('فاتورة شراء'),
              backgroundColor: Colors.orange),
            body: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withValues(alpha: 0.05),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [
                    Text('${purchases.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const Text('عدد الفواتير', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                  Column(children: [
                    Text(formatCurrency(totalPurchases), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                    const Text('إجمالي المشتريات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                ]),
              ),
              Expanded(
                child: purchases.isEmpty
                    ? const EmptyState(message: 'لا يوجد مشتريات', icon: Icons.shopping_cart)
                    : ListView.builder(
                        itemCount: purchases.length,
                        itemBuilder: (_, i) => _buildCard(context, purchases[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Invoice inv, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.shopping_bag, color: Colors.orange.shade700, size: 20)),
        title: Row(children: [
          Expanded(child: Text(inv.contactName.isNotEmpty ? inv.contactName : 'بدون مورد',
            style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(formatCurrency(inv.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
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
          builder: (_) => InvoiceScreen(type: 'purchase', invoice: inv))),
        onLongPress: () async {
          if (await confirmDelete(context, 'فاتورة #${inv.id.substring(0, 6)}')) {
            provider.deletePurchase(inv.id);
          }
        },
      ),
    );
  }
}
