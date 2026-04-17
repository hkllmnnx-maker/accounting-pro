import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class PdfService {
  static Future<pw.Document> generateInvoicePdf({
    required Invoice invoice,
    required String companyName,
    required String companyPhone,
    required String companyAddress,
    required String currency,
  }) async {
    final doc = pw.Document();
    final isSale = invoice.type == 'sale';
    final title = isSale ? 'فاتورة بيع' : 'فاتورة شراء';
    final contactLabel = isSale ? 'العميل' : 'المورد';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(isSale ? 0xFF4CAF50 : 0xFFFF9800),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    if (companyPhone.isNotEmpty)
                      pw.Text(companyPhone,
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 10)),
                    if (companyAddress.isNotEmpty)
                      pw.Text(companyAddress,
                          style: const pw.TextStyle(
                              color: PdfColors.white, fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(title,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('#${invoice.id.substring(0, invoice.id.length > 8 ? 8 : invoice.id.length)}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Invoice Info
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('$contactLabel:',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(
                      invoice.contactName.isEmpty ? '-' : invoice.contactName,
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('التاريخ:',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Text(_formatDate(invoice.date),
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Items Table
          pw.Text('الأصناف',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('#', bold: true),
                  _cell('الصنف', bold: true),
                  _cell('الكمية', bold: true),
                  _cell('السعر', bold: true),
                  _cell('الإجمالي', bold: true),
                ],
              ),
              ...invoice.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return pw.TableRow(children: [
                  _cell('${i + 1}'),
                  _cell(item.productName),
                  _cell('${item.quantity}'),
                  _cell(_formatCurrency(item.price, currency)),
                  _cell(_formatCurrency(item.total, currency)),
                ]);
              }),
            ],
          ),
          pw.SizedBox(height: 16),

          // Totals
          pw.Container(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              width: 250,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(children: [
                _totalRow('المجموع الفرعي', invoice.subtotal, currency),
                _totalRow('الخصم', -invoice.discount, currency),
                _totalRow('الضريبة (${invoice.tax.toStringAsFixed(0)}%)',
                    invoice.taxAmount, currency),
                pw.Divider(),
                _totalRow('الإجمالي', invoice.totalAmount, currency, bold: true),
                _totalRow('المدفوع', invoice.paid, currency,
                    color: PdfColors.green),
                _totalRow('المتبقي', invoice.remaining, currency,
                    bold: true,
                    color: invoice.remaining > 0
                        ? PdfColors.red
                        : PdfColors.green),
              ]),
            ),
          ),

          if (invoice.notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ملاحظات:',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey),
          pw.Center(
            child: pw.Text('شكراً لتعاملكم معنا',
                style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                    fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _totalRow(String label, double value, String currency,
      {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(_formatCurrency(value.abs(), currency),
              style: pw.TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  static String _formatCurrency(double amount, String currency) {
    final formatted = amount.toStringAsFixed(2);
    return '$formatted $currency';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> printInvoice(pw.Document doc, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: fileName,
    );
  }

  static Future<void> shareInvoice(pw.Document doc, String fileName) async {
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: '$fileName.pdf',
    );
  }

  /// توليد تقرير مالي PDF (المبيعات، المشتريات، المصاريف، الأرباح)
  static Future<pw.Document> generateFinancialReport({
    required String companyName,
    required String currency,
    required DateTime from,
    required DateTime to,
    required Map<String, dynamic> stats,
    required List<Map<String, dynamic>> expensesByCategory,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1565C0),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('تقرير مالي',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 12)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('من: ${_formatDate(from)}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 10)),
                    pw.Text('إلى: ${_formatDate(to)}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 10)),
                    pw.Text('تاريخ التقرير: ${_formatDate(DateTime.now())}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary Stats
          pw.Text('الملخص المالي',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('البند', bold: true),
                  _cell('القيمة', bold: true),
                ],
              ),
              _statRow('عدد فواتير البيع', '${stats['salesCount'] ?? 0}'),
              _statRow('عدد فواتير الشراء', '${stats['purchasesCount'] ?? 0}'),
              _statRow('عدد المصاريف', '${stats['expensesCount'] ?? 0}'),
              _statRow('إجمالي المبيعات',
                  _formatCurrency((stats['totalSales'] ?? 0).toDouble(), currency)),
              _statRow('إجمالي المشتريات',
                  _formatCurrency((stats['totalPurchases'] ?? 0).toDouble(), currency)),
              _statRow('إجمالي المصاريف',
                  _formatCurrency((stats['totalExpenses'] ?? 0).toDouble(), currency)),
              _statRow('الربح الإجمالي',
                  _formatCurrency((stats['grossProfit'] ?? 0).toDouble(), currency),
                  highlight: true),
              _statRow('صافي الربح',
                  _formatCurrency((stats['netProfit'] ?? 0).toDouble(), currency),
                  highlight: true),
            ],
          ),
          pw.SizedBox(height: 20),

          // Expenses by category
          if (expensesByCategory.isNotEmpty) ...[
            pw.Text('المصاريف حسب التصنيف',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('التصنيف', bold: true),
                    _cell('المبلغ', bold: true),
                  ],
                ),
                ...expensesByCategory.map((cat) => pw.TableRow(children: [
                      _cell(cat['category']?.toString() ?? ''),
                      _cell(_formatCurrency(
                          (cat['amount'] ?? 0).toDouble(), currency)),
                    ])),
              ],
            ),
          ],

          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey),
          pw.Center(
            child: pw.Text('تم إنشاء هذا التقرير بواسطة Accounting Pro',
                style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                    fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    return doc;
  }

  static pw.TableRow _statRow(String label, String value, {bool highlight = false}) {
    return pw.TableRow(
      decoration: highlight
          ? const pw.BoxDecoration(color: PdfColors.blue50)
          : null,
      children: [
        _cell(label, bold: highlight),
        _cell(value, bold: highlight),
      ],
    );
  }

  /// توليد تقرير مخزون PDF
  static Future<pw.Document> generateInventoryReport({
    required String companyName,
    required String currency,
    required List<Product> products,
  }) async {
    final doc = pw.Document();
    final totalValue = products.fold(0.0, (s, p) => s + (p.sellPrice * p.quantity));
    final totalCost = products.fold(0.0, (s, p) => s + (p.buyPrice * p.quantity));
    final totalQty = products.fold(0, (s, p) => s + p.quantity);
    final outOfStock = products.where((p) => p.quantity <= 0).length;
    final lowStock = products.where((p) => p.quantity > 0 && p.quantity < 5).length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF00695C),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('تقرير المخزون',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 12)),
                  ],
                ),
                pw.Text('تاريخ: ${_formatDate(DateTime.now())}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Summary
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('البند', bold: true),
                  _cell('القيمة', bold: true),
                ],
              ),
              _statRow('إجمالي المنتجات', '${products.length}'),
              _statRow('إجمالي الكمية', '$totalQty'),
              _statRow('تكلفة المخزون (شراء)', _formatCurrency(totalCost, currency)),
              _statRow('قيمة المخزون (بيع)', _formatCurrency(totalValue, currency), highlight: true),
              _statRow('أرباح متوقعة', _formatCurrency(totalValue - totalCost, currency), highlight: true),
              _statRow('منتجات نافدة', '$outOfStock'),
              _statRow('منتجات منخفضة', '$lowStock'),
            ],
          ),
          pw.SizedBox(height: 20),

          pw.Text('تفاصيل المنتجات',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('#', bold: true),
                  _cell('الاسم', bold: true),
                  _cell('الفئة', bold: true),
                  _cell('الكمية', bold: true),
                  _cell('سعر الشراء', bold: true),
                  _cell('سعر البيع', bold: true),
                ],
              ),
              ...products.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return pw.TableRow(
                  decoration: p.quantity <= 0
                      ? const pw.BoxDecoration(color: PdfColors.red50)
                      : p.quantity < 5
                          ? const pw.BoxDecoration(color: PdfColors.amber50)
                          : null,
                  children: [
                    _cell('${i + 1}'),
                    _cell(p.name),
                    _cell(p.category),
                    _cell('${p.quantity}'),
                    _cell(_formatCurrency(p.buyPrice, currency)),
                    _cell(_formatCurrency(p.sellPrice, currency)),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  /// توليد كشف حساب عميل/مورد PDF
  static Future<pw.Document> generateAccountStatementPdf({
    required String companyName,
    required String contactName,
    required String currency,
    required List<AccountEntry> entries,
  }) async {
    final doc = pw.Document();
    final totalDebit = entries.fold(0.0, (s, e) => s + e.debit);
    final totalCredit = entries.fold(0.0, (s, e) => s + e.credit);
    final balance = totalDebit - totalCredit;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF795548),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(companyName,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('كشف حساب',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 12)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(contactName,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('تاريخ: ${_formatDate(DateTime.now())}',
                        style: const pw.TextStyle(
                            color: PdfColors.white, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('التاريخ', bold: true),
                  _cell('البيان', bold: true),
                  _cell('مدين', bold: true),
                  _cell('دائن', bold: true),
                  _cell('الرصيد', bold: true),
                ],
              ),
              ...entries.map((e) => pw.TableRow(children: [
                    _cell(_formatDate(e.date)),
                    _cell(e.description),
                    _cell(e.debit > 0 ? _formatCurrency(e.debit, currency) : '-'),
                    _cell(e.credit > 0 ? _formatCurrency(e.credit, currency) : '-'),
                    _cell(_formatCurrency(e.balance, currency)),
                  ])),
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.amber100),
                children: [
                  _cell('الإجمالي', bold: true),
                  _cell(''),
                  _cell(_formatCurrency(totalDebit, currency), bold: true),
                  _cell(_formatCurrency(totalCredit, currency), bold: true),
                  _cell(_formatCurrency(balance, currency), bold: true),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: balance >= 0 ? PdfColors.green50 : PdfColors.red50,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('الرصيد النهائي:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '${_formatCurrency(balance.abs(), currency)} ${balance >= 0 ? 'مدين' : 'دائن'}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: balance >= 0 ? PdfColors.green : PdfColors.red,
                    )),
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }
}
