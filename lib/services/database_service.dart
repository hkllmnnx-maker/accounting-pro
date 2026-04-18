import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late Box _clientsBox;
  late Box _suppliersBox;
  late Box _employeesBox;
  late Box _productsBox;
  late Box _salesBox;
  late Box _purchasesBox;
  late Box _expensesBox;
  late Box _vouchersBox;
  late Box _exchangesBox;
  late Box _journalBox;
  late Box _quotesBox;
  // ignore: unused_field
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _clientsBox = await Hive.openBox('clients');
    _suppliersBox = await Hive.openBox('suppliers');
    _employeesBox = await Hive.openBox('employees');
    _productsBox = await Hive.openBox('products');
    _salesBox = await Hive.openBox('sales');
    _purchasesBox = await Hive.openBox('purchases');
    _expensesBox = await Hive.openBox('expenses');
    _vouchersBox = await Hive.openBox('vouchers');
    _exchangesBox = await Hive.openBox('exchanges');
    _journalBox = await Hive.openBox('journal');
    _quotesBox = await Hive.openBox('quotes');
    _settingsBox = await Hive.openBox('settings');

    if (_clientsBox.isEmpty) await _loadSampleData();
  }

  // ============= CLIENTS =============
  List<Client> getClients() => _clientsBox.values
      .map((e) => Client.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> saveClient(Client c) => _clientsBox.put(c.id, c.toMap());
  Future<void> deleteClient(String id) => _clientsBox.delete(id);

  // ============= SUPPLIERS =============
  List<Supplier> getSuppliers() => _suppliersBox.values
      .map((e) => Supplier.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> saveSupplier(Supplier s) => _suppliersBox.put(s.id, s.toMap());
  Future<void> deleteSupplier(String id) => _suppliersBox.delete(id);

  // ============= EMPLOYEES =============
  List<Employee> getEmployees() => _employeesBox.values
      .map((e) => Employee.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> saveEmployee(Employee e) => _employeesBox.put(e.id, e.toMap());
  Future<void> deleteEmployee(String id) => _employeesBox.delete(id);

  // ============= PRODUCTS =============
  List<Product> getProducts() => _productsBox.values
      .map((e) => Product.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> saveProduct(Product p) => _productsBox.put(p.id, p.toMap());
  Future<void> deleteProduct(String id) => _productsBox.delete(id);

  Product? getProduct(String id) {
    final data = _productsBox.get(id);
    if (data == null) return null;
    return Product.fromMap(Map<dynamic, dynamic>.from(data));
  }

  // ============= SALES =============
  List<Invoice> getSales() => _salesBox.values
      .map((e) => Invoice.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveSale(Invoice inv) => _salesBox.put(inv.id, inv.toMap());
  Future<void> deleteSale(String id) => _salesBox.delete(id);

  /// حفظ فاتورة بيع مع تحديث المخزون ورصيد العميل
  Future<void> saveSaleWithSideEffects(Invoice inv, {Invoice? oldInvoice}) async {
    // عكس التأثير القديم إن وجد
    if (oldInvoice != null) {
      _reverseInvoiceStock(oldInvoice, isSale: true);
      _reverseInvoiceClientBalance(oldInvoice);
    }
    // تطبيق التأثير الجديد
    _applyInvoiceStock(inv, isSale: true);
    _applyInvoiceClientBalance(inv);
    await _salesBox.put(inv.id, inv.toMap());
  }

  Future<void> deleteSaleWithSideEffects(String id) async {
    final data = _salesBox.get(id);
    if (data != null) {
      final inv = Invoice.fromMap(Map<dynamic, dynamic>.from(data));
      _reverseInvoiceStock(inv, isSale: true);
      _reverseInvoiceClientBalance(inv);
    }
    await _salesBox.delete(id);
  }

  // ============= PURCHASES =============
  List<Invoice> getPurchases() => _purchasesBox.values
      .map((e) => Invoice.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> savePurchase(Invoice inv) => _purchasesBox.put(inv.id, inv.toMap());
  Future<void> deletePurchase(String id) => _purchasesBox.delete(id);

  /// حفظ فاتورة شراء مع تحديث المخزون ورصيد المورد
  Future<void> savePurchaseWithSideEffects(Invoice inv, {Invoice? oldInvoice}) async {
    if (oldInvoice != null) {
      _reverseInvoiceStock(oldInvoice, isSale: false);
      _reverseInvoiceSupplierBalance(oldInvoice);
    }
    _applyInvoiceStock(inv, isSale: false);
    _applyInvoiceSupplierBalance(inv);
    await _purchasesBox.put(inv.id, inv.toMap());
  }

  Future<void> deletePurchaseWithSideEffects(String id) async {
    final data = _purchasesBox.get(id);
    if (data != null) {
      final inv = Invoice.fromMap(Map<dynamic, dynamic>.from(data));
      _reverseInvoiceStock(inv, isSale: false);
      _reverseInvoiceSupplierBalance(inv);
    }
    await _purchasesBox.delete(id);
  }

  // ============= HELPERS: Stock & Balance =============
  void _applyInvoiceStock(Invoice inv, {required bool isSale}) {
    for (var item in inv.items) {
      if (item.productId.isEmpty) continue;
      final data = _productsBox.get(item.productId);
      if (data == null) continue;
      final p = Product.fromMap(Map<dynamic, dynamic>.from(data));
      // البيع ينقص المخزون، الشراء يزيده
      p.quantity += isSale ? -item.quantity : item.quantity;
      _productsBox.put(p.id, p.toMap());
    }
  }

  void _reverseInvoiceStock(Invoice inv, {required bool isSale}) {
    for (var item in inv.items) {
      if (item.productId.isEmpty) continue;
      final data = _productsBox.get(item.productId);
      if (data == null) continue;
      final p = Product.fromMap(Map<dynamic, dynamic>.from(data));
      // العكس: البيع يعيد المخزون، الشراء يخصمه
      p.quantity += isSale ? item.quantity : -item.quantity;
      _productsBox.put(p.id, p.toMap());
    }
  }

  void _applyInvoiceClientBalance(Invoice inv) {
    if (inv.contactId.isEmpty) return;
    final data = _clientsBox.get(inv.contactId);
    if (data == null) return;
    final c = Client.fromMap(Map<dynamic, dynamic>.from(data));
    // رصيد العميل يزيد بالمتبقي (المبلغ المستحق له علينا مديناً)
    c.balance += inv.remaining;
    _clientsBox.put(c.id, c.toMap());
  }

  void _reverseInvoiceClientBalance(Invoice inv) {
    if (inv.contactId.isEmpty) return;
    final data = _clientsBox.get(inv.contactId);
    if (data == null) return;
    final c = Client.fromMap(Map<dynamic, dynamic>.from(data));
    c.balance -= inv.remaining;
    _clientsBox.put(c.id, c.toMap());
  }

  void _applyInvoiceSupplierBalance(Invoice inv) {
    if (inv.contactId.isEmpty) return;
    final data = _suppliersBox.get(inv.contactId);
    if (data == null) return;
    final s = Supplier.fromMap(Map<dynamic, dynamic>.from(data));
    // رصيد المورد يزيد بالمتبقي (نحن مدينون له)
    s.balance += inv.remaining;
    _suppliersBox.put(s.id, s.toMap());
  }

  void _reverseInvoiceSupplierBalance(Invoice inv) {
    if (inv.contactId.isEmpty) return;
    final data = _suppliersBox.get(inv.contactId);
    if (data == null) return;
    final s = Supplier.fromMap(Map<dynamic, dynamic>.from(data));
    s.balance -= inv.remaining;
    _suppliersBox.put(s.id, s.toMap());
  }

  // ============= EXPENSES =============
  List<Expense> getExpenses() => _expensesBox.values
      .map((e) => Expense.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveExpense(Expense e) => _expensesBox.put(e.id, e.toMap());
  Future<void> deleteExpense(String id) => _expensesBox.delete(id);

  // ============= VOUCHERS =============
  List<Voucher> getVouchers() => _vouchersBox.values
      .map((e) => Voucher.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveVoucher(Voucher v) => _vouchersBox.put(v.id, v.toMap());
  Future<void> deleteVoucher(String id) => _vouchersBox.delete(id);

  /// حفظ السند مع تحديث رصيد العميل/المورد
  Future<void> saveVoucherWithSideEffects(Voucher v, {Voucher? oldVoucher}) async {
    if (oldVoucher != null) {
      _reverseVoucherBalance(oldVoucher);
    }
    _applyVoucherBalance(v);
    await _vouchersBox.put(v.id, v.toMap());
  }

  Future<void> deleteVoucherWithSideEffects(String id) async {
    final data = _vouchersBox.get(id);
    if (data != null) {
      final v = Voucher.fromMap(Map<dynamic, dynamic>.from(data));
      _reverseVoucherBalance(v);
    }
    await _vouchersBox.delete(id);
  }

  void _applyVoucherBalance(Voucher v) {
    if (v.contactId.isEmpty) return;
    if (v.contactType == 'client') {
      final data = _clientsBox.get(v.contactId);
      if (data == null) return;
      final c = Client.fromMap(Map<dynamic, dynamic>.from(data));
      // سند قبض: رصيد العميل ينقص، سند صرف: يزيد
      c.balance += v.type == 'receipt' ? -v.amount : v.amount;
      _clientsBox.put(c.id, c.toMap());
    } else {
      final data = _suppliersBox.get(v.contactId);
      if (data == null) return;
      final s = Supplier.fromMap(Map<dynamic, dynamic>.from(data));
      // سند صرف لمورد: رصيد المورد ينقص، سند قبض منه: يزيد
      s.balance += v.type == 'payment' ? -v.amount : v.amount;
      _suppliersBox.put(s.id, s.toMap());
    }
  }

  void _reverseVoucherBalance(Voucher v) {
    if (v.contactId.isEmpty) return;
    if (v.contactType == 'client') {
      final data = _clientsBox.get(v.contactId);
      if (data == null) return;
      final c = Client.fromMap(Map<dynamic, dynamic>.from(data));
      c.balance -= v.type == 'receipt' ? -v.amount : v.amount;
      _clientsBox.put(c.id, c.toMap());
    } else {
      final data = _suppliersBox.get(v.contactId);
      if (data == null) return;
      final s = Supplier.fromMap(Map<dynamic, dynamic>.from(data));
      s.balance -= v.type == 'payment' ? -v.amount : v.amount;
      _suppliersBox.put(s.id, s.toMap());
    }
  }

  // ============= EXCHANGES =============
  List<CurrencyExchange> getExchanges() => _exchangesBox.values
      .map((e) => CurrencyExchange.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveExchange(CurrencyExchange ex) => _exchangesBox.put(ex.id, ex.toMap());
  Future<void> deleteExchange(String id) => _exchangesBox.delete(id);

  // ============= JOURNAL ENTRIES =============
  List<JournalEntry> getJournalEntries() => _journalBox.values
      .map((e) => JournalEntry.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveJournalEntry(JournalEntry je) => _journalBox.put(je.id, je.toMap());
  Future<void> deleteJournalEntry(String id) => _journalBox.delete(id);

  // ============= QUOTES =============
  List<Quote> getQuotes() => _quotesBox.values
      .map((e) => Quote.fromMap(Map<dynamic, dynamic>.from(e)))
      .toList()..sort((a, b) => b.date.compareTo(a.date));

  Future<void> saveQuote(Quote q) => _quotesBox.put(q.id, q.toMap());
  Future<void> deleteQuote(String id) => _quotesBox.delete(id);

  // ============= ACCOUNT STATEMENTS =============
  List<AccountEntry> getAccountStatement(String contactId) {
    final sales = getSales().where((s) => s.contactId == contactId);
    final purchases = getPurchases().where((p) => p.contactId == contactId);
    final vouchers = getVouchers().where((v) => v.contactId == contactId);

    List<AccountEntry> entries = [];
    double balance = 0;

    for (var s in sales) {
      balance += s.totalAmount;
      entries.add(AccountEntry(
        id: s.id, description: 'فاتورة بيع #${s.id.substring(0, 6)}',
        debit: s.totalAmount, balance: balance, date: s.date,
        referenceType: 'sale', referenceId: s.id,
      ));
    }
    for (var p in purchases) {
      balance -= p.totalAmount;
      entries.add(AccountEntry(
        id: p.id, description: 'فاتورة شراء #${p.id.substring(0, 6)}',
        credit: p.totalAmount, balance: balance, date: p.date,
        referenceType: 'purchase', referenceId: p.id,
      ));
    }
    for (var v in vouchers) {
      if (v.type == 'receipt') {
        balance -= v.amount;
        entries.add(AccountEntry(
          id: v.id, description: 'سند قبض',
          credit: v.amount, balance: balance, date: v.date,
          referenceType: 'voucher', referenceId: v.id,
        ));
      } else {
        balance += v.amount;
        entries.add(AccountEntry(
          id: v.id, description: 'سند صرف',
          debit: v.amount, balance: balance, date: v.date,
          referenceType: 'voucher', referenceId: v.id,
        ));
      }
    }

    entries.sort((a, b) => a.date.compareTo(b.date));
    double runBal = 0;
    for (var e in entries) {
      runBal += e.debit - e.credit;
      e.balance = runBal;
    }
    return entries;
  }

  // ============= DATE-FILTERED STATS =============
  Map<String, dynamic> getFilteredStats(DateTime from, DateTime to) {
    final sales = getSales().where((s) =>
        !s.date.isBefore(DateTime(from.year, from.month, from.day)) &&
        !s.date.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59)));
    final purchases = getPurchases().where((p) =>
        !p.date.isBefore(DateTime(from.year, from.month, from.day)) &&
        !p.date.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59)));
    final expenses = getExpenses().where((e) =>
        !e.date.isBefore(DateTime(from.year, from.month, from.day)) &&
        !e.date.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59)));

    final totalSales = sales.fold(0.0, (s, i) => s + i.totalAmount);
    final totalPurchases = purchases.fold(0.0, (s, i) => s + i.totalAmount);
    final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);

    return {
      'salesCount': sales.length,
      'purchasesCount': purchases.length,
      'expensesCount': expenses.length,
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalExpenses': totalExpenses,
      'grossProfit': totalSales - totalPurchases,
      'netProfit': totalSales - totalPurchases - totalExpenses,
    };
  }

  List<Map<String, dynamic>> getFilteredExpensesByCategory(DateTime from, DateTime to) {
    final expenses = getExpenses().where((e) =>
        !e.date.isBefore(DateTime(from.year, from.month, from.day)) &&
        !e.date.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59)));
    final Map<String, double> catMap = {};
    for (var e in expenses) {
      catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
    }
    return catMap.entries.map((e) => {'category': e.key, 'amount': e.value}).toList();
  }

  // ============= DASHBOARD STATS =============
  Map<String, dynamic> getDashboardStats() {
    final today = DateTime.now();
    // Today's date for filtering

    final sales = getSales();
    final purchases = getPurchases();
    final expenses = getExpenses();

    final todaySales = sales.where((s) =>
        s.date.year == today.year && s.date.month == today.month && s.date.day == today.day);
    final todayPurchases = purchases.where((p) =>
        p.date.year == today.year && p.date.month == today.month && p.date.day == today.day);
    final todayExpenses = expenses.where((e) =>
        e.date.year == today.year && e.date.month == today.month && e.date.day == today.day);

    final monthlySales = sales.where((s) =>
        s.date.year == today.year && s.date.month == today.month);
    final monthlyPurchases = purchases.where((p) =>
        p.date.year == today.year && p.date.month == today.month);
    final monthlyExpenses = expenses.where((e) =>
        e.date.year == today.year && e.date.month == today.month);

    return {
      'clientsCount': getClients().length,
      'suppliersCount': getSuppliers().length,
      'employeesCount': getEmployees().length,
      'productsCount': getProducts().length,
      'todaySales': todaySales.fold(0.0, (s, i) => s + i.totalAmount),
      'todayPurchases': todayPurchases.fold(0.0, (s, i) => s + i.totalAmount),
      'todayExpenses': todayExpenses.fold(0.0, (s, e) => s + e.amount),
      'monthlySales': monthlySales.fold(0.0, (s, i) => s + i.totalAmount),
      'monthlyPurchases': monthlyPurchases.fold(0.0, (s, i) => s + i.totalAmount),
      'monthlyExpenses': monthlyExpenses.fold(0.0, (s, e) => s + e.amount),
      'totalSales': sales.fold(0.0, (s, i) => s + i.totalAmount),
      'totalPurchases': purchases.fold(0.0, (s, i) => s + i.totalAmount),
      'totalExpenses': expenses.fold(0.0, (s, e) => s + e.amount),
      'salesCount': sales.length,
      'purchasesCount': purchases.length,
      'clientsBalance': getClients().fold(0.0, (s, c) => s + c.balance),
      'suppliersBalance': getSuppliers().fold(0.0, (s, su) => s + su.balance),
    };
  }

  // ============= CHART DATA =============
  List<Map<String, dynamic>> getMonthlySalesData() {
    final sales = getSales();
    final now = DateTime.now();
    List<Map<String, dynamic>> data = [];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthSales = sales.where((s) =>
          s.date.year == month.year && s.date.month == month.month);
      final monthPurchases = getPurchases().where((p) =>
          p.date.year == month.year && p.date.month == month.month);
      data.add({
        'month': month.month,
        'year': month.year,
        'sales': monthSales.fold(0.0, (s, i) => s + i.totalAmount),
        'purchases': monthPurchases.fold(0.0, (s, i) => s + i.totalAmount),
      });
    }
    return data;
  }

  List<Map<String, dynamic>> getExpensesByCategory() {
    final expenses = getExpenses();
    final Map<String, double> catMap = {};
    for (var e in expenses) {
      catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
    }
    return catMap.entries.map((e) => {'category': e.key, 'amount': e.value}).toList();
  }

  // ============= NEW: TOP PRODUCTS / TOP CLIENTS REPORTS =============
  /// Returns the top selling products in the given period, ordered by total quantity sold.
  /// Each entry contains: productId, productName, quantity, revenue, invoicesCount.
  List<Map<String, dynamic>> getTopProducts(DateTime from, DateTime to, {int limit = 10}) {
    final sales = getSales().where((s) =>
        !s.date.isBefore(from) && !s.date.isAfter(to));
    final Map<String, Map<String, dynamic>> agg = {};
    for (var inv in sales) {
      for (var item in inv.items) {
        final key = item.productId.isNotEmpty ? item.productId : item.productName;
        final existing = agg[key];
        if (existing == null) {
          agg[key] = {
            'productId': item.productId,
            'productName': item.productName,
            'quantity': item.quantity,
            'revenue': item.total,
            'invoicesCount': 1,
          };
        } else {
          existing['quantity'] = (existing['quantity'] as int) + item.quantity;
          existing['revenue'] = (existing['revenue'] as double) + item.total;
          existing['invoicesCount'] = (existing['invoicesCount'] as int) + 1;
        }
      }
    }
    final list = agg.values.toList();
    list.sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
    return list.take(limit).toList();
  }

  /// Returns the top clients in the given period, ordered by total purchases.
  /// Each entry contains: clientId, clientName, totalSales, invoicesCount, lastPurchase.
  List<Map<String, dynamic>> getTopClients(DateTime from, DateTime to, {int limit = 10}) {
    final sales = getSales().where((s) =>
        !s.date.isBefore(from) && !s.date.isAfter(to) && s.contactName.isNotEmpty);
    final Map<String, Map<String, dynamic>> agg = {};
    for (var inv in sales) {
      final key = inv.contactId.isNotEmpty ? inv.contactId : inv.contactName;
      final existing = agg[key];
      if (existing == null) {
        agg[key] = {
          'clientId': inv.contactId,
          'clientName': inv.contactName,
          'totalSales': inv.totalAmount,
          'invoicesCount': 1,
          'lastPurchase': inv.date,
        };
      } else {
        existing['totalSales'] = (existing['totalSales'] as double) + inv.totalAmount;
        existing['invoicesCount'] = (existing['invoicesCount'] as int) + 1;
        final last = existing['lastPurchase'] as DateTime;
        if (inv.date.isAfter(last)) existing['lastPurchase'] = inv.date;
      }
    }
    final list = agg.values.toList();
    list.sort((a, b) => (b['totalSales'] as double).compareTo(a['totalSales'] as double));
    return list.take(limit).toList();
  }

  /// Returns top suppliers by total purchases in the given period.
  List<Map<String, dynamic>> getTopSuppliers(DateTime from, DateTime to, {int limit = 10}) {
    final purchases = getPurchases().where((p) =>
        !p.date.isBefore(from) && !p.date.isAfter(to) && p.contactName.isNotEmpty);
    final Map<String, Map<String, dynamic>> agg = {};
    for (var inv in purchases) {
      final key = inv.contactId.isNotEmpty ? inv.contactId : inv.contactName;
      final existing = agg[key];
      if (existing == null) {
        agg[key] = {
          'supplierId': inv.contactId,
          'supplierName': inv.contactName,
          'totalPurchases': inv.totalAmount,
          'invoicesCount': 1,
          'lastPurchase': inv.date,
        };
      } else {
        existing['totalPurchases'] = (existing['totalPurchases'] as double) + inv.totalAmount;
        existing['invoicesCount'] = (existing['invoicesCount'] as int) + 1;
        final last = existing['lastPurchase'] as DateTime;
        if (inv.date.isAfter(last)) existing['lastPurchase'] = inv.date;
      }
    }
    final list = agg.values.toList();
    list.sort((a, b) => (b['totalPurchases'] as double).compareTo(a['totalPurchases'] as double));
    return list.take(limit).toList();
  }

  /// Returns last 7 days' sales/expenses summary for the home dashboard sparkline.
  /// Returns a list ordered oldest -> newest.
  List<Map<String, dynamic>> getLast7DaysActivity() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> result = [];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final next = day.add(const Duration(days: 1));
      final daySales = getSales().where((s) =>
          !s.date.isBefore(day) && s.date.isBefore(next));
      final dayExpenses = getExpenses().where((e) =>
          !e.date.isBefore(day) && e.date.isBefore(next));
      result.add({
        'date': day,
        'sales': daySales.fold<double>(0, (sum, inv) => sum + inv.totalAmount),
        'expenses': dayExpenses.fold<double>(0, (sum, e) => sum + e.amount),
        'salesCount': daySales.length,
      });
    }
    return result;
  }

  /// Returns inventory valuation summary: totalProducts, totalQuantity, totalCostValue, totalSellValue, expectedProfit.
  Map<String, dynamic> getInventoryValuation() {
    final products = getProducts();
    double costValue = 0, sellValue = 0;
    int totalQuantity = 0;
    int outOfStock = 0, lowStock = 0;
    for (var p in products) {
      costValue += p.buyPrice * p.quantity;
      sellValue += p.sellPrice * p.quantity;
      totalQuantity += p.quantity;
      if (p.quantity <= 0) {
        outOfStock++;
      } else if (p.quantity <= 10) {
        lowStock++;
      }
    }
    return {
      'totalProducts': products.length,
      'totalQuantity': totalQuantity,
      'costValue': costValue,
      'sellValue': sellValue,
      'expectedProfit': sellValue - costValue,
      'outOfStock': outOfStock,
      'lowStock': lowStock,
    };
  }

  // ============= SAMPLE DATA =============
  Future<void> _loadSampleData() async {
    final clients = [
      Client(id: 'c1', name: 'احمد محمد', phone: '0501234567', address: 'الرياض', balance: 5000),
      Client(id: 'c2', name: 'خالد العلي', phone: '0509876543', address: 'جدة', balance: 3200),
      Client(id: 'c3', name: 'محمد سعيد', phone: '0551112233', address: 'الدمام', balance: 1500),
      Client(id: 'c4', name: 'عبدالله حسن', phone: '0567778899', address: 'مكة', balance: 8000),
      Client(id: 'c5', name: 'فهد ابراهيم', phone: '0534445566', address: 'المدينة', balance: 2700),
    ];
    for (var c in clients) {
      await saveClient(c);
    }

    final suppliers = [
      Supplier(id: 's1', name: 'شركة النور للتوريدات', phone: '0112223344', address: 'الرياض', balance: 15000),
      Supplier(id: 's2', name: 'مؤسسة الأمل التجارية', phone: '0115556677', address: 'جدة', balance: 8500),
      Supplier(id: 's3', name: 'شركة الفجر', phone: '0118889900', address: 'الدمام', balance: 6200),
    ];
    for (var s in suppliers) {
      await saveSupplier(s);
    }

    final employees = [
      Employee(id: 'e1', name: 'سعد الدوسري', phone: '0541112233', position: 'محاسب', salary: 7000),
      Employee(id: 'e2', name: 'عمر الشهري', phone: '0542223344', position: 'مدير مبيعات', salary: 9000),
      Employee(id: 'e3', name: 'يوسف القحطاني', phone: '0543334455', position: 'أمين مخزن', salary: 5500),
    ];
    for (var e in employees) {
      await saveEmployee(e);
    }

    final products = [
      Product(id: 'p1', name: 'لابتوب HP', category: 'إلكترونيات', buyPrice: 2500, sellPrice: 3200, quantity: 15, unit: 'قطعة'),
      Product(id: 'p2', name: 'طابعة كانون', category: 'إلكترونيات', buyPrice: 800, sellPrice: 1100, quantity: 25, unit: 'قطعة'),
      Product(id: 'p3', name: 'ورق A4', category: 'قرطاسية', buyPrice: 15, sellPrice: 22, quantity: 500, unit: 'رزمة'),
      Product(id: 'p4', name: 'حبر طابعة', category: 'قرطاسية', buyPrice: 45, sellPrice: 65, quantity: 100, unit: 'علبة'),
      Product(id: 'p5', name: 'شاشة سامسونج', category: 'إلكترونيات', buyPrice: 1200, sellPrice: 1600, quantity: 10, unit: 'قطعة'),
      Product(id: 'p6', name: 'كيبورد لوجيتك', category: 'إلكترونيات', buyPrice: 120, sellPrice: 180, quantity: 50, unit: 'قطعة'),
      Product(id: 'p7', name: 'ماوس لاسلكي', category: 'إلكترونيات', buyPrice: 60, sellPrice: 95, quantity: 80, unit: 'قطعة'),
      Product(id: 'p8', name: 'كرسي مكتبي', category: 'أثاث', buyPrice: 350, sellPrice: 500, quantity: 20, unit: 'قطعة'),
    ];
    for (var p in products) {
      await saveProduct(p);
    }

    final now = DateTime.now();
    final sales = [
      Invoice(id: 'inv1', type: 'sale', contactId: 'c1', contactName: 'احمد محمد',
        items: [InvoiceItem(productId: 'p1', productName: 'لابتوب HP', quantity: 2, price: 3200)],
        tax: 15, paid: 5000, date: now),
      Invoice(id: 'inv2', type: 'sale', contactId: 'c2', contactName: 'خالد العلي',
        items: [InvoiceItem(productId: 'p3', productName: 'ورق A4', quantity: 10, price: 22),
          InvoiceItem(productId: 'p4', productName: 'حبر طابعة', quantity: 5, price: 65)],
        tax: 15, paid: 400, date: now.subtract(const Duration(days: 1))),
      Invoice(id: 'inv3', type: 'sale', contactId: 'c3', contactName: 'محمد سعيد',
        items: [InvoiceItem(productId: 'p5', productName: 'شاشة سامسونج', quantity: 1, price: 1600)],
        tax: 15, paid: 1840, date: now.subtract(const Duration(days: 3))),
    ];
    for (var s in sales) {
      await saveSale(s);
    }

    final purchases = [
      Invoice(id: 'pur1', type: 'purchase', contactId: 's1', contactName: 'شركة النور للتوريدات',
        items: [InvoiceItem(productId: 'p1', productName: 'لابتوب HP', quantity: 5, price: 2500)],
        tax: 15, paid: 10000, date: now.subtract(const Duration(days: 2))),
      Invoice(id: 'pur2', type: 'purchase', contactId: 's2', contactName: 'مؤسسة الأمل التجارية',
        items: [InvoiceItem(productId: 'p3', productName: 'ورق A4', quantity: 100, price: 15)],
        tax: 15, paid: 1500, date: now.subtract(const Duration(days: 5))),
    ];
    for (var p in purchases) {
      await savePurchase(p);
    }

    final expensesList = [
      Expense(id: 'exp1', title: 'إيجار المكتب', category: 'إيجار', amount: 5000, date: now),
      Expense(id: 'exp2', title: 'فاتورة كهرباء', category: 'مرافق', amount: 800, date: now.subtract(const Duration(days: 1))),
      Expense(id: 'exp3', title: 'صيانة طابعة', category: 'صيانة', amount: 350, date: now.subtract(const Duration(days: 4))),
      Expense(id: 'exp4', title: 'نقل بضائع', category: 'نقل', amount: 600, date: now.subtract(const Duration(days: 2))),
    ];
    for (var e in expensesList) {
      await saveExpense(e);
    }

    final vouchersList = [
      Voucher(id: 'v1', type: 'receipt', contactId: 'c1', contactName: 'احمد محمد',
        contactType: 'client', amount: 2000, paymentMethod: 'نقدي', date: now),
      Voucher(id: 'v2', type: 'payment', contactId: 's1', contactName: 'شركة النور للتوريدات',
        contactType: 'supplier', amount: 5000, paymentMethod: 'تحويل بنكي', date: now.subtract(const Duration(days: 1))),
    ];
    for (var v in vouchersList) {
      await saveVoucher(v);
    }
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ============= BACKUP & RESTORE =============
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'version': '2.0',
      'exportDate': DateTime.now().toIso8601String(),
      'clients': _clientsBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'suppliers': _suppliersBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'employees': _employeesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'products': _productsBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'sales': _salesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'purchases': _purchasesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'expenses': _expensesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'vouchers': _vouchersBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'exchanges': _exchangesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'journal': _journalBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
      'quotes': _quotesBox.values.map((e) => Map<String, dynamic>.from(e)).toList(),
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    Future<void> restore(Box box, String key) async {
      await box.clear();
      final items = (data[key] as List?) ?? [];
      for (var item in items) {
        final map = Map<String, dynamic>.from(item as Map);
        await box.put(map['id'], map);
      }
    }
    await restore(_clientsBox, 'clients');
    await restore(_suppliersBox, 'suppliers');
    await restore(_employeesBox, 'employees');
    await restore(_productsBox, 'products');
    await restore(_salesBox, 'sales');
    await restore(_purchasesBox, 'purchases');
    await restore(_expensesBox, 'expenses');
    await restore(_vouchersBox, 'vouchers');
    await restore(_exchangesBox, 'exchanges');
    await restore(_journalBox, 'journal');
    await restore(_quotesBox, 'quotes');
  }

  Future<void> clearAllData() async {
    await _clientsBox.clear();
    await _suppliersBox.clear();
    await _employeesBox.clear();
    await _productsBox.clear();
    await _salesBox.clear();
    await _purchasesBox.clear();
    await _expensesBox.clear();
    await _vouchersBox.clear();
    await _exchangesBox.clear();
    await _journalBox.clear();
    await _quotesBox.clear();
  }
}
