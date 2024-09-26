import 'package:auth_2024/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Page4 extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedBirthDate;
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    // Cargar los datos actuales del usuario en los TextEditingControllers
    final usuario = _authController.user.value;
    if (usuario != null) {
      _nameController.text = usuario.name;
      _emailController.text = usuario.email;
      _whatsappController.text = usuario.whatsapp ?? '';
      _phoneController.text = usuario.phone ?? '';
      _selectedBirthDate = usuario.birthDate;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Imagen circular con icono de cámara
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: usuario?.imageUrl != null
                      ? NetworkImage(usuario!.imageUrl!)
                      : AssetImage('assets/profile_placeholder.png')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _showImagePicker(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Campo de texto para el nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Campo de texto para el correo electrónico
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            // Campo de texto para WhatsApp
            TextField(
              controller: _whatsappController,
              decoration: InputDecoration(
                labelText: 'WhatsApp',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),

            // Campo de texto para celular
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Celular',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),

            // Campo de selección de fecha de nacimiento
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? 'Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)}'
                        : 'Seleccione su fecha de nacimiento',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectBirthDate(context),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Botón para guardar cambios
            ElevatedButton(
              onPressed: () async {
                // Lógica para guardar los cambios
                String name = _nameController.text.trim();
                String email = _emailController.text.trim();
                String wsp = _whatsappController.text.trim();
                String phone = _phoneController.text.trim();

                await _authController.updateUser(
                  name,
                  phone,
                  email,
                  wsp,
                  _selectedBirthDate,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Datos guardados exitosamente')),
                );
              },
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para seleccionar la fecha de nacimiento
  Future<void> _selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedBirthDate) {
      _selectedBirthDate = pickedDate;
    }
  }

  // Método para mostrar el picker de imágenes
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
                _authController.pickImage(true);
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () {
                _authController.pickImage(false);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
