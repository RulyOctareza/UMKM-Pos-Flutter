import 'package:drift/drift.dart';

/// Skema tabel toko (Stores)
@DataClassName('StoreTableData')
class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get pin => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Skema tabel kategori produk (Categories)
@DataClassName('CategoryTableData')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Skema tabel produk & stok (Products)
@DataClassName('ProductTableData')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get price => real()();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get minStockAlert => integer().withDefault(const Constant(5))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  TextColumn get barcode => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Skema tabel transaksi penjualan (Transactions)
@DataClassName('TransactionTableData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()(); // 'cash', 'qris', 'transfer'
  RealColumn get cashReceived => real().withDefault(const Constant(0.0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Skema tabel detail item transaksi (TransactionItems)
@DataClassName('TransactionItemTableData')
class TransactionItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get priceAtSale => real()();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}
