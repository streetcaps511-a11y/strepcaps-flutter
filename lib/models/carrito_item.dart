// lib/models/carrito_item.dart

class CarritoItem {
  final String id;
  final String nombre;
  final String imagenUrl;
  final String talla;
  final double precio;
  int cantidad;

  CarritoItem({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.talla,
    required this.precio,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;

  // Convertir a Map (para guardar en SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      'talla': talla,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  // Crear desde un Map (para leer desde SharedPreferences)
  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      // ✅ Ajuste de seguridad: si imagenUrl es null, usa cadena vacía
      imagenUrl: map['imagenUrl'] as String? ?? '',
      talla: map['talla'] as String,
      precio: (map['precio'] as num).toDouble(),
      cantidad: map['cantidad'] as int,
    );
  }
}