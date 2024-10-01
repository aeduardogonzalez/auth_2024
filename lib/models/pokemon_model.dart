class Pokemon {
  final String name;
  final String imageUrl;
  final double height;
  final double weight;
  final List<String> types;
  final String category;
  final String ability;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
    required this.category,
    required this.ability,
  });

  // Método para crear una instancia de Pokemon desde un JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List<dynamic>)
        .map((typeInfo) => typeInfo['type']['name'] as String)
        .toList();

    return Pokemon(
      name: json['name'] ,
      imageUrl: json['sprites']['front_default'],
      height: json['height'] / 10, // Convertir de decímetros a metros
      weight: json['weight'] / 10, // Convertir de hectogramos a kilogramos
      types: types,
      category: 'Semilla', // Puedes obtener la categoría de otro endpoint si es necesario
      ability: json['abilities'][0]['ability']['name'],
    );
  }
}