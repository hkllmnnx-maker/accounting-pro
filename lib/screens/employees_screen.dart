import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});
  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final employees = provider.employees
            .where((e) => e.name.contains(_search) || e.position.contains(_search)).toList();
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(title: const Text('الموظفين'),
              backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.add), label: const Text('إضافة موظف')),
            body: Column(children: [
              SearchField(hint: 'بحث عن موظف...', onChanged: (v) => setState(() => _search = v)),
              Expanded(
                child: employees.isEmpty
                    ? const EmptyState(message: 'لا يوجد موظفين', icon: Icons.badge)
                    : ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (_, i) => _buildCard(context, employees[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Employee emp, AppProvider provider) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Text(emp.name.isNotEmpty ? emp.name[0] : '?',
            style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold))),
        title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(emp.position.isNotEmpty ? emp.position : 'بدون منصب', style: const TextStyle(fontSize: 12)),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(formatCurrency(emp.salary), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
          const Text('الراتب', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        onTap: () => _showForm(context, provider, employee: emp),
        onLongPress: () async {
          if (await confirmDelete(context, emp.name)) provider.deleteEmployee(emp.id);
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {Employee? employee}) {
    final nameC = TextEditingController(text: employee?.name ?? '');
    final phoneC = TextEditingController(text: employee?.phone ?? '');
    final posC = TextEditingController(text: employee?.position ?? '');
    final salaryC = TextEditingController(text: employee?.salary.toString() ?? '0');
    final notesC = TextEditingController(text: employee?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => Directionality(textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(key: formKey, child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(employee == null ? 'إضافة موظف' : 'تعديل موظف',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppTextField(label: 'الاسم *', controller: nameC,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              AppTextField(label: 'الهاتف', controller: phoneC, keyboardType: TextInputType.phone),
              AppTextField(label: 'المنصب', controller: posC),
              AppTextField(label: 'الراتب', controller: salaryC, keyboardType: TextInputType.number),
              AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  provider.saveEmployee(Employee(
                    id: employee?.id ?? provider.generateId(),
                    name: nameC.text, phone: phoneC.text, position: posC.text,
                    salary: double.tryParse(salaryC.text) ?? 0, notes: notesC.text,
                    createdAt: employee?.createdAt ?? DateTime.now()));
                  Navigator.pop(context);
                },
                child: Text(employee == null ? 'إضافة' : 'حفظ'))),
            ]))))));
  }
}
