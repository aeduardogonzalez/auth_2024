import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pokemon_model.dart';

class PokemonService {
  final String baseUrl = 'https://pokeapi.co/api/v2/pokemon';

  // Obtener la lista de Pokémon básica
  Future<List<Map<String, dynamic>>> fetchPokemonList(int offset, int limit) async {
    final response = await http.get(
      Uri.parse('$baseUrl?offset=$offset&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Error al obtener la lista de Pokémon');
    }
  }

  // Obtener los detalles de un Pokémon específico
  Future<Pokemon> fetchPokemonDetail(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final pokemonDetail = json.decode(response.body);
      return Pokemon.fromJson(pokemonDetail);
    } else {
      throw Exception('Error al obtener detalles del Pokémon');
    }
  }
}