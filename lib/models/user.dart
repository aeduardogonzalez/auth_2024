import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String id;
  String email;
  String name;
  String? whatsapp; // Opcional
  String? phone; // Opcional
  DateTime? birthDate; // Opcional
  String? imageUrl; // Opcional

  // Constructor
  Usuario({
    required this.id,
    required this.email,
    required this.name,
    this.whatsapp, // Opcional
    this.phone, // Opcional
    this.birthDate, // Opcional
    this.imageUrl, // Opcional
  });

  // Método para convertir un documento de Firestore en una instancia de Usuario
  factory Usuario.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id, // ID del documento
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      whatsapp: data['whatsapp'], // Puede ser nulo
      phone: data['phone'], // Puede ser nulo
      // Verificamos si 'birthDate' no es nulo y lo convertimos a DateTime
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      imageUrl: data['imageUrl'], // Puede ser nulo
    );
  }

  // Método para convertir un objeto Usuario a Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'whatsapp': whatsapp,
      'phone': phone,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
