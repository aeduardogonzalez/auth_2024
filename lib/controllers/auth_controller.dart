import 'dart:io';
import 'package:auth_2024/models/user.dart';
import 'package:auth_2024/pages/home_page.dart';
import 'package:auth_2024/pages/login_page.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart'; // Importar GetStorage
import '../services/firebase_service.dart';

class AuthController extends GetxController {
  var imageFile =
      Rxn<File>(); // Variable para almacenar la imagen seleccionada en móvil
  var imageWebFile =
      Rxn<Uint8List>(); // Variable para almacenar la imagen seleccionada en web
  final FirebaseService _firebaseService = FirebaseService();
  var isLoading = false.obs; // Observa si se está cargando una operación
  var user = Rxn<Usuario>(); // Observa el estado del usuario
  final storage =
      GetStorage(); // Crear una instancia de GetStorage para almacenar las credenciales

  @override
  void onInit() {
    super.onInit();
    _autoLogin(); // Intentar login automático al iniciar
  }

// Método para seleccionar una imagen (móvil o web)
  Future<void> pickImage(bool fromCamera) async {
    if (kIsWeb) {
      // Seleccionar imagen en Flutter Web usando FilePicker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.first.bytes != null) {
        imageWebFile.value =
            result.files.first.bytes; // Guardar imagen para la web
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

  // Método para registrar el usuario y guardar datos en Firestore
  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      Usuario? newUser = await _firebaseService.registerWithEmail(
          email: email, password: password, name: name);
      if (newUser != null) {
        user.value = newUser; // Usuario registrado exitosamente
        await _saveCredentials(email, password); // Guardar credenciales
        Get.offAll(() => HomePage()); // Redirigir a la vista principal
      } else {
        Get.snackbar("Error", "No se pudo registrar el usuario");
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error durante el registro");
    } finally {
      isLoading.value = false;
    }
  }

  //Método para actualizar datos del Usuario
  Future<void> updateUser(String name, String phone, String email,
      String whatsApp, DateTime? birthDate) async {
    try {
      isLoading.value = true; // Indicar que el proceso está en curso

      // Verificar si el usuario o el ID del usuario es nulo
      if (user.value == null || user.value?.id == null) {
        isLoading.value = false; // Si no hay usuario o ID, detenemos el loading
        Get.snackbar("Error", "Usuario no válido o no autenticado.");
        return;
      }

      String? imageUrl;

      // Verificar si se ha seleccionado una nueva imagen para subir
      if (imageFile.value != null || imageWebFile.value != null) {
        imageUrl = await _firebaseService.uploadImageForPlatform(
          kIsWeb ? imageWebFile.value! : imageFile.value!,
          user.value!.id, // Aseguramos que el ID no sea nulo
        );
      }

      // Actualiza los datos del usuario en Firestore
      await _firebaseService.updateUser(
        userId: user.value!.id, // Aseguramos que el ID no sea nulo
        name: name,
        whatsapp: whatsApp,
        phone: phone,
        birthDate: birthDate,
        profileImage: imageUrl, // Pasar imageUrl o null si no se actualizó
      );

      // Actualizar la información local del usuario
      user.value = Usuario(
        id: user.value!.id, // Aseguramos que el ID no sea nulo
        email: email,
        name: name,
        whatsapp: whatsApp,
        phone: phone,
        birthDate: birthDate,
        imageUrl: imageUrl ??
            user.value!
                .imageUrl, // Mantener la imagen anterior si no fue actualizada
      );

      Get.snackbar(
          "Éxito", "Los datos del usuario fueron actualizados correctamente.");
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error durante la actualización");
      print("Error en la actualización de usuario: $e");
    } finally {
      isLoading.value = false; // Detener el loading al finalizar
    }
  }

  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      Usuario? loggedInUser =
          await _firebaseService.loginWithEmail(email, password);
      if (loggedInUser != null) {
        user.value = loggedInUser; // Usuario inició sesión exitosamente
        await _saveCredentials(email, password); // Guardar credenciales
        Get.offAll(() => HomePage()); // Redirigir a la vista principal
      } else {
        Get.snackbar("Error", "No se pudo iniciar sesión");
      }
    } catch (e) {
      Get.snackbar("Error", "Ocurrió un error durante el inicio de sesión");
    } finally {
      isLoading.value = false;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _firebaseService.signOut();
    await _clearCredentials(); // Eliminar credenciales guardadas
    user.value = null; // Usuario ha cerrado sesión
    Get.snackbar("Sesión cerrada", "Hasta pronto");
    Get.offAll(() => LoginPage()); // Redirigir a la vista de login
  }

  // Guardar las credenciales de usuario usando GetStorage
  Future<void> _saveCredentials(String email, String password) async {
    storage.write('email', email);
    storage.write('password', password);
  }

  // Intentar login automático
  Future<void> _autoLogin() async {
    String? email = storage.read('email');
    String? password = storage.read('password');

    if (email != null && password != null) {
      await login(email, password); // Auto login con credenciales guardadas
    }
  }

  // Eliminar las credenciales guardadas
  Future<void> _clearCredentials() async {
    storage.remove('email');
    storage.remove('password');
  }
}
