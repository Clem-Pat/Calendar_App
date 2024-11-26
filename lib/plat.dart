class Plat {
  final int? id;
  final String name;
  final String description;
  final String ingredients;
  final String recipe;

  Plat({this.id, required this.name, required this.description, required this.ingredients, required this.recipe});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'recipe': recipe,
    };
  }

  factory Plat.fromMap(Map<String, dynamic> map) {
    return Plat(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ingredients: map['ingredients'],
      recipe: map['recipe'],
    );
  }
}
