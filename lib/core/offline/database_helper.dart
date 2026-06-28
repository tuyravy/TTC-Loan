import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:apploan/models/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:apploan/models/repayment/model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  DatabaseHelper._privateConstructor();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreateRayment,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createLookupCacheTable(db);
    }
  }

  Future _createLookupCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS LookupCache (
        cache_key TEXT PRIMARY KEY,
        data TEXT,
        updated_at TEXT
      )
    ''');
  }

  //Repayment List
  Future _onCreateRayment(Database db, int version) async {
    await _createLookupCacheTable(db);
    await db.execute('''
      CREATE TABLE Repayment (
        id INTEGER PRIMARY KEY,
        client TEXT,
        loan_officer TEXT,
        branch TEXT,
        client_id TEXT,
        loan_id TEXT,
        mobile TEXT,
        client_code TEXT,
        account_number TEXT,
        cycle TEXT,
        loan_term TEXT,
        photo TEXT,
        principal TEXT,
        disburmentAmt TEXT,
        end_pricipal TEXT,
        interest TEXT,
        monthly_fee TEXT,
        penalty TEXT,
        villages_name TEXT,
        last_payment_date TEXT,
        total_repayment TEXT,
        arrea TEXT,
        total_toclose TEXT,
        status_pay TEXT,
        syncedate TEXT,
        synced TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Product (
        id INTEGER PRIMARY KEY,
        name TEXT,
        interest_rate TEXT,
        principal TEXT,
        loan_term TEXT,
        syncedate TEXT,
        synced TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Staff (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        profile TEXT,
        phone TEXT,
        gender TEXT,
        status TEXT,
        branch_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        profilePath TEXT,
        policy TEXT,
        type TEXT,
        full_name TEXT,
        syncedate TEXT,
        synced TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Users (
        permission TEXT,
        token TEXT,
        user_id TEXT,
        branch_id TEXT,
        name TEXT,
        syncedate TEXT,
        synced TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Collected (
        id INTEGER PRIMARY KEY,
        client TEXT,
        loan_officer TEXT,
        created_by_id TEXT,
        branch TEXT,
        client_id TEXT,
        loan_id TEXT,
        client_code TEXT,
        photo TEXT,
        total_repayment TEXT,
        amount_penalty TEXT,
        currency_id TEXT,
        description TEXT,
        gateway_id TEXT,
        submitted_on TEXT,
        status_pay TEXT,
        syncedate TEXT,
        synced TEXT
      )
    ''');
  }

  Future<int> insertRepayment(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Repayment', row);
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Product', row);
  }

  Future<int> insertStaff(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Staff', row);
  }

  Future<List<RepaymentModel>> queryAllRowsRepayment(int? value_check) async {
    List<RepaymentModel> results = [];
    Database db = await instance.database;

    if (value_check == 2) {
      List<Map<String, Object?>> responseData = await db.query(
        'Repayment',
        columns: [
          'id',
          'client',
          'loan_officer',
          'branch',
          'mobile',
          'client_id',
          'loan_id',
          'client_code',
          'account_number',
          'cycle',
          'loan_term',
          'photo',
          'villages_name',
          'arrea',
          'last_payment_date',
          'end_pricipal as principal',
          'interest',
          'monthly_fee',
          'total_toclose as total_repayment',
        ],
      );

      results = responseData.map((e) => RepaymentModel.fromJson(e)).toList();
    } else {
      List<Map<String, Object?>> responseData = await db.rawQuery(
        'select * from Repayment where loan_id not in(SELECT loan_id FROM Collected)',
      );
      results = responseData.map((e) => RepaymentModel.fromJson(e)).toList();
    }

    return results;
  }

  Future<List<RepaymentModel>> queryAllRowsRepayments(int? value_check) async {
    List<RepaymentModel> results = [];
    Database db = await instance.database;

    if (value_check == 2) {
      List<Map<String, Object?>> responseData = await db.query(
        'Repayment',
        columns: [
          'id',
          'client',
          'loan_officer',
          'branch',
          'mobile',
          'client_id',
          'loan_id',
          'client_code',
          'account_number',
          'cycle',
          'loan_term',
          'photo',
          'villages_name',
          'arrea',
          'last_payment_date',
          'end_pricipal as principal',
          'interest',
          'monthly_fee',
          'total_toclose as total_repayment',
        ],
      );

      results = responseData.map((e) => RepaymentModel.fromJson(e)).toList();
    } else {
      List<Map<String, Object?>> responseData = await db.rawQuery(
        'select * from Repayment where loan_id not in(SELECT loan_id FROM Collected)',
      );
      results = responseData.map((e) => RepaymentModel.fromJson(e)).toList();
    }
    return results;
  }

  Future<int> countCustomersRepayment() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Repayment where loan_id not in(SELECT loan_id FROM Collected)',
          ),
        ) ??
        0;
  }

  Future<int> SumCustomersRepayment() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT sum(total_repayment) FROM Repayment'),
        ) ??
        0;
  }

  //End Repayment List

  Future<List<ProductModel>> queryAllRowsProducts() async {
    List<ProductModel> results = [];
    Database db = await instance.database;
    List<Map<String, Object?>> responseData = await db.rawQuery(
      'select * from Product',
    );
    results = responseData.map((e) => ProductModel.fromJson(e)).toList();
    return results;
  }

  Future<List<StaffModel>> queryAllRowsStaff() async {
    List<StaffModel> results = [];
    Database db = await instance.database;
    List<Map<String, Object?>> responseData = await db.rawQuery(
      'select * from Staff',
    );
    results = responseData.map((e) => StaffModel.fromJson(e)).toList();
    return results;
  }

  Future<int> countCustomersCollection({String? userId}) async {
    Database db = await instance.database;
    if (userId == null) {
      return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM Collected'),
          ) ??
          0;
    }
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Collected WHERE created_by_id = ?',
            [userId],
          ),
        ) ??
        0;
  }

  Future<List<PaymentModel>> queryAllRowsCollectedByUser(String? userId) async {
    Database db = await instance.database;
    if (userId == null) return queryAllRowsCollected();
    final responseData = await db.rawQuery(
      'select * from Collected where created_by_id = ?',
      [userId],
    );
    return responseData.map((e) => PaymentModel.fromDb(e)).toList();
  }

  Future<int> countCustomersRepaymentNotYetSync() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM Collected where synced='0'"),
        ) ??
        0;
  }

  //collected
  // Future<List<PaymentModel>> queryAllRowsCollected() async {
  //   List<PaymentModel> results = [];
  //   Database db = await instance.database;

  //   List<Map<String, Object?>> responseData = await db.rawQuery(
  //     'select * from Collected',
  //   );
  //   results = responseData.map((e) => PaymentModel.fromJson(e)).toList();

  //   return results;
  // }

  // Future<List<PaymentModel>> queryAllRowsCollectedNotYetSync() async {
  //   List<PaymentModel> results = [];
  //   Database db = await instance.database;

  //   List<Map<String, Object?>> responseData = await db.rawQuery(
  //     "select * from Collected where synced='0'",
  //   );

  //   results = responseData.map((e) => PaymentModel.fromJson(e)).toList();
  //   return results;
  // }
  Future<List<PaymentModel>> queryAllRowsCollected() async {
    Database db = await instance.database;
    final responseData = await db.rawQuery('select * from Collected');
    return responseData.map((e) => PaymentModel.fromDb(e)).toList();
  }

  Future<List<PaymentModel>> queryAllRowsCollectedNotYetSync() async {
    Database db = await instance.database;
    final responseData = await db.rawQuery(
      "select * from Collected where synced='0'",
    );
    return responseData.map((e) => PaymentModel.fromDb(e)).toList();
  }

  Future<List<PaymentModel>> queryAllRowsCollectedNotYetSyncByUser(
    String? userId,
  ) async {
    Database db = await instance.database;
    if (userId == null) return queryAllRowsCollectedNotYetSync();
    final responseData = await db.rawQuery(
      "select * from Collected where synced='0' and created_by_id = ?",
      [userId],
    );
    return responseData.map((e) => PaymentModel.fromDb(e)).toList();
  }

  // Future<int> updateCollected(Map<String, dynamic> row) async {
  //   Database db = await instance.database;
  //   String? id = row['loan_id'];
  //   return await db.update(
  //     'Collected',
  //     row,
  //     where: 'loan_id = ?',
  //     whereArgs: [id],
  //   );
  // }
  Future<int> updateCollected(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String? loanId = row['loan_id']?.toString();
    final updateRow = Map<String, dynamic>.from(row)..remove('id');
    return await db.update(
      'Collected',
      updateRow,
      where: 'loan_id = ?',
      whereArgs: [loanId],
    );
  }

  // Future<int> insertCollected(Map<String, dynamic> row) async {
  //   Database db = await instance.database;

  //   final rowId = int.tryParse(row['id']?.toString() ?? '0') ?? 0;

  //   final existing = await db.query(
  //     'Collected',
  //     where: 'id = ?',
  //     whereArgs: [rowId],
  //   );

  //   if (existing.isNotEmpty) {
  //     final existingRecord = existing.first;

  //     double existingAmt =
  //         double.tryParse(
  //           existingRecord['total_repayment']?.toString() ?? '0',
  //         ) ??
  //         0;
  //     double newAmt =
  //         double.tryParse(row['total_repayment']?.toString() ?? '0') ?? 0;

  //     // Always sum — never lose previous amount
  //     row['total_repayment'] = existingAmt + newAmt;

  //     return await db.update(
  //       'Collected',
  //       row,
  //       where: 'id = ?',
  //       whereArgs: [rowId],
  //     );
  //   }

  //   return await db.insert('Collected', row);
  // }
  Future<int> insertCollected(Map<String, dynamic> row) async {
    Database db = await instance.database;
    final loanId = row['loan_id']?.toString();

    final existing = await db.query(
      'Collected',
      where: 'loan_id = ?',
      whereArgs: [loanId],
    );

    final unsyncedExisting =
        existing.where((e) => e['synced']?.toString() == '0').toList();

    if (unsyncedExisting.isNotEmpty) {
      double existingAmt =
          double.tryParse(
            unsyncedExisting.first['total_repayment']?.toString() ?? '0',
          ) ??
          0;
      double newAmt =
          double.tryParse(row['total_repayment']?.toString() ?? '0') ?? 0;
      final updateRow =
          Map<String, dynamic>.from(row)
            ..remove('id')
            ..['total_repayment'] = existingAmt + newAmt;
      return await db.update(
        'Collected',
        updateRow,
        where: 'loan_id = ? and synced = ?',
        whereArgs: [loanId, '0'],
      );
    }

    // Already-synced rows for this loan must stay untouched so the next
    // transfer only ever picks up synced=0 rows; insert this as a new row
    // instead of merging into the synced one.
    //
    // Always let SQLite assign the row's id — callers pass in their own
    // source loan/report id (which is only unique within that report, not
    // across Collected as a whole), so keeping it risks a UNIQUE constraint
    // collision between unrelated loans from different screens. Every
    // lookup against this table is keyed by loan_id, never by id, so this
    // is safe.
    final newRow = Map<String, dynamic>.from(row)..remove('id');
    return await db.insert('Collected', newRow);
  }

  Future<int?> getCollectedMaxId() async {
    Database db = await instance.database;
    // Execute the query and handle exceptions
    try {
      var result = await db.rawQuery(
        'SELECT MAX(id) + 1 as max_id FROM Collected',
      );
      // Check if result is not empty before accessing first element
      if (result.isNotEmpty) {
        // Access the 'max_id' column and cast it to int?
        var maxId = result.first['max_id'] as int?;
        return maxId;
      } else {
        // Handle case where no rows are returned (result is empty)
        return null; // or handle the absence of max_id as needed
      }
    } catch (e) {
      // Handle any exceptions that might occur during query execution
      print('Error while fetching max id: $e');
      return null; // or throw an exception depending on your error handling strategy
    }
  }

  Future<int?> getCollectedItemCountByLoanId(String? loanId) async {
    Database db = await instance.database;

    try {
      var result = await db.rawQuery(
        'SELECT count(*) as total FROM Collected WHERE loan_id = ?',
        [loanId],
      );

      if (result.isNotEmpty) {
        return result.first['total'] as int?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error while fetching collected item count: $e');
      return null;
    }
  }

  Future<void> truncateTable(String syncDate) async {
    Database db = await instance.database;
    await db.delete('Collected');
    await db.delete('Repayment');
    await db.delete('Product');
    await db.delete('Staff');
    await db.delete('Users');
    await db.delete('LookupCache');
    await db.execute('VACUUM'); // This resets the auto-increment counter.
  }

  Future<void> truncateTableCollected(String syncDate) async {
    Database db = await instance.database;
    await db.delete('Collected', where: 'syncedate < ?', whereArgs: [syncDate]);
    // await db.delete('Collected');
    await db.execute('VACUUM'); // This resets the auto-increment counter.
  }

  Future<void> DeleteCollected() async {
    Database db = await instance.database;
    await db.delete('Collected', where: 'synced = ?', whereArgs: [1]);
    // await db.delete('Collected');
    await db.execute('VACUUM'); // This resets the auto-increment counter.
  }

  Future<void> DeleteCollectedByID(int id) async {
    Database db = await instance.database;
    await db.delete('Collected', where: 'id = ?', whereArgs: [id]);
    // await db.delete('Collected');
    await db.execute('VACUUM'); // This resets the auto-increment counter.
  }

  /// Removes the local row for [loanId] right after a successful submit —
  /// once the server has it, there's no need to keep it around locally.
  Future<void> deleteCollectedByLoanId(String loanId) async {
    Database db = await instance.database;
    await db.delete('Collected', where: 'loan_id = ?', whereArgs: [loanId]);
  }

  Future<int> countCustomersCollect() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Repayment where loan_id not in(SELECT loan_id FROM Collected)',
          ),
        ) ??
        0;
  }

  Future<int> updateRepayment(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('Repayment', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteRepayment(int id) async {
    Database db = await instance.database;
    return await db.delete('Repayment', where: 'id = ?', whereArgs: [id]);
  }

  // Generic lookup-data cache, keyed by [cacheKey].
  // Stores a list of raw JSON maps (e.g. an API response's `data` list) so it
  // can be read back later without calling the API again.
  Future<void> cacheLookupList(
    String cacheKey,
    List<Map<String, dynamic>> rows,
  ) async {
    Database db = await instance.database;
    await db.insert('LookupCache', {
      'cache_key': cacheKey,
      'data': jsonEncode(rows),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>?> getCachedLookupList(
    String cacheKey,
  ) async {
    Database db = await instance.database;
    final rows = await db.query(
      'LookupCache',
      columns: ['data'],
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.first['data'] as String) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> clearLookupCache([String? cacheKey]) async {
    Database db = await instance.database;
    if (cacheKey == null) {
      await db.delete('LookupCache');
    } else {
      await db.delete(
        'LookupCache',
        where: 'cache_key = ?',
        whereArgs: [cacheKey],
      );
    }
  }
}
