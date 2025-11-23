import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../model/contact_model.dart';

class AppDatabase {
  // Singleton
  static final AppDatabase instance = AppDatabase._internal();
  factory AppDatabase() => instance;
  AppDatabase._internal();

  static Database? _database;
  final _uuid = Uuid();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'contacts_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE contacts (
            id TEXT PRIMARY KEY,
            userId INTEGER NOT NULL,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            photoPath TEXT,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE contacts ADD COLUMN photoPath TEXT');
        }
      },
    );
  }

  // ────────────────────────────────────────
  // AUTH
  // ────────────────────────────────────────

  Future<int> createUser(String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ────────────────────────────────────────
  // CONTACTS
  // ────────────────────────────────────────

  Future<void> saveContact(Contact contact, int userId) async {
    final db = await database;

    final map = contact.toMap();
    map['userId'] = userId; 

    final existing = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contact.id],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'contacts',
        map,
        where: 'id = ?',
        whereArgs: [contact.id],
      );
    } else {
      await db.insert('contacts', map);
    }
  }

  Future<List<Contact>> getAllContacts(int userId) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return maps.map(Contact.fromMap).toList();
  }

  Future<List<Contact>> searchContacts(int userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'userId = ? AND name LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map(Contact.fromMap).toList();
  }

  // AJOUTÉES ICI : LES MÉTHODES MANQUANTES
  Future<void> deleteContact(String contactId, int userId) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ? AND userId = ?',
      whereArgs: [contactId, userId],
    );
  }

  Future<bool> contactExists(String contactId, int userId) async {
    if (contactId.isEmpty) return false;
    final db = await database;
    final result = await db.query(
      'contacts',
      columns: ['id'],
      where: 'id = ? AND userId = ?',
      whereArgs: [contactId, userId],
    );
    return result.isNotEmpty;
  }
}
