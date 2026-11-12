
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'spendwise.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Menambahkan transaksi
  Future<int> insertTransaction(
    TransactionModel transaction,
  ) async {
    final db = await database;

    return await db.insert(
      'transactions',
      transaction.toMap(),
    );
  }

  // Mengambil semua transaksi
  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;

    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );

    return result
        .map((e) => TransactionModel.fromMap(e))
        .toList();
  }

  // Mengedit transaksi
  Future<int> updateTransaction(
    TransactionModel transaction,
  ) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Menghapus transaksi
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghitung saldo dan ringkasan transaksi
  Future<Map<String, int>> getSummary() async {
    final db = await database;

    final incomeResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = 'income'
    ''');

    final expenseResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM transactions
      WHERE type = 'expense'
    ''');

    final income = (incomeResult.first['total'] as num).toInt();
    final expense = (expenseResult.first['total'] as num).toInt();

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
