import 'dart:io';
import 'package:auth_2024/models/item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../services/item_service.dart';

class ItemController extends GetxController {
  final ItemService _itemService = ItemService();
  
  var isLoading = false.obs; // Definir isLoading como observable
  var imageFile = Rxn<File>(); // Variable para almacenar la imagen seleccionada en móvil
  var imageWebFile = Rxn<Uint8List>(); // Variable para almacenar la imagen seleccionada en web
  RxList<Item> items = <Item>[].obs; // Lista observable de ítems para actualizar la UI automáticamente
  var filteredItems = <Item>[].obs; // Lista observable de ítems filtrados
  var searchQuery = ''.obs; // Variable observable para el texto de búsqueda

  // Método para seleccionar una imagen (móvil o web)
  Future<void> pickImage(bool fromCamera) async {
    if (kIsWeb) {
      // Seleccionar imagen en Flutter Web usando FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.first.bytes != null) {
        imageWebFile.value = result.files.first.bytes; // Guardar imagen para la web
      } else {
        Get.snackbar("Error", "No se seleccionó ninguna imagen");
      }
    } else {
      // Seleccionar imagen en dispositivos móviles usando ImagePicker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        imageFile.value = File(pickedFile.path); // Guardar la imagen en móviles
      } else {
        Get.snackbar("Error", "No se seleccionó ninguna imagen");
      }
    }
  }

  // Método para guardar un nuevo ítem
  Future<void> saveNewItem(String detail, int quantity, double price, bool isActive, DateTime purchaseDate, String category) async {
    try {
      isLoading.value = true;
      String itemId = Uuid().v4(); // Generar un ID único para el ítem

      if (imageFile.value != null || imageWebFile.value != null) {
        String? imageUrl = await _itemService.uploadImageForPlatform(
          kIsWeb ? imageWebFile.value! : imageFile.value!, itemId,
        );

        if (imageUrl != null) {
          // Crear una instancia de Item con todos los datos
          Item item = Item(
            id: itemId,
            imageUrl: imageUrl,
            detail: detail,
            quantity: quantity,
            price: price,
            isActive: isActive,
            purchaseDate: purchaseDate,
            category: category,
          );

          // Guardar el ítem usando el servicio
          await _itemService.saveItem(item);
          Get.snackbar('Éxito', 'Ítem guardado correctamente');
          fetchItems(); // Volver a cargar los ítems después de guardar
        } else {
          Get.snackbar('Error', 'No se pudo subir la imagen');
        }
      } else {
        Get.snackbar('Error', 'Debe seleccionar una imagen');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al guardar el ítem');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para actualizar un ítem existente
  Future<void> updateItem(Item item) async {
    try {
      isLoading.value = true;

      // Si hay una nueva imagen seleccionada, actualizar la imagen
      String? imageUrl;
      if (imageFile.value != null || imageWebFile.value != null) {
        imageUrl = await _itemService.uploadImageForPlatform(
          kIsWeb ? imageWebFile.value! : imageFile.value!, item.id,
        );
        if (imageUrl != null) {
          item.imageUrl = imageUrl; // Actualizar la URL de la imagen en el ítem
        }
      }

      // Actualizar los datos del ítem en Firestore
      await _itemService.updateItem(item);
      Get.snackbar('Éxito', 'Ítem actualizado correctamente');
      fetchItems(); // Volver a cargar los ítems después de actualizar
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al actualizar el ítem');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para eliminar un ítem
  Future<void> deleteItem(String itemId) async {
    try {
      isLoading.value = true;
      await _itemService.deleteItem(itemId);
      Get.snackbar('Éxito', 'Ítem eliminado correctamente');
      fetchItems(); // Volver a cargar los ítems después de eliminar
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al eliminar el ítem');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para cargar todos los ítems
  void fetchItems() {
    isLoading.value = true;
    _itemService.getItems().listen((fetchedItems) {
      items.value = fetchedItems;
      applyFilter(); // Aplicar filtro cada vez que se actualicen los ítems
      isLoading.value = false;
    });
  }

  // Método para aplicar el filtro basado en el texto de búsqueda
  void applyFilter() {
    if (searchQuery.value.isEmpty) {
      // Si no hay búsqueda, mostrar todos los ítems
      filteredItems.value = items;
    } else {
      // Filtrar los ítems según el texto de búsqueda
      filteredItems.value = items.where((item) {
        return item.detail.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  // Método para actualizar el texto de búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilter(); // Aplicar el filtro cada vez que se actualice el texto de búsqueda
  }


  // Método para obtener un ítem por su ID
  Future<Item?> getItemById(String itemId) async {
    try {
      return await _itemService.getItem(itemId);
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al obtener el ítem');
      return null;
    }
  }
}
