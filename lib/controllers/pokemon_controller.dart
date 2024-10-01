import 'package:get/get.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

class PokemonController extends GetxController {
  var pokemonList = <Pokemon>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedType = ''.obs; // Nuevo: para filtrar por tipo
  int offset = 0; // Para paginación
  final int limit = 20;
  final PokemonService _pokemonService = PokemonService(); // Instancia del servicio

  @override
  void onInit() {
    super.onInit();
    fetchPokemon(); // Cargar los primeros Pokémon
  }

  // Método para obtener la lista de Pokémon desde la API usando el servicio
  Future<void> fetchPokemon() async {
    if (isLoading.value) return; // Prevenir múltiples peticiones simultáneas
    isLoading.value = true;

    try {
      final results = await _pokemonService.fetchPokemonList(offset, limit);
      for (var result in results) {
        final pokemon = await _pokemonService.fetchPokemonDetail(result['url']);
        pokemonList.add(pokemon); // Añadir el Pokémon a la lista observable
      }
      offset += limit; // Aumentar el offset para la siguiente paginación
    } finally {
      isLoading.value = false;
    }
  }

  // Método para aplicar el filtro de búsqueda
  List<Pokemon> get filteredPokemonList {
    var filteredList = pokemonList;
    
    // Filtrar por nombre si hay búsqueda
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((pokemon) => pokemon.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList().obs;
    }

    // Filtrar por tipo si hay uno seleccionado
    if (selectedType.isNotEmpty) {
      filteredList = filteredList.where((pokemon) => pokemon.types.contains(selectedType.value)).toList().obs;
    }

    return filteredList;
  }

  // Método para actualizar la búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Método para actualizar el filtro por tipo
  void updateSelectedType(String type) {
    selectedType.value = type;
  }
}