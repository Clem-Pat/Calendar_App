import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'diner.dart';
import 'invite.dart';
import 'plat.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  
  Future<MySqlConnection> _createConnection() async {
    try {
      final publicUrl0 = "mysql://root:qtlozpjYmZrMfKioxmFrAUcYxoUwnRuA@autorack.proxy.rlwy.net:39228/railway";
      final publicUrl = "mysql://root:VeucxKPpzypxltmUjplTqWuDoYoPOsih@autorack.proxy.rlwy.net:33328/railway";
      final uri = Uri.parse(publicUrl);
      
      print('Host: ${uri.host}');
      print('Port: ${uri.port}');
      print('User: ${uri.userInfo.split(':')[0]}');
      print('PW: ${uri.userInfo.split(':')[1]}');
      print('Database: ${uri.pathSegments[0]}');
      
      // final settings = ConnectionSettings(
      //   host: uri.host,
      //   port: uri.hasPort ? uri.port : 3306, // Default port for MySQL
      //   user: uri.userInfo.split(':')[0],
      //   password: uri.userInfo.split(':')[1],
      //   db: uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null,
      //   useSSL: false,
      //   timeout: Duration(seconds: 30),
      // );
      var settings = ConnectionSettings(
          host: 'autorack.proxy.rlwy.net',
          port: 3306,
          user: 'root',
          password: 'VeucxKPpzypxltmUjplTqWuDoYoPOsih',
          db: 'railway',
          useSSL: false,
      );
      
      return await MySqlConnection.connect(settings);
    } catch (e) {
      print('Error connecting to the database: $e');
      //rethrow;
      throw Exception('Failed to connect to the database');
    }
  }

  late Future<MySqlConnection> db = _createConnection();

  DatabaseHelper._internal();


  Future<void> closeConnection(MySqlConnection connection) async {
    await connection.close();
  }

  Future<void> testDB() async{
    //final db = await _createConnection();
    try {
      var connection = await db;
      var results = await connection.query('SELECT * FROM diner');
      for (var row in results) {
        print(row);
      }
    } catch (e) {
      print('While Testing : Error connecting to the database: $e');
      // Handle retries or show user-friendly message
    } finally {
      //await closeConnection(db);
    }
  }

  Future<int> insertDiner(Diner diner) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var result = await connection.query('INSERT INTO diner (name, date) VALUES (?, ?)', [diner.name, diner.date]);
      return result.insertId!;
    } catch (e) {
      print('Error inserting diner: $e');
      return -1; // Return a default value or handle the error appropriately
    } finally {
      //await closeConnection(db);
    }
  }

  Future<Map<String, dynamic>?> queryDinerById(int id) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var results = await connection.query('SELECT * FROM diner WHERE id = ?', [id]);
      if (results.isNotEmpty) {
        return results.first.fields;
      }
      return null;
    } catch (e) {
      print('Error querying diner by ID: $e');
      //rethrow;
      return null;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<List<Map<String, dynamic>>> queryAllDiners() async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var results = await connection.query('SELECT * FROM diner');
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error querying all diners: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> queryPlatsForDiner(int dinerId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var results = await connection.query('SELECT * FROM plats WHERE diner_id = ?', [dinerId]);
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error querying plats for diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
    return [];
  }

  Future<int> insertInvite(Invite invite) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var result = await connection.query('INSERT INTO invites (first_name, name) VALUES (?, ?)', [invite.first_name, invite.name]);
      return result.insertId!;
    } catch (e) {
      print('Error inserting invite: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
    return -1; // Return a default value or handle the error appropriately
  }

  Future<int> insertPlat(Plat plat) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var result = await connection.query('INSERT INTO plats (name, description) VALUES (?, ?)', [plat.name, plat.description]);
      return result.insertId!;
    } catch (e) {
      print('Error inserting plat: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
    return -1; // Return a default value or handle the error appropriately
  }

  Future<void> insertDinerInvite(int dinerId, int inviteId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('INSERT INTO diner_invite (diner_id, invite_id) VALUES (?, ?)', [dinerId, inviteId]);
    } catch (e) {
      print('Error inserting diner invite: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> insertDinerPlat(int dinerId, int platId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('INSERT INTO diner_plat (diner_id, plat_id) VALUES (?, ?)', [dinerId, platId]);
    } catch (e) {
      print('Error inserting diner plat: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<List<Map<String, dynamic>>> queryInvitesForDiner(int dinerId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      var results = await connection.query('SELECT * FROM invites WHERE id IN (SELECT invite_id FROM diner_invite WHERE diner_id = ?)', [dinerId]);
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error querying invites for diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
    return []; // Return an empty list in case of an error
  }

  Future<void> deleteDiner(int id) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('DELETE FROM diner WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> deleteInvite(int id) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('DELETE FROM invites WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting invite: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> deletePlat(int id) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('DELETE FROM plats WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting plat: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> deleteInvitesForDiner(int dinerId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('DELETE FROM diner_invite WHERE diner_id = ?', [dinerId]);
    } catch (e) {
      print('Error deleting invites for diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> deletePlatsForDiner(int dinerId) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('DELETE FROM diner_plat WHERE diner_id = ?', [dinerId]);
    } catch (e) {
      print('Error deleting plats for diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> updateDiner(Diner diner) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      await connection.query('UPDATE diner SET name = ?, date = ? WHERE id = ?', [diner.name, diner.date, diner.id]);
    } catch (e) {
      print('Error updating diner: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> printTable(String tableName) async {
    //final db = await _createConnection();
    try {
      var connection = await db;
      final result = await connection.query('SELECT * FROM $tableName');
      print('Table: $tableName');
      result.forEach((row) {
        print(row.fields);
      });
    } catch (e) {
      print('Error printing table: $e');
      //rethrow;
    } finally {
      //await closeConnection(db);
    }
  }

  Future<void> printAllTables() async {
    await printTable('diner');
    await printTable('invite');
    await printTable('diner_invite');
    await printTable('plat');
    await printTable('diner_plat');
  }

  deleteAll() {}
}