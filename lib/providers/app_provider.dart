import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  void refresh() => notifyListeners();

  // Clients
  List<Client> get clients => _db.getClients();
  Future<void> saveClient(Client c) async { await _db.saveClient(c); notifyListeners(); }
  Future<void> deleteClient(String id) async { await _db.deleteClient(id); notifyListeners(); }

  // Suppliers
  List<Supplier> get suppliers => _db.getSuppliers();
  Future<void> saveSupplier(Supplier s) async { await _db.saveSupplier(s); notifyListeners(); }
  Future<void> deleteSupplier(String id) async { await _db.deleteSupplier(id); notifyListeners(); }

  // Employees
  List<Employee> get employees => _db.getEmployees();
  Future<void> saveEmployee(Employee e) async { await _db.saveEmployee(e); notifyListeners(); }
  Future<void> deleteEmployee(String id) async { await _db.deleteEmployee(id); notifyListeners(); }

  // Products
  List<Product> get products => _db.getProducts();
  Future<void> saveProduct(Product p) async { await _db.saveProduct(p); notifyListeners(); }
  Future<void> deleteProduct(String id) async { await _db.deleteProduct(id); notifyListeners(); }

  // Sales
  List<Invoice> get sales => _db.getSales();
  Future<void> saveSale(Invoice inv) async { await _db.saveSale(inv); notifyListeners(); }
  Future<void> deleteSale(String id) async { await _db.deleteSale(id); notifyListeners(); }

  // Purchases
  List<Invoice> get purchases => _db.getPurchases();
  Future<void> savePurchase(Invoice inv) async { await _db.savePurchase(inv); notifyListeners(); }
  Future<void> deletePurchase(String id) async { await _db.deletePurchase(id); notifyListeners(); }

  // Expenses
  List<Expense> get expenses => _db.getExpenses();
  Future<void> saveExpense(Expense e) async { await _db.saveExpense(e); notifyListeners(); }
  Future<void> deleteExpense(String id) async { await _db.deleteExpense(id); notifyListeners(); }

  // Vouchers
  List<Voucher> get vouchers => _db.getVouchers();
  Future<void> saveVoucher(Voucher v) async { await _db.saveVoucher(v); notifyListeners(); }
  Future<void> deleteVoucher(String id) async { await _db.deleteVoucher(id); notifyListeners(); }

  // Exchanges
  List<CurrencyExchange> get exchanges => _db.getExchanges();
  Future<void> saveExchange(CurrencyExchange ex) async { await _db.saveExchange(ex); notifyListeners(); }
  Future<void> deleteExchange(String id) async { await _db.deleteExchange(id); notifyListeners(); }

  // Journal
  List<JournalEntry> get journalEntries => _db.getJournalEntries();
  Future<void> saveJournalEntry(JournalEntry je) async { await _db.saveJournalEntry(je); notifyListeners(); }
  Future<void> deleteJournalEntry(String id) async { await _db.deleteJournalEntry(id); notifyListeners(); }

  // Quotes
  List<Quote> get quotes => _db.getQuotes();
  Future<void> saveQuote(Quote q) async { await _db.saveQuote(q); notifyListeners(); }
  Future<void> deleteQuote(String id) async { await _db.deleteQuote(id); notifyListeners(); }

  // Account Statement
  List<AccountEntry> getAccountStatement(String contactId) => _db.getAccountStatement(contactId);

  // Dashboard
  Map<String, dynamic> get dashboardStats => _db.getDashboardStats();

  // Charts
  List<Map<String, dynamic>> get monthlySalesData => _db.getMonthlySalesData();
  List<Map<String, dynamic>> get expensesByCategory => _db.getExpensesByCategory();

  String generateId() => _db.generateId();
}
