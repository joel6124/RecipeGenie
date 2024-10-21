import 'package:flutter/material.dart';
import 'package:recipe_genie/db_helper.dart';

class RecipiesDetailScreen extends StatefulWidget {
  bool isLiked;
  final String id;
  final String name;
  String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> directions;
  final String duration;
  final String difficulty;
  final int servings;
  final int calories;
  final String carbs;
  final String protein;
  final String fat;

  RecipiesDetailScreen({
    super.key,
    required this.isLiked,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.directions,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  State<RecipiesDetailScreen> createState() => _RecipiesDetailScreenState();
}

class _RecipiesDetailScreenState extends State<RecipiesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          widget.name,
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
        actions: [
          IconButton(
            icon: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked
                  ? const Color.fromARGB(255, 193, 35, 24)
                  : Colors.grey,
            ),
            onPressed: () async {
              setState(() {
                widget.isLiked = !widget.isLiked;
              });
              if (widget.isLiked) {
                await RecipeDatabaseHelper().insertFavouriteRecipe({
                  'id': widget.id,
                  'name': widget.name,
                  'imageUrl': widget.imageUrl,
                  'description': widget.description,
                  'ingredients': (widget.ingredients).join('; '),
                  'directions': (widget.directions).join('; '),
                  'duration': widget.duration,
                  'difficulty': widget.difficulty,
                  'servings': widget.servings,
                  'calories': widget.calories,
                  'carbs': widget.carbs,
                  'protein': widget.protein,
                  'fat': widget.fat
                });

                _showSnackBar('Recipe added to favorites!');
              } else {
                await RecipeDatabaseHelper().removeRecipe(widget.id);

                _showSnackBar('Recipe removed from favorites!');
              }
            },
            iconSize: 28.0,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    widget.imageUrl =
                        "https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg";
                    return Image.network(
                      "https://www.foodlocale.in/wp-content/uploads/2022/11/food.jpg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                          Icons.timelapse, widget.duration, Colors.grey),
                      _buildInfoCard(
                          Icons.star, widget.difficulty, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 218, 234, 236),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildInfoCard(
                              Icons.restaurant,
                              '${widget.servings} servings',
                              const Color.fromARGB(255, 0, 35, 48)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(255, 218, 234, 236),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildInfoCard(Icons.local_fire_department,
                              '${widget.calories} cal', Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Ingredients'),
                  const SizedBox(height: 8),
                  ...widget.ingredients
                      .map((ingredient) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.local_dining,
                                    size: 20,
                                    color:
                                        const Color.fromARGB(255, 0, 105, 5)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Directions'),
                  const SizedBox(height: 8),
                  ...widget.directions
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '${entry.key + 1}. ${entry.value}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Nutritional Information'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Carbohydrates',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.carbs,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Proteins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.protein,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.fat,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Text(message),
          Icon(
            Icons.favorite,
            color: const Color.fromARGB(255, 206, 43, 31),
          )
        ],
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color.fromARGB(255, 0, 35, 48),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildInfoCard(IconData icon, String text, Color my_color) {
    return Row(
      children: [
        Icon(icon, color: my_color),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
