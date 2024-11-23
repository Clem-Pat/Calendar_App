import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'diner.dart';
import 'invite.dart';
import 'plat.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dinner_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    _initFfi();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _initFfi() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE invite (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        name TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE plat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        ingredients TEXT,
        recipe TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE diner_invite (
        diner_id INTEGER NOT NULL,
        invite_id INTEGER NOT NULL,
        FOREIGN KEY (diner_id) REFERENCES diner(id),
        FOREIGN KEY (invite_id) REFERENCES invite(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE diner_plat (
        diner_id INTEGER NOT NULL,
        plat_id INTEGER NOT NULL,
        FOREIGN KEY (diner_id) REFERENCES diner(id),
        FOREIGN KEY (plat_id) REFERENCES plat(id)
      );
    ''');
  }

  Future<int> insertDiner(Diner diner) async {
    final db = await instance.database;
    return await db.insert('diner', diner.toMap());
  }

  Future<List<Diner>> getAllDiners() async {
    final db = await instance.database;
    final result = await db.query('diner');

    return result.map((json) => Diner(id: json['id'] as int, name: json['name'] as String, date: json['date'] as String)).toList();
  }

  Future<List<Map<String, dynamic>>> queryAllDiners() async {
    final db = await instance.database;
    return await db.query('diner');
  }

  Future<List<Map<String, dynamic>>> queryAllPlats() async {
    final db = await instance.database;
    return await db.query('plat');
  }

  Future<Map<String, dynamic>> queryDinerById(int id) async {
    final db = await instance.database;
    final result = await db.query('diner', where: 'id = ?', whereArgs: [id]);
    return result.first;
  }


  Future<List<Map<String, dynamic>>> queryPlatsForDiner(int dinerId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT plat.name, plat.recipe
      FROM plat
      INNER JOIN diner_plat ON plat.id = diner_plat.plat_id
      WHERE diner_plat.diner_id = ?
    ''', [dinerId]);
  }

  Future<int> insertInvite(Invite invite) async {
    final db = await instance.database;
    return await db.insert('invite', invite.toMap());
  }

  Future<int> insertPlat(Plat plat) async {
    final db = await instance.database;
    return await db.insert('plat', plat.toMap());
  }

  Future<void> insertDinerInvite(int dinerId, int inviteId) async {
    final db = await instance.database;
    await db.insert('diner_invite', {'diner_id': dinerId, 'invite_id': inviteId});
  }

  Future<void> insertDinerPlat(int dinerId, int platId) async {
    final db = await instance.database;
    await db.insert('diner_plat', {'diner_id': dinerId, 'plat_id': platId});
  }

  Future<List<Map<String, dynamic>>> queryInvitesForDiner(int dinerId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT invite.first_name, invite.name
      FROM invite
      INNER JOIN diner_invite ON invite.id = diner_invite.invite_id
      WHERE diner_invite.diner_id = ?
    ''', [dinerId]);
  }
  
  Future<List<Invite>> getInvitesForDiner(int dinerId) async {
    final db = await instance.database;
    final result = await db.query(
      'invite',
      columns: ['first_name', 'name'],
      where: 'diner_id = ?',
      whereArgs: [dinerId],
    );
    return result.map((row) => Invite.fromMap(row)).toList();
  }

  Future<List<String>> getInvitesNamesForDiner(int dinerId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT invite.first_name, invite.name
      FROM invite
      INNER JOIN diner_invite ON invite.id = diner_invite.invite_id
      WHERE diner_invite.diner_id = ?
    ''', [dinerId]);
    return result.map((row) => '${row['first_name']} ${row['name']}').toList();
  }

  Future<List<Plat>> getPlatsForDiner(int dinerId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT p.id, p.name, p.description, p.ingredients, p.recipe
      FROM plat p
      JOIN diner_plat dp ON p.id = dp.plat_id
      WHERE dp.diner_id = $dinerId
    ''');

    return result.map((json) => Plat(id: json['id'] as int, name: json['name'] as String, description: json['description'] as String, ingredients: json['ingredients'] as String, recipe: json['recipe'] as String)).toList();
  }

  Future<void> deleteDiner(int dinerId) async {
    final db = await instance.database;
    await db.delete('diner', where: 'id = ?', whereArgs: [dinerId]);
  }

  Future<void> deleteInvite(int inviteId) async {
    final db = await instance.database;
    await db.delete('invite', where: 'id = ?', whereArgs: [inviteId]);
  }

  Future<void> deletePlat(int platId) async {
    final db = await instance.database;
    await db.delete('plat', where: 'id = ?', whereArgs: [platId]);
  }

  Future<void> deleteInvitesForDiner(int dinerId) async {
    final db = await database;
    await db.delete(
      'diner_invite',
      where: 'diner_id = ?',
      whereArgs: [dinerId],
    );
  }

  Future<void> deletePlatsForDiner(int dinerId) async {
    final db = await database;
    await db.delete(
      'diner_plat',
      where: 'diner_id = ?',
      whereArgs: [dinerId],
    );
  }

  Future<void> deleteDinerInvite(int dinerId, int inviteId) async {
    final db = await instance.database;
    await db.delete('diner_invite', where: 'diner_id = ? AND invite_id = ?', whereArgs: [dinerId, inviteId]);
  }

  Future<void> deleteDinerPlat(int dinerId, int platId) async {
    final db = await instance.database;
    await db.delete('diner_plat', where: 'diner_id = ? AND plat_id = ?', whereArgs: [dinerId, platId]);
  }

  Future<void> updateDiner(Diner diner) async {
    final db = await instance.database;
    await db.update('diner', diner.toMap(), where: 'id = ?', whereArgs: [diner.id]);
  }

  Future<void> updateInvite(Invite invite) async {
    final db = await instance.database;
    await db.update('invite', invite.toMap(), where: 'id = ?', whereArgs: [invite.id]);
  }

  Future<void> updatePlat(Plat plat) async {
    final db = await instance.database;
    await db.update('plat', plat.toMap(), where: 'id = ?', whereArgs: [plat.id]);
  }

  Future<void> updateDinerInvite(int dinerId, int inviteId) async {
    final db = await instance.database;
    await db.update('diner_invite', {'diner_id': dinerId, 'invite_id': inviteId}, where: 'diner_id = ? AND invite_id = ?', whereArgs: [dinerId, inviteId]);
  }

  Future<void> updateDinerPlat(int dinerId, int platId) async {
    final db = await instance.database;
    await db.update('diner_plat', {'diner_id': dinerId, 'plat_id': platId}, where: 'diner_id = ? AND plat_id = ?', whereArgs: [dinerId, platId]);
  }

  Future<void> deleteAll() async {
    final db = await instance.database;
    await db.delete('diner');
    await db.delete('invite');
    await db.delete('plat');
    await db.delete('diner_invite');
    await db.delete('diner_plat');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> printTable(String tableName) async {
  final db = await instance.database;
  final result = await db.query(tableName);
  print('Table: $tableName');
  result.forEach((row) {
    print(row);
  });
}

Future<void> printAllTables() async {
  await printTable('diner');
  await printTable('invite');
  await printTable('diner_invite');
  await printTable('plat');
  await printTable('diner_plat');
}


}