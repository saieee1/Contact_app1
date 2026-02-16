import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/contact.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        photoUrl TEXT,
        address TEXT,
        company TEXT,
        jobTitle TEXT,
        birthday TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Create
  Future<Contact> insertContact(Contact contact) async {
    Database db = await database;
    contact.createdAt = DateTime.now();
    contact.updatedAt = DateTime.now();
    int id = await db.insert('contacts', contact.toMap());
    return contact.copyWith(id: id);
  }

  // Read all
  Future<List<Contact>> getAllContacts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Read favorites
  Future<List<Contact>> getFavoriteContacts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Read single contact
  Future<Contact?> getContact(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  // Update
  Future<int> updateContact(Contact contact) async {
    Database db = await database;
    contact.updatedAt = DateTime.now();
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete
  Future<int> deleteContact(int id) async {
    Database db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle favorite
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    Database db = await database;
    return await db.update(
      'contacts',
      {
        'isFavorite': isFavorite ? 1 : 0,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search contacts
  Future<List<Contact>> searchContacts(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'name LIKE ? OR phoneNumber LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }
}