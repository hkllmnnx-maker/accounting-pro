import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabC;

  @override
  void initState() { super.initState(); _tabC = TabController(length: 4, vsync: this); }
  @override
  void dispose() { _tabC.dispose(); super.dispose(); }

  final _months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final stats = provider.dashboardStats;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('التقارير والإحصاءات'),
              backgroundColor: Colors.cyan.shade700, foregroundColor: Colors.white,
              bottom: TabBar(controller: _tabC, isScrollable: true,
                indicatorColor: Colors.white, labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'نظرة عامة'), Tab(text: 'المبيعات والمشتريات'),
                  Tab(text: 'المصاريف'), Tab(text: 'الأرباح'),
                ]),
            ),
            body: TabBarView(controller: _tabC, children: [
              _buildOverview(stats),
              _buildSalesPurchases(provider),
              _buildExpensesChart(provider),
              _buildProfitReport(provider, stats),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildOverview(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        // KPI Cards
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5, crossAxisSpacing: 8, mainAxisSpacing: 8,
          children: [
            _kpiCard('إجمالي المبيعات', formatCurrency(stats['totalSales'] ?? 0),
              Icons.trending_up, Colors.green),
            _kpiCard('إجمالي المشتريات', formatCurrency(stats['totalPurchases'] ?? 0),
              Icons.trending_down, Colors.orange),
            _kpiCard('إجمالي المصاريف', formatCurrency(stats['totalExpenses'] ?? 0),
              Icons.money_off, Colors.red),
            _kpiCard('صافي الربح', formatCurrency(
              (stats['totalSales'] ?? 0) - (stats['totalPurchases'] ?? 0) - (stats['totalExpenses'] ?? 0)),
              Icons.account_balance_wallet, Colors.blue),
            _kpiCard('عدد العملاء', '${stats['clientsCount'] ?? 0}',
              Icons.people, Colors.purple),
            _kpiCard('عدد المنتجات', '${stats['productsCount'] ?? 0}',
              Icons.inventory_2, Colors.teal),
            _kpiCard('ذمم العملاء', formatCurrency(stats['clientsBalance'] ?? 0),
              Icons.account_balance, Colors.indigo),
            _kpiCard('ذمم الموردين', formatCurrency(stats['suppliersBalance'] ?? 0),
              Icons.local_shipping, Colors.brown),
          ],
        ),
      ]),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
          overflow: TextOverflow.ellipsis),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildSalesPurchases(AppProvider provider) {
    final data = provider.monthlySalesData;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('المبيعات والمشتريات الشهرية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: data.isEmpty
              ? const Center(child: Text('لا توجد بيانات'))
              : BarChart(BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(data),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          formatCurrency(rod.toY),
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Text(_months[((data[idx]['month'] as int) - 1) % 12],
                            style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(_formatShort(value),
                        style: const TextStyle(fontSize: 9)),
                    )),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: (d['sales'] as double), color: Colors.green, width: 12,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                      BarChartRodData(toY: (d['purchases'] as double), color: Colors.orange, width: 12,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                    ]);
                  }).toList(),
                )),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legendDot(Colors.green, 'المبيعات'),
          const SizedBox(width: 20),
          _legendDot(Colors.orange, 'المشتريات'),
        ]),
        const SizedBox(height: 16),
        // Monthly details table
        ...data.map((d) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_months[((d['month'] as int) - 1) % 12], style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('مبيعات: ${formatCurrency(d['sales'] as double)}',
              style: const TextStyle(fontSize: 12, color: Colors.green)),
            Text('مشتريات: ${formatCurrency(d['purchases'] as double)}',
              style: const TextStyle(fontSize: 12, color: Colors.orange)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildExpensesChart(AppProvider provider) {
    final data = provider.expensesByCategory;
    final total = data.fold(0.0, (s, d) => s + (d['amount'] as double));
    final colors = [Colors.purple, Colors.blue, Colors.orange, Colors.teal, Colors.indigo, Colors.red, Colors.grey];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('المصاريف حسب التصنيف',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: data.isEmpty
              ? const Center(child: Text('لا توجد مصاريف'))
              : PieChart(PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    final amt = d['amount'] as double;
                    final pct = total > 0 ? (amt / total * 100) : 0;
                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: amt,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      radius: 50,
                    );
                  }).toList(),
                )),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 6,
          children: data.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            return _legendDot(colors[i % colors.length], '${d['category']}');
          }).toList(),
        ),
        const SizedBox(height: 16),
        ...data.map((d) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(d['category'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(formatCurrency(d['amount'] as double), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            Text('${total > 0 ? ((d['amount'] as double) / total * 100).toStringAsFixed(1) : 0}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildProfitReport(AppProvider provider, Map<String, dynamic> stats) {
    final totalSales = (stats['totalSales'] ?? 0.0) as double;
    final totalPurchases = (stats['totalPurchases'] ?? 0.0) as double;
    final totalExpenses = (stats['totalExpenses'] ?? 0.0) as double;
    final grossProfit = totalSales - totalPurchases;
    final netProfit = grossProfit - totalExpenses;
    final monthlyData = provider.monthlySalesData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        const Text('تقرير الأرباح والخسائر',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Profit line chart
        SizedBox(
          height: 200,
          child: monthlyData.isEmpty
              ? const Center(child: Text('لا توجد بيانات'))
              : LineChart(LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < monthlyData.length) {
                          return Text(_months[((monthlyData[idx]['month'] as int) - 1) % 12],
                            style: const TextStyle(fontSize: 9));
                        }
                        return const Text('');
                      },
                    )),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(_formatShort(value),
                        style: const TextStyle(fontSize: 9)),
                    )),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), (e.value['sales'] as double) - (e.value['purchases'] as double))
                      ).toList(),
                      isCurved: true, color: Colors.blue, barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                )),
        ),
        const SizedBox(height: 16),
        // P&L Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _plRow('إجمالي المبيعات', totalSales, Colors.green),
              _plRow('إجمالي المشتريات', -totalPurchases, Colors.orange),
              const Divider(),
              _plRow('مجمل الربح', grossProfit, Colors.blue, isBold: true),
              _plRow('إجمالي المصاريف', -totalExpenses, Colors.red),
              const Divider(thickness: 2),
              _plRow('صافي الربح', netProfit, netProfit >= 0 ? Colors.green : Colors.red, isBold: true, size: 18),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _plRow(String label, double value, Color color, {bool isBold = false, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : null)),
        Text(formatCurrency(value.abs()), style: TextStyle(fontSize: size, color: color,
          fontWeight: isBold ? FontWeight.bold : null)),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 0;
    for (var d in data) {
      if ((d['sales'] as double) > max) max = d['sales'] as double;
      if ((d['purchases'] as double) > max) max = d['purchases'] as double;
    }
    return max > 0 ? max * 1.2 : 1000;
  }

  String _formatShort(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }
}
