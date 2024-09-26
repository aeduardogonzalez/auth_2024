import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String id;
  String imageUrl;
  String detail;
  int quantity;
  double price;
  bool isActive;
  DateTime? purchaseDate; // Hacer purchaseDate opcional
  String category;

  // Constructor
  Item({
    required this.id,
    required this.imageUrl,
    required this.detail,
    required this.quantity,
    required this.price,
    required this.isActive,
    this.purchaseDate, // purchaseDate puede ser nulo
    required this.category,
  });

  // Método para convertir un documento de Firestore en una instancia de Item
  factory Item.fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id, // ID del documento
      imageUrl: data['imageUrl'] ?? '',
      detail: data['detail'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: data['price'] != null ? data['price'].toDouble() : 0.0,
      isActive: data['isActive'] ?? false,
      // Verificamos si 'purchaseDate' no es nulo y lo convertimos a DateTime
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as Timestamp).toDate()
          : null,
      category: data['category'] ?? '',
    );
  }

  // Método para convertir un objeto Item a Map (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'detail': detail,
      'quantity': quantity,
      'price': price,
      'isActive': isActive,
      'purchaseDate':
          purchaseDate != null ? Timestamp.fromDate(purchaseDate!) : null,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
