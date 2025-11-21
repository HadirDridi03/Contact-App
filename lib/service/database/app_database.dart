import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../model/contact_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  static Database? _database;

  AppDatabase._();

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'contacts_app.db');

    // Dans la méthode _initDB()
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
        photoPath TEXT,                     -- NOUVELLE COLONNE
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

  //AUTH 
  Future<int> createUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {'email': email, 'password': password});
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

  Future<int?> getLoggedInUserId() async {
    final db = await database;
    final result = await db.rawQuery('SELECT id FROM users LIMIT 1');
    return result.isNotEmpty ? result.first['id'] as int? : null;
  }

  //CONTACTS
  Future<List<Contact>> getAllContacts(int userId) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Contact.fromMap(m['id'] as String, m)).toList();
  }

  Future<List<Contact>> searchContacts(int userId, String query) async {
    final db = await database;
    final maps = await db.query(
      'contacts',
      where: 'userId = ? AND name LIKE ?',
      whereArgs: [userId, '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Contact.fromMap(m['id'] as String, m)).toList();
  }

  Future<void> insertContact(Contact contact, int userId) async {
    final db = await database;
    await db.insert('contacts', {
      ...contact.toMap(),
      'userId': userId,
    });
  }

  Future<void> updateContact(Contact contact, int userId) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ? AND userId = ?',
      whereArgs: [contact.id, userId],
    );
  }

  Future<void> deleteContact(String id, int userId) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ? AND userId = ?', whereArgs: [id, userId]);
  }

Future<bool> contactExists(String contactId, int userId) async {
  final db = await database;
  final result = await db.query(
    'contacts',
    where: 'id = ? AND userId = ?',
    whereArgs: [contactId, userId],
  );
  return result.isNotEmpty;
}}