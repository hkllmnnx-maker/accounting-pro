import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/app_provider.dart';
import 'clients_screen.dart';
import 'suppliers_screen.dart';
import 'employees_screen.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'purchases_screen.dart';
import 'expenses_screen.dart';
import 'vouchers_screen.dart';
import 'invoice_screen.dart';
import 'account_statement_screen.dart';
import 'reports_screen.dart';
import 'exchange_screen.dart';
import 'journal_screen.dart';
import 'quotes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatNum(double n) => NumberFormat('#,##0.00', 'en').format(n);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final stats = provider.dashboardStats;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Accounting Pro', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  tooltip: 'التقارير',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Summary
                    _buildSummarySection(context, stats, theme),
                    const SizedBox(height: 16),
                    // Quick Actions
                    Text(' الإجراءات السريعة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildQuickActions(context, theme),
                    const SizedBox(height: 16),
                    // Main Cards
                    Text(' الأقسام الرئيسية', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildMainGrid(context, stats, theme),
                    const SizedBox(height: 16),
                    // Phase 2 Cards
                    Text(' الأدوات المتقدمة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildAdvancedGrid(context, theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, Map<String, dynamic> stats, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.topRight, end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ملخص اليوم', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryChip('المبيعات', _formatNum(stats['todaySales'] ?? 0), Icons.trending_up, Colors.greenAccent),
              const SizedBox(width: 8),
              _summaryChip('المشتريات', _formatNum(stats['todayPurchases'] ?? 0), Icons.trending_down, Colors.orangeAccent),
              const SizedBox(width: 8),
              _summaryChip('المصاريف', _formatNum(stats['todayExpenses'] ?? 0), Icons.money_off, Colors.redAccent),
            ],
          ),
          const Divider(color: Colors.white30, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('صافي الشهر: ${_formatNum((stats['monthlySales'] ?? 0) - (stats['monthlyPurchases'] ?? 0) - (stats['monthlyExpenses'] ?? 0))}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text('${stats['salesCount'] ?? 0} فاتورة', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    final actions = [
      {'icon': Icons.add_shopping_cart, 'label': 'فاتورة بيع', 'color': Colors.green,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceScreen(type: 'sale')))},
      {'icon': Icons.shopping_bag, 'label': 'فاتورة شراء', 'color': Colors.orange,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceScreen(type: 'purchase')))},
      {'icon': Icons.receipt_long, 'label': 'سند قبض', 'color': Colors.blue,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersScreen()))},
      {'icon': Icons.account_balance_wallet, 'label': 'مصروف', 'color': Colors.red,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()))},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ActionChip(
            avatar: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
            label: Text(a['label'] as String, style: const TextStyle(fontSize: 13)),
            onPressed: a['onTap'] as VoidCallback,
            backgroundColor: (a['color'] as Color).withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMainGrid(BuildContext context, Map<String, dynamic> stats, ThemeData theme) {
    final items = [
      _DashItem('العملاء', '${stats['clientsCount']}', Icons.people, Colors.blue, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsScreen()))),
      _DashItem('الموردين', '${stats['suppliersCount']}', Icons.local_shipping, Colors.orange, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()))),
      _DashItem('الموظفين', '${stats['employeesCount']}', Icons.badge, Colors.purple, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeesScreen()))),
      _DashItem('المنتجات', '${stats['productsCount']}', Icons.inventory_2, Colors.teal, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()))),
      _DashItem('المبيعات', _formatNum(stats['totalSales'] ?? 0), Icons.point_of_sale, Colors.green, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesScreen()))),
      _DashItem('المشتريات', _formatNum(stats['totalPurchases'] ?? 0), Icons.shopping_cart, Colors.deepOrange, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()))),
      _DashItem('المصاريف', _formatNum(stats['totalExpenses'] ?? 0), Icons.money_off, Colors.red, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()))),
      _DashItem('السندات', (stats['clientsBalance'] as double).toStringAsFixed(0), Icons.receipt, Colors.indigo, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildDashCard(items[i], theme),
    );
  }

  Widget _buildAdvancedGrid(BuildContext context, ThemeData theme) {
    final items = [
      _DashItem('التقارير', 'إحصاءات', Icons.bar_chart, Colors.cyan, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()))),
      _DashItem('كشف حساب', 'تفاصيل', Icons.account_balance, Colors.brown, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountStatementScreen()))),
      _DashItem('صرف عملات', 'تحويل', Icons.currency_exchange, Colors.amber.shade700, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExchangeScreen()))),
      _DashItem('القيود', 'محاسبية', Icons.book, Colors.deepPurple, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalScreen()))),
      _DashItem('العروض', 'والطلبات', Icons.request_quote, Colors.pink, () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotesScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1.1, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildDashCard(items[i], theme),
    );
  }

  Widget _buildDashCard(_DashItem item, ThemeData theme) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: item.color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 28),
            const SizedBox(height: 6),
            Text(item.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
            Text(item.value, style: TextStyle(fontSize: 11, color: item.color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DashItem {
  final String title, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _DashItem(this.title, this.value, this.icon, this.color, this.onTap);
}
