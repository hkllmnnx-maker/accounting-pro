import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/csv_service.dart';
import '../services/file_download_service.dart';
import '../widgets/common_widgets.dart';
import 'lock_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('الإعدادات'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _sectionTitle(context, 'المظهر'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(
                          provider.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text('الوضع المظلم'),
                        subtitle: Text(provider.themeMode == ThemeMode.dark
                            ? 'مفعّل'
                            : 'غير مفعّل'),
                        value: provider.themeMode == ThemeMode.dark,
                        onChanged: (_) => provider.toggleTheme(),
                      ),
                    ],
                  ),
                ),
                _sectionTitle(context, 'معلومات الشركة'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.business, color: Colors.blue),
                        title: const Text('اسم الشركة'),
                        subtitle: Text(provider.companyName),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _editCompanyField(
                          context,
                          provider,
                          title: 'اسم الشركة',
                          initial: provider.companyName,
                          onSave: (v) => provider.updateCompanyInfo(name: v),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.green),
                        title: const Text('هاتف الشركة'),
                        subtitle: Text(provider.companyPhone.isEmpty
                            ? 'غير محدد'
                            : provider.companyPhone),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _editCompanyField(
                          context,
                          provider,
                          title: 'هاتف الشركة',
                          initial: provider.companyPhone,
                          onSave: (v) => provider.updateCompanyInfo(phone: v),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: const Text('عنوان الشركة'),
                        subtitle: Text(provider.companyAddress.isEmpty
                            ? 'غير محدد'
                            : provider.companyAddress),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _editCompanyField(
                          context,
                          provider,
                          title: 'عنوان الشركة',
                          initial: provider.companyAddress,
                          onSave: (v) => provider.updateCompanyInfo(address: v),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.attach_money, color: Colors.amber),
                        title: const Text('العملة'),
                        subtitle: Text(provider.currency),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _selectCurrency(context, provider),
                      ),
                    ],
                  ),
                ),
                _sectionTitle(context, 'الأمان'),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(Icons.lock, color: provider.isLockEnabled ? Colors.green : Colors.grey),
                        title: const Text('قفل التطبيق برمز PIN'),
                        subtitle: Text(provider.isLockEnabled
                            ? 'القفل مفعّل'
                            : 'إضافة حماية برمز PIN (4 أرقام)'),
                        value: provider.isLockEnabled,
                        onChanged: (val) async {
                          if (val) {
                            // إنشاء رمز جديد
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LockScreen(isSetup: true)),
                            );
                          } else {
                            // إلغاء القفل - يتطلب إدخال الرمز الحالي أولاً
                            _confirmRemoveLock(context, provider);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                _sectionTitle(context, 'النسخ الاحتياطي والبيانات'),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.backup, color: Colors.teal),
                        title: const Text('نسخ احتياطي للبيانات'),
                        subtitle: const Text('تصدير جميع البيانات كنص JSON'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _exportData(context, provider),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.table_chart, color: Colors.green),
                        title: const Text('تصدير إلى CSV'),
                        subtitle: const Text('تصدير العملاء، المنتجات، الفواتير... بصيغة Excel'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _exportCsv(context, provider),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore, color: Colors.orange),
                        title: const Text('استعادة البيانات'),
                        subtitle: const Text('استيراد بيانات من نسخة احتياطية'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _importData(context, provider),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('حذف جميع البيانات'),
                        subtitle: const Text('تحذير: لا يمكن التراجع عن هذا الإجراء'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _clearData(context, provider),
                      ),
                    ],
                  ),
                ),
                _sectionTitle(context, 'الإحصائيات'),
                Card(
                  child: Column(
                    children: [
                      _statTile(context, 'العملاء', provider.clients.length, Icons.people, Colors.blue),
                      const Divider(height: 1),
                      _statTile(context, 'الموردين', provider.suppliers.length, Icons.local_shipping, Colors.orange),
                      const Divider(height: 1),
                      _statTile(context, 'المنتجات', provider.products.length, Icons.inventory_2, Colors.teal),
                      const Divider(height: 1),
                      _statTile(context, 'فواتير البيع', provider.sales.length, Icons.point_of_sale, Colors.green),
                      const Divider(height: 1),
                      _statTile(context, 'فواتير الشراء', provider.purchases.length, Icons.shopping_cart, Colors.deepOrange),
                    ],
                  ),
                ),
                _sectionTitle(context, 'حول التطبيق'),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(Icons.info, color: Colors.blue),
                        title: Text('Accounting Pro'),
                        subtitle: Text('الإصدار 2.0.0'),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(Icons.description, color: Colors.grey),
                        title: Text('الوصف'),
                        subtitle: Text('تطبيق محاسبي احترافي لإدارة الأعمال'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _statTile(BuildContext context, String label, int count, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _editCompanyField(
    BuildContext context,
    AppProvider provider, {
    required String title,
    required String initial,
    required Future<void> Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: AppTextField(
            label: title,
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await onSave(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCurrency(BuildContext context, AppProvider provider) {
    final currencies = ['ر.س', 'د.إ', 'ج.م', 'د.ك', 'د.ب', 'ر.ع', 'ر.ي', 'د.ع', 'د.ل', '\$', '€', '£'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('اختر العملة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currencies.map((c) {
                  final selected = provider.currency == c;
                  return ChoiceChip(
                    label: Text(c, style: const TextStyle(fontSize: 14)),
                    selected: selected,
                    onSelected: (_) {
                      provider.setCurrency(c);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, AppProvider provider) async {
    try {
      final data = await provider.exportAllData();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('نسخة احتياطية'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تم إنشاء نسخة احتياطية. انسخ النص واحفظه في مكان آمن:'),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        jsonStr,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('نسخ'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم النسخ إلى الحافظة'), backgroundColor: Colors.green),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, AppProvider provider) async {
    final options = <_CsvOption>[
      _CsvOption('clients.csv', 'العملاء', Icons.people, Colors.blue,
          () => CsvService.clientsToCsv(provider.clients)),
      _CsvOption('suppliers.csv', 'الموردين', Icons.local_shipping, Colors.orange,
          () => CsvService.suppliersToCsv(provider.suppliers)),
      _CsvOption('employees.csv', 'الموظفين', Icons.badge, Colors.purple,
          () => CsvService.employeesToCsv(provider.employees)),
      _CsvOption('products.csv', 'المنتجات', Icons.inventory_2, Colors.teal,
          () => CsvService.productsToCsv(provider.products)),
      _CsvOption('sales.csv', 'فواتير البيع', Icons.point_of_sale, Colors.green,
          () => CsvService.invoicesToCsv(provider.sales, 'sale')),
      _CsvOption('sales_items.csv', 'تفاصيل أصناف البيع', Icons.list_alt, Colors.green.shade300,
          () => CsvService.invoiceItemsToCsv(provider.sales, 'sale')),
      _CsvOption('purchases.csv', 'فواتير الشراء', Icons.shopping_cart, Colors.deepOrange,
          () => CsvService.invoicesToCsv(provider.purchases, 'purchase')),
      _CsvOption('purchases_items.csv', 'تفاصيل أصناف الشراء', Icons.list_alt, Colors.deepOrange.shade300,
          () => CsvService.invoiceItemsToCsv(provider.purchases, 'purchase')),
      _CsvOption('expenses.csv', 'المصاريف', Icons.money_off, Colors.red,
          () => CsvService.expensesToCsv(provider.expenses)),
      _CsvOption('vouchers.csv', 'السندات (قبض/صرف)', Icons.receipt_long, Colors.indigo,
          () => CsvService.vouchersToCsv(provider.vouchers)),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.table_chart, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('اختر البيانات المراد تصديرها',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ]),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final o = options[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: o.color.withValues(alpha: 0.15),
                          child: Icon(o.icon, color: o.color),
                        ),
                        title: Text(o.label,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(o.fileName,
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: const Icon(Icons.download, color: Colors.green),
                        onTap: () async {
                          final csv = o.builder();
                          if (csv.length <= 3) {
                            // BOM only -> empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا توجد بيانات للتصدير')),
                            );
                            return;
                          }
                          try {
                            await FileDownloadService.downloadText(
                              filename: o.fileName,
                              content: csv,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تصدير ${o.label} بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importData(BuildContext context, AppProvider provider) async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('استعادة البيانات'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الصق نص النسخة الاحتياطية (JSON):',
                    style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 10,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: '{ ... }',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تحذير: سيتم استبدال البيانات الحالية',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                try {
                  final data = jsonDecode(controller.text) as Map<String, dynamic>;
                  await provider.importAllData(data);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم استعادة البيانات بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في البيانات: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('استعادة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveLock(BuildContext context, AppProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد إزالة القفل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('أدخل رمز القفل الحالي لتأكيد الإلغاء:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '••••',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (provider.verifyLockPin(controller.text)) {
                  await provider.removeLockPin();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إلغاء قفل التطبيق'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('رمز القفل غير صحيح'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearData(BuildContext context, AppProvider provider) async {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text(
            'هل أنت متأكد من حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await provider.clearAllData();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف جميع البيانات'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('حذف الكل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CsvOption {
  final String fileName;
  final String label;
  final IconData icon;
  final Color color;
  final String Function() builder;
  _CsvOption(this.fileName, this.label, this.icon, this.color, this.builder);
}
