import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

String formatCurrency(double amount) => NumberFormat('#,##0.00', 'en').format(amount);

/// Format currency with currency symbol from AppProvider
String formatCurrencyWithSymbol(BuildContext context, double amount) {
  final currency = Provider.of<AppProvider>(context, listen: false).currency;
  return '${NumberFormat('#,##0.00', 'en').format(amount)} $currency';
}

String formatDate(DateTime date) => DateFormat('yyyy/MM/dd').format(date);
String formatDateTime(DateTime date) => DateFormat('yyyy/MM/dd HH:mm').format(date);

// Reusable search field
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hint,
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

// Reusable empty state
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// Reusable form field
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  const AppTextField({super.key, required this.label, required this.controller,
    this.keyboardType, this.maxLines = 1, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}

// Delete confirmation dialog
Future<bool> confirmDelete(BuildContext context, String itemName) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "$itemName"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ),
  ) ?? false;
}

// Status badge
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'pending': color = Colors.orange; label = 'معلق';
      case 'approved': color = Colors.green; label = 'مقبول';
      case 'rejected': color = Colors.red; label = 'مرفوض';
      case 'converted': color = Colors.blue; label = 'محوّل';
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
