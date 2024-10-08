// // import 'dart:convert'; // for jsonEncode and jsonDecode
// // import 'package:sqflite/sqflite.dart';
// // import 'package:path/path.dart';
// // import 'dart:developer' as dev;

// // class RecipeDatabaseHelper {
// //   static final RecipeDatabaseHelper _instance =
// //       RecipeDatabaseHelper._internal();
// //   static Database? _database;

// //   factory RecipeDatabaseHelper() {
// //     return _instance;
// //   }

// //   RecipeDatabaseHelper._internal();

// //   Future<Database> get database async {
// //     if (_database != null) return _database!;
// //     _database = await _initDatabase();
// //     return _database!;
// //   }

// //   Future<Database> _initDatabase() async {
// //     String path = join(await getDatabasesPath(), 'Recipes.db');
// //     return openDatabase(
// //       path,
// //       onCreate: (db, version) {
// //         return db.execute(
// //             'CREATE TABLE favourite_recipes (id TEXT PRIMARY KEY, name TEXT, imageUrl TEXT, description TEXT, ingredients TEXT, directions TEXT, duration TEXT, difficulty TEXT, servings INTEGER, calories INTEGER, carbs TEXT, protein TEXT, fat TEXT)');
// //       },
// //       version: 1,
// //     );
// //   }

// //   Future<void> deleteAllRecipes() async {
// //     final db = await database;
// //     await db.delete('favourite_recipes');
// //   }

// //   Future<void> deleteFavRecipeTable() async {
// //     final db = await database;
// //     await db.execute('DROP TABLE favourite_recipes;');
// //   }

// //   Future<void> insertRecipe(Map<String, dynamic> recipe) async {
// //     final db = await database;
// //     await db.insert(
// //       'favourite_recipes',
// //       recipe,
// //       conflictAlgorithm: ConflictAlgorithm.replace,
// //     );
// //   }

// //   // Future<void> insertRecipe({
// //   //   required String id,
// //   //   required String name,
// //   //   required String imageUrl,
// //   //   required String description,
// //   //   required List<String> ingredients,
// //   //   required List<String> directions,
// //   //   required String duration,
// //   //   required String difficulty,
// //   //   required int servings,
// //   //   required int calories,
// //   //   required Map<String, String> nutri_info,
// //   // }) async {
// //   //   final db = await database;

// //   //   // Convert List<String> to strings by joining with a delimiter
// //   //   String ingredientsString = ingredients.join(', '); // Join with a comma
// //   //   String directionsString = directions.join('; '); // Join with a semicolon
// //   //   String nutriInfoJson =
// //   //       jsonEncode(nutri_info); // Keep nutrition info as JSON

// //   //   await db.insert(
// //   //     'favourite_recipes',
// //   //     {
// //   //       'id': id,
// //   //       'name': name,
// //   //       'imageUrl': imageUrl,
// //   //       'description': description,
// //   //       'ingredients': ingredientsString, // Store as string
// //   //       'directions': directionsString, // Store as string
// //   //       'duration': duration,
// //   //       'difficulty': difficulty,
// //   //       'servings': servings,
// //   //       'calories': calories,
// //   //       'nutri_info': nutriInfoJson,
// //   //     },
// //   //     conflictAlgorithm: ConflictAlgorithm.replace,
// //   //   );
// //   // }

// //   Future<List<Map<String, dynamic>>> getRecipes() async {
// //     final db = await database;
// //     try {
// //       final db_fav_recipe = await db.query('favourite_recipes');
// //       dev.log(db_fav_recipe.toString()); // Log retrieved recipes
// //       return db_fav_recipe;
// //     } catch (e) {
// //       dev.log('Error retrieving recipes: $e'); // Log error if any
// //       return []; // Return an empty list on error
// //     }
// //   }

// //   Future<void> removeRecipe(String id) async {
// //     final db = await database;
// //     await db.delete('favourite_recipes', where: 'id = ?', whereArgs: [id]);
// //   }

// //   // Function to convert JSON string back to list or map when retrieving data
// //   List<String> decodeList(String jsonString) {
// //     return List<String>.from(jsonDecode(jsonString));
// //   }

// //   Map<String, String> decodeMap(String jsonString) {
// //     return Map<String, String>.from(jsonDecode(jsonString));
// //   }
// // }

// import 'dart:convert'; // for jsonEncode and jsonDecode
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'dart:developer' as dev;

// class RecipeDatabaseHelper {
//   static final RecipeDatabaseHelper _instance =
//       RecipeDatabaseHelper._internal();
//   static Database? _database;
//   int? _loggedInUserId; // To store the current logged-in user ID

//   factory RecipeDatabaseHelper() {
//     return _instance;
//   }

//   RecipeDatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'Recipes.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         db.execute('''
//           CREATE TABLE users (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             username TEXT UNIQUE,
//             password TEXT
//           )''');
//         return db.execute('''
//           CREATE TABLE favourite_recipes (
//             id TEXT PRIMARY KEY,
//             name TEXT,
//             imageUrl TEXT,
//             description TEXT,
//             ingredients TEXT,
//             directions TEXT,
//             duration TEXT,
//             difficulty TEXT,
//             servings INTEGER,
//             calories INTEGER,
//             carbs TEXT,
//             protein TEXT,
//             fat TEXT,
//             user_id INTEGER, 
//             FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
//           )''');
//       },
//     );
//   }

//   // User Management Methods
//   Future<void> registerUser(String username, String password) async {
//     final db = await database;
//     await db.insert(
//       'users',
//       {'username': username, 'password': password},
//       conflictAlgorithm: ConflictAlgorithm.ignore,
//     );
//   }

//   Future<bool> loginUser(String username, String password) async {
//     final db = await database;
//     final List<Map<String, dynamic>> users = await db.query(
//       'users',
//       where: 'username = ? AND password = ?',
//       whereArgs: [username, password],
//     );
//     if (users.isNotEmpty) {
//       _loggedInUserId = users.first['id']; // Store logged-in user's ID
//       return true;
//     } else {
//       return false;
//     }
//   }

//   // Recipe Management Methods
//   Future<void> insertRecipe(Map<String, dynamic> recipe) async {
//     final db = await database;
//     if (_loggedInUserId == null) {
//       throw Exception("No user is logged in.");
//     }

//     recipe['user_id'] =
//         _loggedInUserId; // Associate recipe with the logged-in user
//     await db.insert(
//       'favourite_recipes',
//       recipe,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<Map<String, dynamic>>> getRecipes() async {
//     final db = await database;
//     if (_loggedInUserId == null) {
//       throw Exception("No user is logged in.");
//     }

//     // Fetch recipes only for the logged-in user
//     try {
//       final db_fav_recipe = await db.query(
//         'favourite_recipes',
//         where: 'user_id = ?',
//         whereArgs: [_loggedInUserId],
//       );
//       dev.log(db_fav_recipe.toString()); // Log retrieved recipes
//       return db_fav_recipe;
//     } catch (e) {
//       dev.log('Error retrieving recipes: $e'); // Log error if any
//       return []; // Return an empty list on error
//     }
//   }

//   Future<void> removeRecipe(String id) async {
//     final db = await database;
//     if (_loggedInUserId == null) {
//       throw Exception("No user is logged in.");
//     }

//     await db.delete(
//       'favourite_recipes',
//       where: 'id = ? AND user_id = ?',
//       whereArgs: [id, _loggedInUserId],
//     );
//   }

//   Future<void> deleteAllRecipes() async {
//     final db = await database;
//     if (_loggedInUserId == null) {
//       throw Exception("No user is logged in.");
//     }

//     await db.delete(
//       'favourite_recipes',
//       where: 'user_id = ?',
//       whereArgs: [_loggedInUserId],
//     );
//   }

//   Future<void> deleteFavRecipeTable() async {
//     final db = await database;
//     await db.execute('DROP TABLE favourite_recipes;');
//   }
// }



import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as dev;

class RecipeDatabaseHelper {
  static final RecipeDatabaseHelper _instance =
      RecipeDatabaseHelper._internal();
  static Database? _database;
  int? _loggedInUserId; // To store the current logged-in user ID

  factory RecipeDatabaseHelper() {
    return _instance;
  }

  RecipeDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'Recipes.db');
    return openDatabase(
      path,
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
  Future<void> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    recipe['user_id'] = _loggedInUserId; // Associate recipe with the logged-in user
    await db.insert(
      'favourite_recipes',
      recipe,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    if (_loggedInUserId == null) {
      throw Exception("No user is logged in.");
    }

    try {
      final db_fav_recipe = await db.query(
        'favourite_recipes',
        where: 'user_id = ?',
        whereArgs: [_loggedInUserId],
      );
      dev.log(db_fav_recipe.toString()); // Log retrieved recipes
      return db_fav_recipe;
    } catch (e) {
      dev.log('Error retrieving recipes: $e'); // Log error if any
      return []; // Return an empty list on error
    }
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
