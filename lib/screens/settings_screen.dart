import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common_widgets.dart';

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
