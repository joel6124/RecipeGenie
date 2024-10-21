import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:recipe_genie/db_helper.dart';
import 'dart:developer' as dev;

const Color primaryColor = Color(0xFF002330);
const Color secondaryColor = Color.fromARGB(255, 236, 229, 218);
const Color orangeColor = Colors.orange;

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  List<Map<String, dynamic>> recipes = [];
  final RecipeDatabaseHelper _dbHelper = RecipeDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  _loadRecipes() async {
    List<Map<String, dynamic>> savedRecipes =
        await _dbHelper.getUserAddedRecipes();
    setState(() {
      recipes = savedRecipes;
    });
  }

  void _refreshRecipes() async {
    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orange[900],
        ),
        title: Text(
          'Your Recipies',
          style:
              TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: recipes.isEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Text(
                    'No recipes added yet!',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: ClipOval(
                          child: Image.network(
                            recipes[index]['imageUrl'] ??
                                'https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.network(
                                'https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg', // Fallback image if error occurs
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        title: Text(
                          recipes[index]['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          recipes[index]['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // trailing: Icon(Icons.arrow_forward_ios,
                        //     color: Colors.orange[900]),
                        // contentPadding:
                        //     EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        // onTap: () {
                        //   // Action when the tile is tapped
                        // },
                      );
                    },
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddRecipePage(onRecipeAdded: _refreshRecipes),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.orange[900]),
      ),
    );
  }
}

class AddRecipePage extends StatefulWidget {
  final Function onRecipeAdded;

  AddRecipePage({required this.onRecipeAdded});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  String newUserRecipeId = ''; // Initialize it as empty first
  final Map<String, dynamic> _newRecipe = {};

  final RecipeDatabaseHelper _dbHelper = RecipeDatabaseHelper();

  @override
  void initState() {
    super.initState();
    newUserRecipeId = randomAlphaNumeric(10);
    _newRecipe.addAll({
      'id': newUserRecipeId,
      'name': '',
      'imageUrl': '',
      'description': '',
      'ingredients': '',
      'directions': '',
      'duration': '',
      'difficulty': '',
      'servings': 0,
      'calories': 0,
      'carbs': '',
      'protein': '',
      'fat': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.orange[900],
        ),
        title: Text(
          'Add Recipe',
          style:
              TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Recipe Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a recipe name' : null,
                  onSaved: (value) => _newRecipe['name'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Image URL'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an image URL' : null,
                  onSaved: (value) => _newRecipe['imageUrl'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: null,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a description' : null,
                  onSaved: (value) => _newRecipe['description'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ingredients'),
                  maxLines: null,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the ingredients' : null,
                  onSaved: (value) => _newRecipe['ingredients'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Directions'),
                  maxLines: null,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the directions' : null,
                  onSaved: (value) => _newRecipe['directions'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Duration'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the duration' : null,
                  onSaved: (value) => _newRecipe['duration'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Difficulty'),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the difficulty level'
                      : null,
                  onSaved: (value) => _newRecipe['difficulty'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Servings'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the number of servings'
                      : null,
                  onSaved: (value) =>
                      _newRecipe['servings'] = int.tryParse(value!) ?? 0,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the calories' : null,
                  onSaved: (value) =>
                      _newRecipe['calories'] = int.tryParse(value!) ?? 0,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Carbs'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the carbs' : null,
                  onSaved: (value) => _newRecipe['carbs'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Protein'),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the protein content'
                      : null,
                  onSaved: (value) => _newRecipe['protein'] = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Fat'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the fat content' : null,
                  onSaved: (value) => _newRecipe['fat'] = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: _submitForm,
                  child: Text(
                    'Add Recipe',
                    style: TextStyle(
                        color: Colors.orange[900], fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _dbHelper.insertRecipe(_newRecipe);
      widget.onRecipeAdded();
      Navigator.pop(context);
    }
  }
}
