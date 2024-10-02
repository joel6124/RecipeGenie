import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as dev;

class RecipeDatabaseHelper {
  static final RecipeDatabaseHelper _instance =
      RecipeDatabaseHelper._internal();
  static Database? _database;

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
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE favourite_recipes (id TEXT PRIMARY KEY, name TEXT, imageUrl TEXT, description TEXT, ingredients TEXT, directions TEXT, duration TEXT, difficulty TEXT, servings INTEGER, calories INTEGER, carbs TEXT, protein TEXT, fat TEXT)');
      },
      version: 1,
    );
  }

  Future<void> deleteAllRecipes() async {
    final db = await database;
    await db.delete('favourite_recipes');
  }

  Future<void> deleteFavRecipeTable() async {
    final db = await database;
    await db.execute('DROP TABLE favourite_recipes;');
  }

  Future<void> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await database;
    await db.insert(
      'favourite_recipes',
      recipe,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<void> insertRecipe({
  //   required String id,
  //   required String name,
  //   required String imageUrl,
  //   required String description,
  //   required List<String> ingredients,
  //   required List<String> directions,
  //   required String duration,
  //   required String difficulty,
  //   required int servings,
  //   required int calories,
  //   required Map<String, String> nutri_info,
  // }) async {
  //   final db = await database;

  //   // Convert List<String> to strings by joining with a delimiter
  //   String ingredientsString = ingredients.join(', '); // Join with a comma
  //   String directionsString = directions.join('; '); // Join with a semicolon
  //   String nutriInfoJson =
  //       jsonEncode(nutri_info); // Keep nutrition info as JSON

  //   await db.insert(
  //     'favourite_recipes',
  //     {
  //       'id': id,
  //       'name': name,
  //       'imageUrl': imageUrl,
  //       'description': description,
  //       'ingredients': ingredientsString, // Store as string
  //       'directions': directionsString, // Store as string
  //       'duration': duration,
  //       'difficulty': difficulty,
  //       'servings': servings,
  //       'calories': calories,
  //       'nutri_info': nutriInfoJson,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    final db = await database;
    try {
      final db_fav_recipe = await db.query('favourite_recipes');
      dev.log(db_fav_recipe.toString()); // Log retrieved recipes
      return db_fav_recipe;
    } catch (e) {
      dev.log('Error retrieving recipes: $e'); // Log error if any
      return []; // Return an empty list on error
    }
  }

  Future<void> removeRecipe(String id) async {
    final db = await database;
    await db.delete('favourite_recipes', where: 'id = ?', whereArgs: [id]);
  }

  // Function to convert JSON string back to list or map when retrieving data
  List<String> decodeList(String jsonString) {
    return List<String>.from(jsonDecode(jsonString));
  }

  Map<String, String> decodeMap(String jsonString) {
    return Map<String, String>.from(jsonDecode(jsonString));
  }
}
