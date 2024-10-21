import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';
import 'package:recipe_genie/db_helper.dart';
import 'package:recipe_genie/menu.dart';
import 'package:recipe_genie/predeifined_recipies.dart';
import 'package:recipe_genie/recipiesDetailScreen.dart';
import 'generateRecipe.dart';
import 'dart:developer' as dev;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Map<String, dynamic>>>? _favouriteRecipesFuture;
  Future<List<Map<String, dynamic>>>? _usersRecipesFuture;
  String? _username;

  @override
  void initState() {
    super.initState();
    _favouriteRecipesFuture = getRecipeFromDb();
    _usersRecipesFuture = getUsersRecipesFuture();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    String? username = await RecipeDatabaseHelper().getLoggedInUsername();
    setState(() {
      _username = username;
    });
  }

  Future<void> refreshRecipes() async {
    setState(() {
      _favouriteRecipesFuture = getRecipeFromDb();
      _usersRecipesFuture = getUsersRecipesFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshRecipes,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.orange[900], size: 30),
          toolbarHeight: 60,
          title: Row(
            children: [
              Icon(
                Icons.local_dining,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 15),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Recipe',
                      style: GoogleFonts.merienda(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'Genie',
                      style: GoogleFonts.merienda(
                        fontSize: 24,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 0, 35, 48),
        ),
        drawer: UserMenu(username: _username ?? 'Guest'),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomTitle(context, 'Unlock Your Flavor Palette',
                      'Chef’s Picks Just for You!'),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    context,
                    'Generate Your Recipe',
                    'Create a personalized recipe plan tailored to your available ingredients and taste preferences.',
                    Icons.restaurant,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GenerateRecipeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildCustomTitle(context, 'Top Picks for You',
                      'Curated Recipe Suggestions'),
                  const SizedBox(height: 10),
                  _buildDefaultRecipies(context),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCustomTitle(context, 'Your Recipe Collection',
                          'Favorites for Future Feasts'),
                      Icon(
                        Icons.favorite,
                        color: const Color.fromARGB(255, 179, 27, 16),
                        size: 30,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildFavouriteRecipies(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTitle(
      BuildContext context, String mainTitle, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange[900],
          ),
        ),
        Text(
          subTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 35, 48),
          ),
        )
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title,
      String description, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      color: const Color.fromARGB(255, 218, 234, 236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  icon,
                  size: 70,
                  color: const Color.fromARGB(255, 0, 35, 48),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteRecipies(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _favouriteRecipesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Looks like you haven\'t saved any recipes yet...\n    Start exploring and add your favorites!',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
            ),
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: snapshot.data!
                  .map((recipe) => Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildRecipeTile(context, recipe, true),
                      ))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildDefaultRecipies(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _usersRecipesFuture ?? Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildPredefinedRecipeTiles(context);
        } else {
          List<Map<String, dynamic>> allRecipes = [
            ...quickRecipes,
            ...snapshot.data!,
          ];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: allRecipes
                  .map((recipe) => Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildRecipeTile(context, recipe, false),
                      ))
                  .toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildPredefinedRecipeTiles(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: quickRecipes
            .map((recipe) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildRecipeTile(context, recipe, false),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRecipeTile(
      BuildContext context, Map<String, dynamic> recipe, bool isLiked) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 4,
          color: const Color.fromARGB(255, 0, 35, 48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
            child: Container(
              height: 200,
              width: 300,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 120,
                        ),
                        child: Text(
                          recipe['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${recipe['duration']} • ${recipe['difficulty']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 218, 234, 236),
                            ),
                            child: const Text('Get Recipe',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 35, 48),
                                    fontWeight: FontWeight.bold)),
                          ),
                          onTap: () {
                            dev.log(recipe.toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipiesDetailScreen(
                                  isLiked: isLiked,
                                  name: recipe['name'],
                                  imageUrl: recipe['imageUrl'],
                                  description: recipe['description'],
                                  duration: recipe['duration'],
                                  difficulty: recipe['difficulty'],
                                  servings: recipe['servings'],
                                  calories: recipe['calories'],
                                  ingredients:
                                      recipe['ingredients'].split('; '),
                                  directions: recipe['directions'].split('; '),
                                  carbs: recipe['carbs'],
                                  protein: recipe['protein'],
                                  fat: recipe['fat'],
                                  id: recipe['id'],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -14,
          top: 0,
          child: CircleAvatar(
            radius: 85,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
              recipe['imageUrl'],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> getRecipeFromDb() async {
    var recipeDb = await RecipeDatabaseHelper().getFavouriteRecipes();
    return recipeDb;
  }

  Future<List<Map<String, dynamic>>> getUsersRecipesFuture() async {
    var recipeDb = await RecipeDatabaseHelper().getPublicsRecipes();
    return recipeDb;
  }
}
