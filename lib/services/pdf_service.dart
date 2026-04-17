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
}
