// ============= CLIENT MODEL =============
class Client {
  String id;
  String name;
  String phone;
  String address;
  double balance;
  String notes;
  DateTime createdAt;

  Client({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.balance = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'address': address, 'balance': balance,
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory Client.fromMap(Map<dynamic, dynamic> map) => Client(
    id: map['id'] ?? '', name: map['name'] ?? '',
    phone: map['phone'] ?? '', address: map['address'] ?? '',
    balance: (map['balance'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= SUPPLIER MODEL =============
class Supplier {
  String id;
  String name;
  String phone;
  String address;
  double balance;
  String notes;
  DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.balance = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'address': address, 'balance': balance,
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory Supplier.fromMap(Map<dynamic, dynamic> map) => Supplier(
    id: map['id'] ?? '', name: map['name'] ?? '',
    phone: map['phone'] ?? '', address: map['address'] ?? '',
    balance: (map['balance'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= EMPLOYEE MODEL =============
class Employee {
  String id;
  String name;
  String phone;
  String position;
  double salary;
  String notes;
  DateTime createdAt;

  Employee({
    required this.id,
    required this.name,
    this.phone = '',
    this.position = '',
    this.salary = 0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'position': position, 'salary': salary,
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory Employee.fromMap(Map<dynamic, dynamic> map) => Employee(
    id: map['id'] ?? '', name: map['name'] ?? '',
    phone: map['phone'] ?? '', position: map['position'] ?? '',
    salary: (map['salary'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= PRODUCT MODEL =============
class Product {
  String id;
  String name;
  String category;
  double buyPrice;
  double sellPrice;
  int quantity;
  String unit;
  String barcode;
  String notes;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.category = '',
    this.buyPrice = 0,
    this.sellPrice = 0,
    this.quantity = 0,
    this.unit = '',
    this.barcode = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'category': category,
    'buyPrice': buyPrice, 'sellPrice': sellPrice,
    'quantity': quantity, 'unit': unit, 'barcode': barcode,
    'notes': notes, 'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromMap(Map<dynamic, dynamic> map) => Product(
    id: map['id'] ?? '', name: map['name'] ?? '',
    category: map['category'] ?? '',
    buyPrice: (map['buyPrice'] ?? 0).toDouble(),
    sellPrice: (map['sellPrice'] ?? 0).toDouble(),
    quantity: (map['quantity'] ?? 0).toInt(),
    unit: map['unit'] ?? '', barcode: map['barcode'] ?? '',
    notes: map['notes'] ?? '',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= INVOICE ITEM =============
class InvoiceItem {
  String productId;
  String productName;
  int quantity;
  double price;
  double discount;

  InvoiceItem({
    required this.productId,
    required this.productName,
    this.quantity = 1,
    this.price = 0,
    this.discount = 0,
  });

  double get total => (price * quantity) - discount;

  Map<String, dynamic> toMap() => {
    'productId': productId, 'productName': productName,
    'quantity': quantity, 'price': price, 'discount': discount,
  };

  factory InvoiceItem.fromMap(Map<dynamic, dynamic> map) => InvoiceItem(
    productId: map['productId'] ?? '',
    productName: map['productName'] ?? '',
    quantity: (map['quantity'] ?? 1).toInt(),
    price: (map['price'] ?? 0).toDouble(),
    discount: (map['discount'] ?? 0).toDouble(),
  );
}

// ============= INVOICE MODEL =============
class Invoice {
  String id;
  String type; // 'sale' or 'purchase'
  String contactId;
  String contactName;
  List<InvoiceItem> items;
  double discount;
  double tax;
  double paid;
  String notes;
  DateTime date;
  DateTime createdAt;

  Invoice({
    required this.id,
    required this.type,
    this.contactId = '',
    this.contactName = '',
    List<InvoiceItem>? items,
    this.discount = 0,
    this.tax = 0,
    this.paid = 0,
    this.notes = '',
    DateTime? date,
    DateTime? createdAt,
  })  : items = items ?? [],
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * (tax / 100);
  double get totalAmount => subtotal - discount + taxAmount;
  double get remaining => totalAmount - paid;

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'contactId': contactId,
    'contactName': contactName,
    'items': items.map((e) => e.toMap()).toList(),
    'discount': discount, 'tax': tax, 'paid': paid,
    'notes': notes, 'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Invoice.fromMap(Map<dynamic, dynamic> map) => Invoice(
    id: map['id'] ?? '', type: map['type'] ?? 'sale',
    contactId: map['contactId'] ?? '',
    contactName: map['contactName'] ?? '',
    items: (map['items'] as List?)?.map((e) => InvoiceItem.fromMap(e)).toList() ?? [],
    discount: (map['discount'] ?? 0).toDouble(),
    tax: (map['tax'] ?? 0).toDouble(),
    paid: (map['paid'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= EXPENSE MODEL =============
class Expense {
  String id;
  String title;
  String category;
  double amount;
  String notes;
  DateTime date;
  DateTime createdAt;

  Expense({
    required this.id,
    required this.title,
    this.category = '',
    this.amount = 0,
    this.notes = '',
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'category': category,
    'amount': amount, 'notes': notes,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Expense.fromMap(Map<dynamic, dynamic> map) => Expense(
    id: map['id'] ?? '', title: map['title'] ?? '',
    category: map['category'] ?? '',
    amount: (map['amount'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= VOUCHER MODEL (Receipt/Payment) =============
class Voucher {
  String id;
  String type; // 'receipt' or 'payment'
  String contactId;
  String contactName;
  String contactType; // 'client' or 'supplier'
  double amount;
  String paymentMethod;
  String notes;
  DateTime date;
  DateTime createdAt;

  Voucher({
    required this.id,
    required this.type,
    this.contactId = '',
    this.contactName = '',
    this.contactType = 'client',
    this.amount = 0,
    this.paymentMethod = '',
    this.notes = '',
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'contactId': contactId,
    'contactName': contactName, 'contactType': contactType,
    'amount': amount, 'paymentMethod': paymentMethod,
    'notes': notes, 'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Voucher.fromMap(Map<dynamic, dynamic> map) => Voucher(
    id: map['id'] ?? '', type: map['type'] ?? 'receipt',
    contactId: map['contactId'] ?? '',
    contactName: map['contactName'] ?? '',
    contactType: map['contactType'] ?? 'client',
    amount: (map['amount'] ?? 0).toDouble(),
    paymentMethod: map['paymentMethod'] ?? '',
    notes: map['notes'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= ACCOUNT STATEMENT ENTRY =============
class AccountEntry {
  String id;
  String description;
  double debit;
  double credit;
  double balance;
  DateTime date;
  String referenceType;
  String referenceId;

  AccountEntry({
    required this.id,
    required this.description,
    this.debit = 0,
    this.credit = 0,
    this.balance = 0,
    DateTime? date,
    this.referenceType = '',
    this.referenceId = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'description': description,
    'debit': debit, 'credit': credit, 'balance': balance,
    'date': date.toIso8601String(),
    'referenceType': referenceType, 'referenceId': referenceId,
  };

  factory AccountEntry.fromMap(Map<dynamic, dynamic> map) => AccountEntry(
    id: map['id'] ?? '', description: map['description'] ?? '',
    debit: (map['debit'] ?? 0).toDouble(),
    credit: (map['credit'] ?? 0).toDouble(),
    balance: (map['balance'] ?? 0).toDouble(),
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    referenceType: map['referenceType'] ?? '',
    referenceId: map['referenceId'] ?? '',
  );
}

// ============= CURRENCY EXCHANGE =============
class CurrencyExchange {
  String id;
  String fromCurrency;
  String toCurrency;
  double amount;
  double rate;
  double result;
  String notes;
  DateTime date;
  DateTime createdAt;

  CurrencyExchange({
    required this.id,
    this.fromCurrency = 'USD',
    this.toCurrency = 'IQD',
    this.amount = 0,
    this.rate = 0,
    this.result = 0,
    this.notes = '',
    DateTime? date,
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'fromCurrency': fromCurrency, 'toCurrency': toCurrency,
    'amount': amount, 'rate': rate, 'result': result,
    'notes': notes, 'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory CurrencyExchange.fromMap(Map<dynamic, dynamic> map) => CurrencyExchange(
    id: map['id'] ?? '', fromCurrency: map['fromCurrency'] ?? 'USD',
    toCurrency: map['toCurrency'] ?? 'IQD',
    amount: (map['amount'] ?? 0).toDouble(),
    rate: (map['rate'] ?? 0).toDouble(),
    result: (map['result'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

// ============= JOURNAL ENTRY (Multi-Entry) =============
class JournalEntry {
  String id;
  String description;
  List<JournalLine> lines;
  DateTime date;
  DateTime createdAt;

  JournalEntry({
    required this.id,
    this.description = '',
    List<JournalLine>? lines,
    DateTime? date,
    DateTime? createdAt,
  })  : lines = lines ?? [],
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get totalDebit => lines.fold(0, (s, l) => s + l.debit);
  double get totalCredit => lines.fold(0, (s, l) => s + l.credit);
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;

  Map<String, dynamic> toMap() => {
    'id': id, 'description': description,
    'lines': lines.map((e) => e.toMap()).toList(),
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromMap(Map<dynamic, dynamic> map) => JournalEntry(
    id: map['id'] ?? '', description: map['description'] ?? '',
    lines: (map['lines'] as List?)?.map((e) => JournalLine.fromMap(e)).toList() ?? [],
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class JournalLine {
  String account;
  double debit;
  double credit;
  String notes;

  JournalLine({
    this.account = '',
    this.debit = 0,
    this.credit = 0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'account': account, 'debit': debit,
    'credit': credit, 'notes': notes,
  };

  factory JournalLine.fromMap(Map<dynamic, dynamic> map) => JournalLine(
    account: map['account'] ?? '',
    debit: (map['debit'] ?? 0).toDouble(),
    credit: (map['credit'] ?? 0).toDouble(),
    notes: map['notes'] ?? '',
  );
}

// ============= QUOTE/ORDER MODEL =============
class Quote {
  String id;
  String type; // 'quote' or 'order'
  String contactId;
  String contactName;
  List<InvoiceItem> items;
  double discount;
  double tax;
  String status; // 'pending', 'approved', 'rejected', 'converted'
  String notes;
  DateTime date;
  DateTime validUntil;
  DateTime createdAt;

  Quote({
    required this.id,
    this.type = 'quote',
    this.contactId = '',
    this.contactName = '',
    List<InvoiceItem>? items,
    this.discount = 0,
    this.tax = 0,
    this.status = 'pending',
    this.notes = '',
    DateTime? date,
    DateTime? validUntil,
    DateTime? createdAt,
  })  : items = items ?? [],
        date = date ?? DateTime.now(),
        validUntil = validUntil ?? DateTime.now().add(const Duration(days: 30)),
        createdAt = createdAt ?? DateTime.now();

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get taxAmount => subtotal * (tax / 100);
  double get totalAmount => subtotal - discount + taxAmount;

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'contactId': contactId,
    'contactName': contactName,
    'items': items.map((e) => e.toMap()).toList(),
    'discount': discount, 'tax': tax, 'status': status,
    'notes': notes, 'date': date.toIso8601String(),
    'validUntil': validUntil.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Quote.fromMap(Map<dynamic, dynamic> map) => Quote(
    id: map['id'] ?? '', type: map['type'] ?? 'quote',
    contactId: map['contactId'] ?? '',
    contactName: map['contactName'] ?? '',
    items: (map['items'] as List?)?.map((e) => InvoiceItem.fromMap(e)).toList() ?? [],
    discount: (map['discount'] ?? 0).toDouble(),
    tax: (map['tax'] ?? 0).toDouble(),
    status: map['status'] ?? 'pending',
    notes: map['notes'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    validUntil: DateTime.tryParse(map['validUntil'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}
