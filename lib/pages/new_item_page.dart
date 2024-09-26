import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/item_controller.dart';
import '../models/item.dart';

class NewItemPage extends StatefulWidget {
  @override
  _NewItemPageState createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  final ItemController _itemController = Get.find();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool isActive = false; // Campo para el checkbox de activo/inactivo
  DateTime? selectedDate; // Campo para la fecha de compra
  String? selectedCategory; // Campo para la categoría seleccionada

  // Lista de categorías
  final List<String> categories = ['Categoría 1', 'Categoría 2', 'Categoría 3'];

  Item? currentItem; // El ítem actual que se edita (si se está editando)

  @override
  void initState() {
    super.initState();
    // Verificar si estamos editando un ítem
    if (Get.arguments != null) {
      currentItem = Get.arguments
          as Item; // Obtener el ítem pasado a través de Get.arguments
      _loadItemData();
    }
  }

  // Cargar los datos del ítem existente en los campos correspondientes
  void _loadItemData() {
    _detailController.text = currentItem!.detail;
    _quantityController.text = currentItem!.quantity.toString();
    _priceController.text = currentItem!.price.toString();
    isActive = currentItem!.isActive;
    selectedDate = currentItem!.purchaseDate;
    selectedCategory = currentItem!.category;

    // Reseteamos la imagen si ya existe para permitir que se seleccione una nueva
    if (currentItem!.imageUrl.isNotEmpty) {
      _itemController.imageFile.value =
          null; // Reseteamos la imagen en caso de cargar una nueva
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem == null ? 'Crear Ítem' : 'Editar Ítem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sección para seleccionar la imagen
            GestureDetector(
              onTap: () => _showImagePicker(context),
              child: Obx(() {
                // Mostrar imagen seleccionada (para web y móvil)
                if (_itemController.imageFile.value != null) {
                  // Mostrar imagen seleccionada en móviles (File)
                  return Image.file(
                    _itemController.imageFile.value!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else if (_itemController.imageWebFile.value != null) {
                  // Mostrar imagen seleccionada en web (Uint8List)
                  return Image.memory(
                    _itemController.imageWebFile.value!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else if (currentItem != null &&
                    currentItem!.imageUrl.isNotEmpty) {
                  // Mostrar imagen existente si estamos editando
                  return Image.network(
                    currentItem!.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  // Mostrar el contenedor para seleccionar una imagen
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Center(child: Text('Seleccionar Imagen')),
                  );
                }
              }),
            ),
            SizedBox(height: 20),

            // Campo de texto para el detalle del ítem
            TextField(
              controller: _detailController,
              decoration: InputDecoration(labelText: 'Detalle'),
            ),
            SizedBox(height: 10),

            // Campo de texto para la cantidad
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad'),
            ),
            SizedBox(height: 10),

            // Campo de texto para el precio
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
            ),
            SizedBox(height: 10),

            // Campo de selección de categoría
            DropdownButton<String>(
              value: selectedCategory,
              hint: Text('Seleccione una categoría'),
              isExpanded: true,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
            ),
            SizedBox(height: 10),

            // Campo de selección de fecha
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? 'Fecha de compra: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'
                        : 'Seleccione la fecha de compra',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Campo de checkbox para Activo/Inactivo
            Row(
              children: [
                Checkbox(
                  value: isActive,
                  onChanged: (bool? value) {
                    setState(() {
                      isActive = value ?? false;
                    });
                  },
                ),
                Text('Activo'),
              ],
            ),
            SizedBox(height: 20),

            // Botón para guardar o actualizar el ítem
            Obx(() {
              return _itemController.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        // Validar que se haya seleccionado una categoría
                        if (selectedCategory == null) {
                          Get.snackbar(
                              'Error', 'Debe seleccionar una categoría');
                          return;
                        }

                        // Guardar o actualizar ítem con la información ingresada
                        final detail = _detailController.text;
                        final quantity =
                            int.tryParse(_quantityController.text) ?? 0;
                        final price =
                            double.tryParse(_priceController.text) ?? 0.0;

                        if (selectedDate == null) {
                          Get.snackbar(
                              'Error', 'Debe seleccionar una fecha de compra');
                          return;
                        }

                        if (currentItem == null) {
                          // Guardar nuevo ítem
                          _itemController.saveNewItem(
                            detail,
                            quantity,
                            price,
                            isActive,
                            selectedDate!,
                            selectedCategory!,
                          );
                        } else {
                          // Actualizar ítem existente
                          currentItem!.detail = detail;
                          currentItem!.quantity = quantity;
                          currentItem!.price = price;
                          currentItem!.isActive = isActive;
                          currentItem!.purchaseDate = selectedDate;
                          currentItem!.category = selectedCategory!;

                          _itemController.updateItem(currentItem!);
                        }

                        Get.back(); // Volver a la pantalla anterior
                      },
                      child: Text(currentItem == null
                          ? 'Guardar Ítem'
                          : 'Actualizar Ítem'),
                    );
            }),
          ],
        ),
      ),
    );
  }

  // Método para mostrar el diálogo de selección de imagen
  void _showImagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Cámara'),
              onTap: () {
                _itemController.pickImage(true);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () {
                _itemController.pickImage(false);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método para seleccionar la fecha de compra
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}
