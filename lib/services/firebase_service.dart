import 'dart:io';
import 'package:auth_2024/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instancia de Firestore
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para registrar un usuario con correo y contraseña
  Future<Usuario?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Si el usuario se crea correctamente, guarda los datos en Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Crea una instancia de Usuario usando el modelo
        Usuario usuario = Usuario(
          id: user.uid,
          email: email,
          name: name,
        );

        return usuario; // Retorna el objeto Usuario
      }

      return null;
    } catch (e) {
      print("Error en el registro: $e");
      return null;
    }
  }

  // Método para actualizar el perfil de usuario
  Future<Usuario?> updateUser({
    required String userId,
    String? name,
    String? whatsapp,
    String? phone,
    DateTime? birthDate,
    dynamic profileImage,
  }) async {
    try {
      String? imageUrl;

      Map<String, dynamic> dataToUpdate = {};

      if (name != null) dataToUpdate['name'] = name;
      if (whatsapp != null) dataToUpdate['whatsapp'] = whatsapp;
      if (phone != null) dataToUpdate['phone'] = phone;
      if (birthDate != null)
        dataToUpdate['birthDate'] = Timestamp.fromDate(birthDate);
      if (profileImage != null) dataToUpdate['imageUrl'] = profileImage;

      // Actualizamos el documento en Firestore
      await _firestore.collection('users').doc(userId).update(dataToUpdate);

      // Obtenemos los datos del usuario actualizado desde Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      // Convertimos el documento en una instancia de Usuario
      Usuario usuarioActualizado = Usuario(
        id: userId,
        email: doc['email'], // Asumimos que el email siempre está presente
        name: doc['name'] ?? name,
        whatsapp: doc['whatsapp'] ?? whatsapp,
        phone: doc['phone'] ?? phone,
        birthDate: doc['birthDate'] != null
            ? (doc['birthDate'] as Timestamp).toDate()
            : birthDate,
        imageUrl: doc['imageUrl'] ?? imageUrl,
      );

      return usuarioActualizado;
    } catch (e) {
      print("Error al actualizar usuario: $e");
      return null;
    }
  }

  // Método para iniciar sesión con correo y contraseña
  Future<Usuario?> loginWithEmail(String email, String password) async {
    try {
      // Inicia sesión con Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Si el usuario existe, obtenemos los datos de Firestore
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          // Creamos una instancia de Usuario usando los datos del documento
          Usuario usuario = Usuario(
            id: user.uid,
            email: doc['email'],
            name: doc['name'],
            whatsapp: doc['whatsapp'],
            phone: doc['phone'],
            birthDate: doc['birthDate'] != null
                ? (doc['birthDate'] as Timestamp).toDate()
                : null,
            imageUrl: doc['imageUrl'],
          );

          return usuario; // Retorna el objeto Usuario
        } else {
          print("Error: No se encontraron datos del usuario en Firestore.");
          return null;
        }
      }
      return null;
    } catch (e) {
      print("Error en el inicio de sesión: $e");
      return null;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  // Obtener usuario actual
  User? get currentUser {
    return _auth.currentUser;
  }

  // Método para subir la imagen según la plataforma (móvil o web)
  Future<String?> uploadImageForPlatform(
      dynamic imageFile, String userId) async {
    if (kIsWeb && imageFile is Uint8List) {
      return await uploadWebImage(imageFile, userId); // Subir imagen web
    } else if (imageFile is File) {
      return await uploadImage(imageFile, userId); // Subir imagen móvil
    } else {
      print('Error: Tipo de archivo no soportado.');
      return null;
    }
  }

  // Método para subir imágenes desde la web (Uint8List)
  Future<String?> uploadWebImage(Uint8List imageBytes, String userId) async {
    try {
      Reference storageReference = _storage.ref().child('users/$userId');
      UploadTask uploadTask = storageReference
          .putData(imageBytes); // Usar putData para bytes en la web
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen en la web: $e');
      return null;
    }
  }

  // Método para subir una imagen a Firebase Storage para móviles
  Future<String?> uploadImage(File imageFile, String userId) async {
    try {
      Reference storageReference = _storage.ref().child('users/$userId');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }
}
