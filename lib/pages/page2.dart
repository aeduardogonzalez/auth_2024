import 'package:auth_2024/pages/widget_pokemon_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pokemon_controller.dart';
import '../models/pokemon_model.dart';

class Page2 extends StatelessWidget {
  final PokemonController _pokemonController = Get.put(PokemonController());
  final List<String> pokemonTypes = [
    'todos',
    'grass',
    'fire',
    'water',
    'electric',
    'poison',
    'rock',
    'ground',
    'psychic',
    'flying'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon'),
      ),
      body: Column(
        children: [
          // Filtros por tipo
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pokemonTypes.length,
              itemBuilder: (context, index) {
                final type = pokemonTypes[index];
                return Obx(() {
                  return GestureDetector(
                    onTap: () {
                      if (type == 'todos') {
                        _pokemonController.updateSelectedType(
                            ''); // Mostrar todos los Pokémon
                      } else {
                        _pokemonController.updateSelectedType(type);
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _pokemonController.selectedType.value == type
                              ? Color.fromARGB(255, 131, 6, 62)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                        child: Center(
                        child: Text(
                          type.capitalizeFirst!,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          SizedBox(height: 10),

          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _pokemonController.updateSearchQuery(value);
              },
            ),
          ),

          // Lista de Pokémon
          Expanded(
            child: Obx(() {
              if (_pokemonController.isLoading.value &&
                  _pokemonController.pokemonList.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !_pokemonController.isLoading.value) {
                    _pokemonController.fetchPokemon();
                    return true;
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: _pokemonController.filteredPokemonList.length,
                  itemBuilder: (context, index) {
                    final pokemon =
                        _pokemonController.filteredPokemonList[index];
                    return GestureDetector(
                      onTap: () => _showPokemonDetail(context,
                          pokemon), // Al tocar el Pokémon, abrir el modal
                      child: PokemonCard(pokemon: pokemon),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Método para mostrar un modal con animación y detalles del Pokémon
  void _showPokemonDetail(BuildContext context, Pokemon pokemon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 1.0,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Imagen del Pokémon más grande
                      Hero(
                        tag: pokemon.name,
                        child: Image.network(
                          pokemon.imageUrl,
                          height: 200,
                          width: 200,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        pokemon.name.capitalizeFirst!,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
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
              ),
            );
          },
        );
      },
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
      case 'todos':
        return Colors.grey; // Color para el filtro "Todos"
      default:
        return Colors.grey;
    }
  }
}