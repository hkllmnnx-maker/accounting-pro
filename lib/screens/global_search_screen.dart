import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../providers/app_provider.dart';
import 'invoice_screen.dart';
import 'account_statement_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';
  String _filter = 'الكل';

  final List<String> _filters = [
    'الكل',
    'العملاء',
    'الموردين',
    'المنتجات',
    'الموظفين',
    'فواتير البيع',
    'فواتير الشراء',
    'السندات',
    'المصاريف',
  ];

  String _fmt(double n) => NumberFormat('#,##0.00', 'en').format(n);
  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd', 'en').format(d);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_SearchResult> _search(AppProvider p) {
    if (_query.trim().isEmpty) return [];
    final q = _query.trim().toLowerCase();
    final List<_SearchResult> results = [];

    bool match(String s) => s.toLowerCase().contains(q);

    if (_filter == 'الكل' || _filter == 'العملاء') {
      for (var c in p.clients) {
        if (match(c.name) || match(c.phone) || match(c.address)) {
          results.add(_SearchResult(
            title: c.name,
            subtitle: 'عميل • ${c.phone.isEmpty ? "بدون هاتف" : c.phone}',
            trailing: '${_fmt(c.balance)} ${p.currency}',
            icon: Icons.person,
            color: Colors.blue,
            category: 'العملاء',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AccountStatementScreen(contactId: c.id, contactName: c.name))),
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'الموردين') {
      for (var s in p.suppliers) {
        if (match(s.name) || match(s.phone) || match(s.address)) {
          results.add(_SearchResult(
            title: s.name,
            subtitle: 'مورد • ${s.phone.isEmpty ? "بدون هاتف" : s.phone}',
            trailing: '${_fmt(s.balance)} ${p.currency}',
            icon: Icons.local_shipping,
            color: Colors.orange,
            category: 'الموردين',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AccountStatementScreen(contactId: s.id, contactName: s.name))),
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'المنتجات') {
      for (var prod in p.products) {
        if (match(prod.name) || match(prod.category) || match(prod.barcode)) {
          results.add(_SearchResult(
            title: prod.name,
            subtitle: 'منتج • ${prod.category.isEmpty ? "بدون فئة" : prod.category} • الكمية: ${prod.quantity}',
            trailing: '${_fmt(prod.sellPrice)} ${p.currency}',
            icon: Icons.inventory_2,
            color: Colors.teal,
            category: 'المنتجات',
            onTap: null,
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'الموظفين') {
      for (var e in p.employees) {
        if (match(e.name) || match(e.phone) || match(e.position)) {
          results.add(_SearchResult(
            title: e.name,
            subtitle: 'موظف • ${e.position.isEmpty ? "بدون وظيفة" : e.position}',
            trailing: '${_fmt(e.salary)} ${p.currency}',
            icon: Icons.badge,
            color: Colors.purple,
            category: 'الموظفين',
            onTap: null,
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'فواتير البيع') {
      for (var inv in p.sales) {
        if (match(inv.contactName) || match(inv.id) || match(inv.notes) ||
            inv.items.any((it) => match(it.productName))) {
          results.add(_SearchResult(
            title: 'فاتورة بيع #${inv.id.length >= 6 ? inv.id.substring(0, 6) : inv.id}',
            subtitle: '${inv.contactName.isEmpty ? "بدون عميل" : inv.contactName} • ${_fmtDate(inv.date)}',
            trailing: '${_fmt(inv.totalAmount)} ${p.currency}',
            icon: Icons.point_of_sale,
            color: Colors.green,
            category: 'فواتير البيع',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => InvoiceScreen(type: 'sale', invoice: inv))),
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'فواتير الشراء') {
      for (var inv in p.purchases) {
        if (match(inv.contactName) || match(inv.id) || match(inv.notes) ||
            inv.items.any((it) => match(it.productName))) {
          results.add(_SearchResult(
            title: 'فاتورة شراء #${inv.id.length >= 6 ? inv.id.substring(0, 6) : inv.id}',
            subtitle: '${inv.contactName.isEmpty ? "بدون مورد" : inv.contactName} • ${_fmtDate(inv.date)}',
            trailing: '${_fmt(inv.totalAmount)} ${p.currency}',
            icon: Icons.shopping_cart,
            color: Colors.deepOrange,
            category: 'فواتير الشراء',
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => InvoiceScreen(type: 'purchase', invoice: inv))),
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'السندات') {
      for (var v in p.vouchers) {
        if (match(v.contactName) || match(v.paymentMethod) || match(v.notes)) {
          results.add(_SearchResult(
            title: v.type == 'receipt' ? 'سند قبض' : 'سند صرف',
            subtitle: '${v.contactName.isEmpty ? "بدون جهة" : v.contactName} • ${_fmtDate(v.date)}',
            trailing: '${_fmt(v.amount)} ${p.currency}',
            icon: v.type == 'receipt' ? Icons.call_received : Icons.call_made,
            color: v.type == 'receipt' ? Colors.blue : Colors.red,
            category: 'السندات',
            onTap: null,
          ));
        }
      }
    }

    if (_filter == 'الكل' || _filter == 'المصاريف') {
      for (var e in p.expenses) {
        if (match(e.title) || match(e.category) || match(e.notes)) {
          results.add(_SearchResult(
            title: e.title,
            subtitle: 'مصروف • ${e.category.isEmpty ? "بدون تصنيف" : e.category} • ${_fmtDate(e.date)}',
            trailing: '${_fmt(e.amount)} ${p.currency}',
            icon: Icons.money_off,
            color: Colors.red,
            category: 'المصاريف',
            onTap: null,
          ));
        }
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final results = _search(provider);
        // Group by category
        final Map<String, List<_SearchResult>> grouped = {};
        for (var r in results) {
          grouped.putIfAbsent(r.category, () => []).add(r);
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('البحث الشامل'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'ابحث في كل البيانات...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filters.length,
                      itemBuilder: (_, i) {
                        final f = _filters[i];
                        final sel = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: sel,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _query.trim().isEmpty
                        ? _buildEmptyState(theme, 'ابدأ بكتابة كلمة البحث', Icons.search)
                        : results.isEmpty
                            ? _buildEmptyState(theme, 'لا توجد نتائج', Icons.search_off)
                            : ListView(
                                padding: const EdgeInsets.only(bottom: 16),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'تم العثور على ${results.length} نتيجة',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...grouped.entries.map((entry) => _buildGroup(entry.key, entry.value, theme)),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroup(String category, List<_SearchResult> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Text(category, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${items.length}', style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ),
        ),
        ...items.map((r) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: r.color.withValues(alpha: 0.15),
                  child: Icon(r.icon, color: r.color),
                ),
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(r.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  r.trailing,
                  style: TextStyle(color: r.color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onTap: r.onTap,
              ),
            )),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(msg, style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final Color color;
  final String category;
  final VoidCallback? onTap;

  _SearchResult({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    required this.color,
    required this.category,
    this.onTap,
  });
}
