import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});
  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final _currencies = {
    'USD': {'name': 'دولار أمريكي', 'symbol': '\$', 'flag': '🇺🇸'},
    'EUR': {'name': 'يورو', 'symbol': '€', 'flag': '🇪🇺'},
    'GBP': {'name': 'جنيه استرليني', 'symbol': '£', 'flag': '🇬🇧'},
    'SAR': {'name': 'ريال سعودي', 'symbol': 'ر.س', 'flag': '🇸🇦'},
    'AED': {'name': 'درهم إماراتي', 'symbol': 'د.إ', 'flag': '🇦🇪'},
    'KWD': {'name': 'دينار كويتي', 'symbol': 'د.ك', 'flag': '🇰🇼'},
    'EGP': {'name': 'جنيه مصري', 'symbol': 'ج.م', 'flag': '🇪🇬'},
    'IQD': {'name': 'دينار عراقي', 'symbol': 'د.ع', 'flag': '🇮🇶'},
    'JOD': {'name': 'دينار أردني', 'symbol': 'د.أ', 'flag': '🇯🇴'},
    'TRY': {'name': 'ليرة تركية', 'symbol': '₺', 'flag': '🇹🇷'},
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final exchanges = provider.exchanges;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('صرف العملات'),
              backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showForm(context, provider),
              icon: const Icon(Icons.currency_exchange),
              label: const Text('عملية صرف جديدة'),
              backgroundColor: Colors.amber.shade700),
            body: Column(children: [
              // Quick converter
              _buildQuickConverter(context),
              const Divider(height: 1),
              // History
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Icon(Icons.history, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text('سجل عمليات الصرف', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${exchanges.length} عملية', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
              ),
              Expanded(
                child: exchanges.isEmpty
                    ? const EmptyState(message: 'لا يوجد عمليات صرف', icon: Icons.currency_exchange)
                    : ListView.builder(
                        itemCount: exchanges.length,
                        itemBuilder: (_, i) => _buildCard(context, exchanges[i], provider)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildQuickConverter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade400],
          begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Column(children: [
        const Text('محول العملات السريع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: const Column(children: [
              Text('USD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text('1.00', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          )),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.swap_horiz, color: Colors.white, size: 30)),
          Expanded(child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: const Column(children: [
              Text('SAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text('3.75', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          )),
        ]),
      ]),
    );
  }

  Widget _buildCard(BuildContext context, CurrencyExchange ex, AppProvider provider) {
    final fromInfo = _currencies[ex.fromCurrency] ?? {'name': ex.fromCurrency, 'flag': '', 'symbol': ''};
    final toInfo = _currencies[ex.toCurrency] ?? {'name': ex.toCurrency, 'flag': '', 'symbol': ''};
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber.shade100,
          child: const Icon(Icons.currency_exchange, color: Colors.amber, size: 20)),
        title: Row(children: [
          Text('${fromInfo['flag']} ${ex.fromCurrency}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          Text('${toInfo['flag']} ${ex.toCurrency}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        subtitle: Row(children: [
          Text('${formatCurrency(ex.amount)} × ${ex.rate}', style: const TextStyle(fontSize: 11)),
          const Text(' | ', style: TextStyle(color: Colors.grey)),
          Text(formatDate(ex.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        trailing: Text(formatCurrency(ex.result),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
        onLongPress: () async {
          if (await confirmDelete(context, 'عملية الصرف')) {
            provider.deleteExchange(ex.id);
          }
        },
      ),
    );
  }

  void _showForm(BuildContext context, AppProvider provider, {CurrencyExchange? exchange}) {
    String fromCurrency = exchange?.fromCurrency ?? 'USD';
    String toCurrency = exchange?.toCurrency ?? 'SAR';
    final amountC = TextEditingController(text: exchange?.amount.toString() ?? '');
    final rateC = TextEditingController(text: exchange?.rate.toString() ?? '');
    final notesC = TextEditingController(text: exchange?.notes ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final result = (double.tryParse(amountC.text) ?? 0) * (double.tryParse(rateC.text) ?? 0);
          return Directionality(textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: Form(key: formKey, child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('عملية صرف جديدة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: DropdownButtonFormField<String>(
                      initialValue: fromCurrency,
                      decoration: const InputDecoration(labelText: 'من عملة'),
                      items: _currencies.entries.map((e) => DropdownMenuItem(
                        value: e.key, child: Text('${e.value['flag']} ${e.key}'))).toList(),
                      onChanged: (v) => setModalState(() => fromCurrency = v ?? 'USD'),
                    )),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.swap_horiz), onPressed: () {
                      setModalState(() { final t = fromCurrency; fromCurrency = toCurrency; toCurrency = t; });
                    }),
                    const SizedBox(width: 8),
                    Expanded(child: DropdownButtonFormField<String>(
                      initialValue: toCurrency,
                      decoration: const InputDecoration(labelText: 'إلى عملة'),
                      items: _currencies.entries.map((e) => DropdownMenuItem(
                        value: e.key, child: Text('${e.value['flag']} ${e.key}'))).toList(),
                      onChanged: (v) => setModalState(() => toCurrency = v ?? 'SAR'),
                    )),
                  ]),
                  const SizedBox(height: 12),
                  AppTextField(label: 'المبلغ *', controller: amountC,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
                  AppTextField(label: 'سعر الصرف *', controller: rateC,
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('الناتج:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatCurrency(result), style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber.shade700)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'ملاحظات', controller: notesC, maxLines: 2),
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final amt = double.tryParse(amountC.text) ?? 0;
                      final rate = double.tryParse(rateC.text) ?? 0;
                      provider.saveExchange(CurrencyExchange(
                        id: exchange?.id ?? provider.generateId(),
                        fromCurrency: fromCurrency, toCurrency: toCurrency,
                        amount: amt, rate: rate, result: amt * rate,
                        notes: notesC.text, date: DateTime.now()));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700, foregroundColor: Colors.white),
                    child: const Text('تنفيذ عملية الصرف'))),
                ])))));
        }));
  }
}
