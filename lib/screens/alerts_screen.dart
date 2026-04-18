import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/app_provider.dart';
import '../models/models.dart';
import 'invoice_screen.dart';
import 'products_screen.dart';
import 'account_statement_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  static const int lowStockThreshold = 10;

  String _fmt(double n) => NumberFormat('#,##0.00', 'en').format(n);
  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final outOfStock = provider.products.where((p) => p.quantity <= 0).toList();
        final lowStock = provider.products.where((p) =>
            p.quantity > 0 && p.quantity <= lowStockThreshold).toList();
        final unpaidSales = provider.sales.where((inv) => inv.remaining > 0.01).toList();
        final unpaidPurchases = provider.purchases.where((inv) => inv.remaining > 0.01).toList();
        final overdueQuotes = provider.quotes.where((q) =>
            q.status == 'pending' && q.validUntil.isBefore(DateTime.now())).toList();
        final clientsWithDebt = provider.clients.where((c) => c.balance > 0.01).toList();
        final suppliersWithDebt = provider.suppliers.where((s) => s.balance > 0.01).toList();

        final totalAlerts = outOfStock.length +
            lowStock.length +
            unpaidSales.length +
            unpaidPurchases.length +
            overdueQuotes.length;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('التنبيهات الذكية'),
                  const SizedBox(width: 8),
                  if (totalAlerts > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$totalAlerts',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(
              child: totalAlerts == 0 && clientsWithDebt.isEmpty && suppliersWithDebt.isEmpty
                  ? _emptyState(theme)
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        _summaryCard(theme, totalAlerts, outOfStock.length, lowStock.length,
                            unpaidSales.length, unpaidPurchases.length, overdueQuotes.length),
                        const SizedBox(height: 12),
                        if (outOfStock.isNotEmpty)
                          _section(
                            context,
                            title: 'منتجات نفدت من المخزون',
                            icon: Icons.remove_shopping_cart,
                            color: Colors.red,
                            count: outOfStock.length,
                            children: outOfStock.map((p) => _productTile(context, p, provider, Colors.red)).toList(),
                          ),
                        if (lowStock.isNotEmpty)
                          _section(
                            context,
                            title: 'منتجات منخفضة المخزون (≤ $lowStockThreshold)',
                            icon: Icons.warning_amber,
                            color: Colors.orange,
                            count: lowStock.length,
                            children: lowStock.map((p) => _productTile(context, p, provider, Colors.orange)).toList(),
                          ),
                        if (unpaidSales.isNotEmpty)
                          _section(
                            context,
                            title: 'فواتير بيع غير مسددة',
                            icon: Icons.receipt_long,
                            color: Colors.deepPurple,
                            count: unpaidSales.length,
                            children: unpaidSales.take(20).map((inv) =>
                                _invoiceTile(context, inv, provider, 'sale')).toList(),
                          ),
                        if (unpaidPurchases.isNotEmpty)
                          _section(
                            context,
                            title: 'فواتير شراء غير مسددة',
                            icon: Icons.shopping_cart_checkout,
                            color: Colors.teal,
                            count: unpaidPurchases.length,
                            children: unpaidPurchases.take(20).map((inv) =>
                                _invoiceTile(context, inv, provider, 'purchase')).toList(),
                          ),
                        if (overdueQuotes.isNotEmpty)
                          _section(
                            context,
                            title: 'عروض أسعار منتهية الصلاحية',
                            icon: Icons.schedule,
                            color: Colors.brown,
                            count: overdueQuotes.length,
                            children: overdueQuotes.map((q) => _quoteTile(q, provider)).toList(),
                          ),
                        if (clientsWithDebt.isNotEmpty)
                          _section(
                            context,
                            title: 'عملاء لديهم ديون',
                            icon: Icons.person_outline,
                            color: Colors.blue,
                            count: clientsWithDebt.length,
                            children: clientsWithDebt.take(20).map((c) => Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.withValues(alpha: 0.15),
                                      child: const Icon(Icons.person, color: Colors.blue),
                                    ),
                                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(c.phone.isEmpty ? 'بدون هاتف' : c.phone),
                                    trailing: Text(
                                      '${_fmt(c.balance)} ${provider.currency}',
                                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => AccountStatementScreen(
                                            contactId: c.id, contactName: c.name))),
                                  ),
                                )).toList(),
                          ),
                        if (suppliersWithDebt.isNotEmpty)
                          _section(
                            context,
                            title: 'مستحقات الموردين',
                            icon: Icons.local_shipping,
                            color: Colors.indigo,
                            count: suppliersWithDebt.length,
                            children: suppliersWithDebt.take(20).map((s) => Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.withValues(alpha: 0.15),
                                      child: const Icon(Icons.local_shipping, color: Colors.indigo),
                                    ),
                                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(s.phone.isEmpty ? 'بدون هاتف' : s.phone),
                                    trailing: Text(
                                      '${_fmt(s.balance)} ${provider.currency}',
                                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => AccountStatementScreen(
                                            contactId: s.id, contactName: s.name))),
                                  ),
                                )).toList(),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(ThemeData theme, int total, int out, int low, int uSales,
      int uPurchases, int overdueQ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: total == 0
              ? [Colors.green, Colors.green.shade300]
              : [Colors.orange, Colors.red.shade400],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(total == 0 ? Icons.check_circle : Icons.notifications_active,
                  color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                total == 0 ? 'كل شيء على ما يرام!' : 'لديك $total تنبيه',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (out > 0) _mini('نفد: $out', Icons.remove_shopping_cart),
              if (low > 0) _mini('منخفض: $low', Icons.warning_amber),
              if (uSales > 0) _mini('بيع غير مسدد: $uSales', Icons.receipt_long),
              if (uPurchases > 0) _mini('شراء غير مسدد: $uPurchases', Icons.shopping_cart_checkout),
              if (overdueQ > 0) _mini('عروض منتهية: $overdueQ', Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required int count,
      required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _productTile(BuildContext context, Product p, AppProvider prov, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.inventory_2, color: color),
        ),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${p.category.isEmpty ? "بدون فئة" : p.category} • سعر البيع: ${_fmt(p.sellPrice)}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الكمية: ${p.quantity}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(p.unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen())),
      ),
    );
  }

  Widget _invoiceTile(BuildContext context, Invoice inv, AppProvider prov, String type) {
    final color = type == 'sale' ? Colors.deepPurple : Colors.teal;
    final percentPaid = inv.totalAmount > 0 ? (inv.paid / inv.totalAmount).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(type == 'sale' ? Icons.receipt : Icons.shopping_cart, color: color),
        ),
        title: Text(
          '${type == "sale" ? "بيع" : "شراء"} #${inv.id.length >= 6 ? inv.id.substring(0, 6) : inv.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${inv.contactName.isEmpty ? "بدون جهة" : inv.contactName} • ${_fmtDate(inv.date)}'),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentPaid,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 2),
            Text('مدفوع: ${_fmt(inv.paid)} من ${_fmt(inv.totalAmount)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('المتبقي', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            Text('${_fmt(inv.remaining)} ${prov.currency}',
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => InvoiceScreen(type: type, invoice: inv))),
      ),
    );
  }

  Widget _quoteTile(Quote q, AppProvider prov) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown.withValues(alpha: 0.15),
          child: const Icon(Icons.request_quote, color: Colors.brown),
        ),
        title: Text(
          'عرض #${q.id.length >= 6 ? q.id.substring(0, 6) : q.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            '${q.contactName.isEmpty ? "بدون عميل" : q.contactName} • انتهى بتاريخ ${_fmtDate(q.validUntil)}'),
        trailing: Text(
          '${_fmt(q.totalAmount)} ${prov.currency}',
          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 96, color: Colors.green.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text('ممتاز! لا توجد تنبيهات',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('كل شيء تحت السيطرة',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
