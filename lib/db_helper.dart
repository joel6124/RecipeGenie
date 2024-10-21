import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as dev;

class RecipeDatabaseHelper {
  static final RecipeDatabaseHelper _instance =
      RecipeDatabaseHelper._internal();
  static Database? _database;
  int? _loggedInUserId;

  factory RecipeDatabaseHelper() {
    return _instance;
  }

  RecipeDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(
      join(await getDatabasesPath(), filePath),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT)''');
        await db.execute('''CREATE TABLE favourite_recipes (
          id TEXT PRIMARY KEY,
          name TEXT,
          imageUrl TEXT,
          description TEXT,
          ingredients TEXT,
          directions TEXT,
          duration TEXT,
          difficulty TEXT,
          servings INTEGER,
          calories INTEGER,
          carbs TEXT,
          protein TEXT,
          fat TEXT,
          user_id INTEGER, 
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)''');
        await db.execute('''CREATE TABLE user_added_recipes (
          id TEXT PRIMARY KEY,
          name TEXT,
          imageUrl TEXT,
          description TEXT,
          ingredients TEXT,
          directions TEXT,
          duration TEXT,
          difficulty TEXT,
          servings INTEGER,
          calories INTEGER,
          carbs TEXT,
          protein TEXT,
          fat TEXT,
          user_id INTEGER, 
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)''');
      },
    );
  }

  // User Management Methods
  Future<void> registerUser(String username, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (users.isNotEmpty) {
      _loggedInUserId = users.first['id']; // Store logged-in user's ID
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getLoggedInUsername() async {
    final db = await database;
    if (_loggedInUserId == null) return null;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [_loggedInUserId],
    );

    return users.isNotEmpty ? users.first['username'] : null;
  }

  Future<void> logout() async {
    _loggedInUserId = null; // Clear the logged-in user ID
  }

  // Recipe Management Methods
  Future<void> insertFavouriteRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    recipe['user_id'] =
        _loggedInUserId; // Associate recipe with the logged-in user
    await db.insert(
      'favourite_recipes',
      recipe,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // New method to insert user-added recipes
  Future<void> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    recipe['user_id'] =
        _loggedInUserId; // Associate recipe with the logged-in user
    await db.insert(
      'user_added_recipes',
      recipe,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFavouriteRecipes() async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final List<Map<String, dynamic>> dbFavRecipes = await db.query(
        'favourite_recipes',
        where: 'user_id = ?',
        whereArgs: [_loggedInUserId],
      );
      dev.log(dbFavRecipes.toString()); // Log retrieved recipes
      return dbFavRecipes;
    } catch (e) {
      dev.log('Error retrieving recipes: $e'); // Log error if any
      return []; // Return an empty list on error
    }
  }

  Future<List<Map<String, dynamic>>> getPublicsRecipes() async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final List<Map<String, dynamic>> userAddedRecipes = await db.query(
        'user_added_recipes',
      );
      dev.log(userAddedRecipes.toString());
      return userAddedRecipes;
    } catch (e) {
      dev.log('Error retrieving user added recipes: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserAddedRecipes() async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final List<Map<String, dynamic>> userAddedRecipes = await db.query(
        'user_added_recipes',
        where: 'user_id = ?',
        whereArgs: [_loggedInUserId],
      );
      dev.log(userAddedRecipes.toString());
      return userAddedRecipes;
    } catch (e) {
      dev.log('Error retrieving user added recipes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRecipeDetails(String recipeName) async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    var result = await db.query('favourite_recipes',
        where: 'name = ? AND user_id = ?',
        whereArgs: [recipeName, _loggedInUserId]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getRecipeFromDb() async {
    final db = await database;
    return await db.query('user_added_recipes');
  }

  Future<void> removeRecipe(String id) async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    await db.delete(
      'favourite_recipes',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, _loggedInUserId],
    );
  }

  Future<void> deleteAllRecipes() async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    await db.delete(
      'favourite_recipes',
      where: 'user_id = ?',
      whereArgs: [_loggedInUserId],
    );
  }

  Future<void> deleteFavRecipeTable() async {
    final db = await database;
    await db.execute('DROP TABLE favourite_recipes;');
  }
}
