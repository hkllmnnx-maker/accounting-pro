import 'package:intl/intl.dart' hide TextDirection;
import '../models/models.dart';

/// Service to convert app data into CSV format strings.
/// All output uses UTF-8 with BOM so that Excel correctly displays Arabic.
class CsvService {
  static const String _bom = '\uFEFF';
  static final _df = DateFormat('yyyy-MM-dd');

  /// Escape a value for CSV (handle commas, quotes, newlines).
  static String _esc(dynamic value) {
    if (value == null) return '';
    var s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      s = '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<dynamic> values) =>
      '${values.map(_esc).join(',')}\r\n';

  // ============= CLIENTS =============
  static String clientsToCsv(List<Client> clients) {
    final sb = StringBuffer(_bom);
    sb.write(_row(['ID', 'الاسم', 'الهاتف', 'العنوان', 'الرصيد', 'ملاحظات', 'تاريخ الإضافة']));
    for (var c in clients) {
      sb.write(_row([c.id, c.name, c.phone, c.address, c.balance, c.notes, _df.format(c.createdAt)]));
    }
    return sb.toString();
  }

  // ============= SUPPLIERS =============
  static String suppliersToCsv(List<Supplier> suppliers) {
    final sb = StringBuffer(_bom);
    sb.write(_row(['ID', 'الاسم', 'الهاتف', 'العنوان', 'الرصيد', 'ملاحظات', 'تاريخ الإضافة']));
    for (var s in suppliers) {
      sb.write(_row([s.id, s.name, s.phone, s.address, s.balance, s.notes, _df.format(s.createdAt)]));
    }
    return sb.toString();
  }

  // ============= EMPLOYEES =============
  static String employeesToCsv(List<Employee> employees) {
    final sb = StringBuffer(_bom);
    sb.write(_row(['ID', 'الاسم', 'الوظيفة', 'الهاتف', 'الراتب', 'ملاحظات', 'تاريخ الإضافة']));
    for (var e in employees) {
      sb.write(_row([e.id, e.name, e.position, e.phone, e.salary, e.notes, _df.format(e.createdAt)]));
    }
    return sb.toString();
  }

  // ============= PRODUCTS =============
  static String productsToCsv(List<Product> products) {
    final sb = StringBuffer(_bom);
    sb.write(_row([
      'ID', 'الاسم', 'الفئة', 'الباركود', 'الوحدة',
      'الكمية', 'سعر الشراء', 'سعر البيع', 'قيمة المخزون', 'ملاحظات'
    ]));
    for (var p in products) {
      sb.write(_row([
        p.id, p.name, p.category, p.barcode, p.unit,
        p.quantity, p.buyPrice, p.sellPrice, (p.buyPrice * p.quantity), p.notes
      ]));
    }
    return sb.toString();
  }

  // ============= INVOICES =============
  static String invoicesToCsv(List<Invoice> invoices, String type) {
    final sb = StringBuffer(_bom);
    final isSale = type == 'sale';
    sb.write(_row([
      'رقم الفاتورة', 'التاريخ', isSale ? 'العميل' : 'المورد',
      'عدد الأصناف', 'الإجمالي قبل الضريبة', 'الخصم',
      'الضريبة %', 'الإجمالي', 'المدفوع', 'المتبقي', 'الحالة', 'ملاحظات'
    ]));
    for (var inv in invoices) {
      final status = inv.remaining <= 0.01
          ? 'مدفوعة'
          : inv.paid > 0
              ? 'جزئية'
              : 'غير مدفوعة';
      sb.write(_row([
        inv.id, _df.format(inv.date), inv.contactName,
        inv.items.length, inv.subtotal, inv.discount,
        inv.tax, inv.totalAmount, inv.paid, inv.remaining, status, inv.notes
      ]));
    }
    return sb.toString();
  }

  // ============= INVOICE ITEMS DETAILS =============
  static String invoiceItemsToCsv(List<Invoice> invoices, String type) {
    final sb = StringBuffer(_bom);
    final isSale = type == 'sale';
    sb.write(_row([
      'رقم الفاتورة', 'التاريخ', isSale ? 'العميل' : 'المورد',
      'المنتج', 'الكمية', 'السعر', 'الخصم', 'الإجمالي'
    ]));
    for (var inv in invoices) {
      for (var item in inv.items) {
        sb.write(_row([
          inv.id, _df.format(inv.date), inv.contactName,
          item.productName, item.quantity, item.price, item.discount, item.total
        ]));
      }
    }
    return sb.toString();
  }

  // ============= EXPENSES =============
  static String expensesToCsv(List<Expense> expenses) {
    final sb = StringBuffer(_bom);
    sb.write(_row(['ID', 'العنوان', 'الفئة', 'المبلغ', 'التاريخ', 'ملاحظات']));
    for (var e in expenses) {
      sb.write(_row([e.id, e.title, e.category, e.amount, _df.format(e.date), e.notes]));
    }
    return sb.toString();
  }

  // ============= VOUCHERS =============
  static String vouchersToCsv(List<Voucher> vouchers) {
    final sb = StringBuffer(_bom);
    sb.write(_row([
      'ID', 'النوع', 'الجهة', 'نوع الجهة',
      'المبلغ', 'طريقة الدفع', 'التاريخ', 'ملاحظات'
    ]));
    for (var v in vouchers) {
      sb.write(_row([
        v.id, v.type == 'receipt' ? 'قبض' : 'صرف',
        v.contactName, v.contactType == 'client' ? 'عميل' : 'مورد',
        v.amount, v.paymentMethod, _df.format(v.date), v.notes
      ]));
    }
    return sb.toString();
  }
}
