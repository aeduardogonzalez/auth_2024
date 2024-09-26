import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/item_controller.dart';
import 'new_item_page.dart';

class Page1 extends StatelessWidget {
  final ItemController _itemController = Get.put(ItemController());
  final TextEditingController _searchController =
      TextEditingController(); // Controlador para el campo de búsqueda

  @override
  Widget build(BuildContext context) {
    _itemController
        .fetchItems(); // Cargar los ítems cuando se construye la página
    return Scaffold(
      appBar: AppBar(
        title: Text('Ítems'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.to(() =>
                  NewItemPage()); // Navegar a la página de creación de ítems
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de texto para la búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _itemController.updateSearchQuery(
                    value); // Actualizar la búsqueda en el controlador
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_itemController.filteredItems.isEmpty) {
                return Center(child: Text('No se encontraron ítems.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75, // Ajustar el tamaño de las tarjetas
                ),
                itemCount: _itemController.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _itemController.filteredItems[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen del ítem
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              item.imageUrl,
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, size: 100);
                              },
                            ),
                          ),
                        ),

                        // Detalles del ítem
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.detail,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Cantidad: ${item.quantity}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Valor: \$${item.price}'),
                        ),

                        // Íconos de editar y eliminar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Navegar a la página de edición con los datos del ítem
                                Get.to(() => NewItemPage(), arguments: item);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Confirmación antes de eliminar
                                Get.defaultDialog(
                                  title: 'Eliminar Ítem',
                                  middleText:
                                      '¿Estás seguro de eliminar este ítem?',
                                  textConfirm: 'Sí',
                                  textCancel: 'No',
                                  onConfirm: () {
                                    _itemController.deleteItem(item.id);
                                    Get.back(); // Cerrar el diálogo
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
