import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/pokemon_model.dart'; // Asegúrate de importar el modelo de Pokémon

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen del Pokémon (más grande)
            Image.network(
              pokemon.imageUrl,
              height: 150, // Ajusta el tamaño a tu preferencia
              width: 150, // Ajusta el tamaño a tu preferencia
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            // Información del Pokémon
            Text(
              pokemon.name.capitalizeFirst!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Altura: ${pokemon.height} m'),
            Text('Peso: ${pokemon.weight} kg'),
            Text('Habilidad: ${pokemon.ability.capitalizeFirst!}'),
            SizedBox(height: 10),
            Wrap(
              children: pokemon.types
                  .map((type) => Container(
                        margin: EdgeInsets.only(right: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(type),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type.capitalizeFirst!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener el color de fondo según el tipo de Pokémon
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return Colors.green;
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow;
      case 'poison':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}