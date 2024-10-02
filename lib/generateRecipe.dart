// import 'package:flutter/material.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
// import 'dart:convert';

// class GeneraterecipeScreen extends StatefulWidget {
//   const GeneraterecipeScreen({Key? key}) : super(key: key);

//   @override
//   _GeneraterecipeScreenState createState() =>
//       _GeneraterecipeScreenState();
// }

// class _GeneraterecipeScreenState extends State<GeneraterecipeScreen> {
//   String? _selectedGoal;
//   String? _selectedExperience;
//   bool _isLoading = false;
//   String? _rawResponse;
//   Map<String, dynamic>? _workoutPlan;

//   final List<String> _fitnessGoals = [
//     'Lose weight',
//     'Build muscle',
//     'Improve cardiovascular health',
//     'Increase flexibility',
//     'Enhance overall fitness'
//   ];

//   final List<String> _experienceLevels = [
//     'Beginner',
//     'Intermediate',
//     'Advanced'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Generate Workout Plan'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Select your fitness goal:',
//                 style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _fitnessGoals
//                   .map((goal) => ChoiceChip(
//                         label: Text(goal),
//                         selected: _selectedGoal == goal,
//                         onSelected: (selected) {
//                           setState(() {
//                             _selectedGoal = selected ? goal : null;
//                           });
//                         },
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 16),
//             Text('Select your experience level:',
//                 style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _experienceLevels
//                   .map((level) => ChoiceChip(
//                         label: Text(level),
//                         selected: _selectedExperience == level,
//                         onSelected: (selected) {
//                           setState(() {
//                             _selectedExperience = selected ? level : null;
//                           });
//                         },
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: (_selectedGoal != null &&
//                       _selectedExperience != null &&
//                       !_isLoading)
//                   ? _generateWorkoutPlan
//                   : null,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Generate Workout Plan'),
//             ),
//             const SizedBox(height: 24),
//             if (_workoutPlan != null || _rawResponse != null)
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: _buildWorkoutPlanDisplay(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWorkoutPlanDisplay() {
//     if (_workoutPlan != null) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Your Personalized Workout Plan',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).primaryColor,
//                 ),
//           ),
//           const SizedBox(height: 16),
//           ..._workoutPlan!.entries
//               .map((entry) => _buildSection(entry.key, entry.value)),
//         ],
//       );
//     } else if (_rawResponse != null) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Raw Response (Debug Info):',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//           ),
//           const SizedBox(height: 8),
//           Text(_rawResponse!),
//         ],
//       );
//     } else {
//       return const Text('No workout plan generated yet.');
//     }
//   }

//   Widget _buildSection(String title, dynamic content) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 8),
//             if (content is List)
//               ...content.map((item) => Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Text(item.toString()),
//                   ))
//             else
//               Text(content.toString()),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _generateWorkoutPlan() async {
//     setState(() {
//       _isLoading = true;
//       _workoutPlan = null;
//       _rawResponse = null;
//     });

//     final gemini = Gemini.instance;
//     try {
//       final response = await gemini.text(
//           "Generate a structured workout plan for someone with the goal of $_selectedGoal and experience level: $_selectedExperience. "
//           "The plan should include: 1. Warm-up exercises 2. Main workout routine 3. Cool-down exercises 4. Nutrition tips. "
//           "Format the response as a JSON object with these keys: warmUp, mainWorkout, coolDown, nutritionTips. "
//           "For exercises and tips, use an array of strings. "
//           "Example format: "
//           "{"
//           "  \"warmUp\": [\"Exercise 1\", \"Exercise 2\"],"
//           "  \"mainWorkout\": [\"Exercise 1\", \"Exercise 2\"],"
//           "  \"coolDown\": [\"Exercise 1\", \"Exercise 2\"],"
//           "  \"nutritionTips\": [\"Tip 1\", \"Tip 2\"]"
//           "}");

//       if (response?.output != null) {
//         print("Raw Gemini response:");
//         print(response!.output);
//         setState(() {
//           _rawResponse = response.output;
//           _workoutPlan = _parseWorkoutPlan(response.output!);
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('No output from Gemini');
//       }
//     } catch (e) {
//       print('Error generating workout plan: $e');
//       setState(() {
//         _isLoading = false;
//         _workoutPlan = null;
//         _rawResponse = 'Error: $e';
//       });
//     }
//   }

//   Map<String, dynamic> _parseWorkoutPlan(String text) {
//     // Remove any markdown formatting
//     text = text.replaceAll('```json', '').replaceAll('```', '').trim();

//     try {
//       // Replace problematic number ranges with strings
//       text = text.replaceAllMapped(
//           RegExp(r':\s*(\d+)-(\d+)([^\d]|$)'),
//           (match) =>
//               ': "${match.group(1)}-${match.group(2)}"${match.group(3)}');

//       // Parse the JSON
//       Map<String, dynamic> jsonResponse = jsonDecode(text);
//       return _processJsonResponse(jsonResponse);
//     } catch (e) {
//       print('Error parsing JSON: $e');
//       // If JSON parsing fails, fall back to text parsing
//       return _parseWorkoutPlanText(text);
//     }
//   }

//   Map<String, dynamic> _processJsonResponse(Map<String, dynamic> jsonResponse) {
//     // Process each section of the workout plan
//     ['warmUp', 'mainWorkout', 'coolDown', 'nutritionTips'].forEach((key) {
//       if (jsonResponse[key] is List) {
//         jsonResponse[key] = jsonResponse[key].map((item) {
//           if (item is Map) {
//             return item.entries.map((e) => "${e.key}: ${e.value}").join(', ');
//           }
//           return item.toString();
//         }).toList();
//       }
//     });
//     return jsonResponse;
//   }

//   Map<String, dynamic> _parseWorkoutPlanText(String text) {
//     final Map<String, dynamic> plan = {};
//     String currentSection = '';
//     List<String> currentList = [];

//     for (var line in text.split('\n')) {
//       line = line.trim();
//       if (line.isEmpty) continue;

//       if (line.endsWith(':')) {
//         if (currentSection.isNotEmpty) {
//           plan[currentSection] =
//               currentList.isNotEmpty ? currentList : 'No details provided';
//           currentList = [];
//         }
//         currentSection = line.substring(0, line.length - 1);
//       } else {
//         if (line.startsWith('•') || line.startsWith('-')) {
//           currentList.add(line.substring(1).trim());
//         } else {
//           currentList.add(line);
//         }
//       }
//     }

//     if (currentSection.isNotEmpty) {
//       plan[currentSection] =
//           currentList.isNotEmpty ? currentList : 'No details provided';
//     }

//     return plan;
//   }
// }

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
        iconTheme: const IconThemeData(color: Colors.white),
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
                      _isLoading // Check if loading is true
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors
                                  .white), // Set the color of the loading indicator
                            )
                          : const Text(
                              'Generate Your Personalized Recipe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (!_isLoading) // Only show the icon when not loading
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

  // Widget _buildrecipeDisplay() {
  //   if (recipe != null) {
  //     return Expanded(
  //       child: SingleChildScrollView(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               recipe!['name'] ?? 'recipe',
  //               style: Theme.of(context)
  //                   .textTheme
  //                   .headlineSmall
  //                   ?.copyWith(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             if (recipe!.containsKey('imageUrl'))
  //               Image.network(
  //                 recipe!['imageUrl'] ??
  //                     'https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg',
  //                 errorBuilder: (BuildContext context, Object exception,
  //                     StackTrace? stackTrace) {
  //                   return Image.network(
  //                     'https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg', // Fallback image if error occurs
  //                     fit: BoxFit.cover,
  //                   );
  //                 },
  //                 fit: BoxFit.cover, // Optional: Use to fit image properly
  //               ),
  //             const SizedBox(height: 16),
  //             _buildSection('Description', recipe!['description']),
  //             _buildSection('Ingredients', recipe!['ingredients']),
  //             _buildSection('Directions', recipe!['directions']),
  //             _buildSection('Nutritional Info', recipe!['nutri_info']),
  //           ],
  //         ),
  //       ),
  //     );
  //   } else if (_rawResponse != null) {
  //     return Expanded(
  //       child: SingleChildScrollView(
  //         child: Text(
  //           'Raw Response (Debug Info):\n$_rawResponse',
  //           style: const TextStyle(color: Colors.red),
  //         ),
  //       ),
  //     );
  //   } else {
  //     return const Text('No recipe generated yet :(');
  //   }
  // }

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
