import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:random_string/random_string.dart';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:recipe_genie/recipiesDetailScreen.dart';

class GenerateRecipeScreen extends StatefulWidget {
  const GenerateRecipeScreen({Key? key}) : super(key: key);

  @override
  _GenerateRecipeScreenState createState() => _GenerateRecipeScreenState();
}

class _GenerateRecipeScreenState extends State<GenerateRecipeScreen> {
  List<String> _ingredients = [];
  String? _selectedDiet;
  String? _selectedCuisine;
  bool _isLoading = false;
  String? _rawResponse;
  Map<String, dynamic>? recipe;
  TextEditingController _ingriController = TextEditingController();

  final List<String> _dietaryPreferences = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Keto',
    'Paleo'
  ];

  final List<String> _cuisineTypes = [
    'Italian',
    'Mexican',
    'Indian',
    'Chinese',
    'Mediterranean'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          'Generate recipe',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 35, 48),
        iconTheme: IconThemeData(
          color: Colors.orange[900],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvailableIngredientsList(),
              const SizedBox(height: 16),
              _buildDietaryPreferencesChips(),
              const SizedBox(height: 16),
              _buildCuisineTypeChips(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (_selectedDiet != null &&
                      _selectedCuisine != null &&
                      !_isLoading) {
                    setState(() {
                      _isLoading =
                          true; // Set loading to true when button is clicked
                    });
                    _generaterecipe(); // Call your recipe generation method
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromARGB(255, 0, 35, 48),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : Text(
                              'Generate Your Personalized Recipe',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (!_isLoading)
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 30,
                        )
                    ],
                  ),
                ),
              ),

              // ElevatedButton(
              //   onPressed:
              //   child: _isLoading
              //       ? const CircularProgressIndicator()
              //       : const Text('Generate Recipe'),
              // ),
              const SizedBox(height: 24),
              // _buildrecipeDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableIngredientsList() {
    return Column(
      children: [
        TextField(
          controller: _ingriController,
          decoration: InputDecoration(
            hintText: 'Ingredients you have?',
            suffixIcon: Icon(Icons.food_bank),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                _ingredients.add(value.trim());
                _ingriController.clear();
              });
            }
          },
        ),
        SizedBox(height: 10),
        if (_ingredients.isNotEmpty)
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _ingredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                deleteIcon: Icon(Icons.cancel),
                onDeleted: () {
                  setState(() {
                    _ingredients.remove(ingredient);
                  });
                },
              );
            }).toList(),
          )
      ],
    );
  }

  Widget _buildDietaryPreferencesChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your dietary preference:',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dietaryPreferences
              .map((diet) => ChoiceChip(
                    label: Text(diet),
                    selected: _selectedDiet == diet,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDiet = selected ? diet : null;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCuisineTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your cuisine type:',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _cuisineTypes
              .map((cuisine) => ChoiceChip(
                    label: Text(cuisine),
                    selected: _selectedCuisine == cuisine,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCuisine = selected ? cuisine : null;
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSection(String title, dynamic content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (content is List)
              ...content.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(item.toString()),
                  ))
            else
              Text(content.toString()),
          ],
        ),
      ),
    );
  }

  Future<void> _generaterecipe() async {
    setState(() {
      _isLoading = true;
      recipe = null;
      _rawResponse = null;
    });
    String availableIngredients = _ingredients.join(", ");

    final gemini = Gemini.instance;
    try {
      final response = await gemini.text(
          "Generate a detailed recipe with a name for a dish with the following criteria: diet type: $_selectedDiet, cuisine: $_selectedCuisine, available ingredients at hand currently to make the dish:  $availableIngredients"
          "The dish must have these ingredients: $availableIngredients"
          "Note, if the avaliable ingredients have only Veg items and the diet type selected is either Gluten-Free, Keto or Paleo then send a response as a String - \"Invalid Combination\" otherwise"
          "The recipe should include: name, duration, difficulty, imageUrl, description, servings, calories, ingredients, directions, carbs ,protein and fat."
          "Format the response as a JSON object with these keys: name, duration, difficulty, imageUrl, description, servings, calories, ingredients, directions, carbs ,protein and fat."
          "For servings and calories, use an integer. "
          "For name, duration, difficulty, imageUrl, description, ingredients, directions, carbs ,protein and fat, use String. "
          "ingredients and  directions must be of type String - Example: \"ingredient1; ingredient2;... \""
          "Every ingredient and direction must be separated by a ; and combined into a single String"
          "Example format: "
          "{"
          "  \"name\": \"Spaghetti Carbonara\","
          "  \"duration\": \"20 min\","
          "  \"difficulty\": \"Intermediate\","
          "  \"imageUrl\": \"https://www.allrecipes.com/thmb/Vg2cRidr2zcYhWGvPD8M18xM_WY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/11973-spaghetti-carbonara-ii-DDMFS-4x3-6edea51e421e4457ac0c3269f3be5157.jpg\","
          "  \"description\": \"A classic Italian dish with eggs, cheese, pancetta, and pepper.\","
          "  \"servings\": 2,"
          "  \"calories\": 400,"
          "  \"ingredients\": \"200g spaghetti; 100g pancetta; 2 large eggs; 50g Pecorino cheese; Freshly ground black pepper\","
          "  \"directions\": \"Cook the spaghetti according to package instructions.; In a bowl, whisk the eggs and cheese together.; In a pan, cook the pancetta until crispy.; Add the cooked spaghetti to the pancetta, then remove from heat.; Quickly mix in the egg and cheese mixture, stirring continuously.; Season with black pepper and serve immediately.\","
          "  \"carbs\": \"45g\","
          "  \"protein\": \"20g\","
          "  \"fat\": \"15g\""
          "}");

      if (response?.output != null) {
        dev.log("Raw Gemini response:");
        print(response!.output);
        if (response.output == "Invalid Combination") {
          setState(() {
            _isLoading = false;
          });
          final snackBar = SnackBar(
            content: Row(
              children: [
                Text("Try a different Combination!"),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color.fromARGB(255, 0, 35, 48),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          setState(() {
            _rawResponse = response.output;
            recipe = _parserecipe(response.output!);
            dev.log(recipe.toString());
            _isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipiesDetailScreen(
                isLiked: false,
                id: randomAlphaNumeric(10),
                name: recipe!['name'] ?? 'Special Dish',
                imageUrl: recipe!['imageUrl'],
                description: recipe!['description'],
                duration: recipe!['duration'],
                difficulty: recipe!['difficulty'],
                servings: recipe!['servings'],
                calories: recipe!['calories'],
                ingredients: recipe!['ingredients'].split('; '),
                directions: recipe!['directions'].split('; '),
                carbs: recipe!['carbs'],
                protein: recipe!['protein'],
                fat: recipe!['fat'],
              ),
            ),
          );
        }
      } else {
        throw Exception('No output from Gemini');
      }
    } catch (e) {
      print('Error generating recipe: $e');
      setState(() {
        _isLoading = false;
        recipe = null;
        _rawResponse = 'Error: $e';
      });
    }
  }

  Map<String, dynamic> _parserecipe(String text) {
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      return jsonDecode(text);
    } catch (e) {
      print('Error parsing JSON: $e');
      return {};
    }
  }
}
