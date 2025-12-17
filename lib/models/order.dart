// lib/models/order.dart
import 'package:streetmovil/models/carrito_item.dart';

class Order {
  final String id;
  final String fecha;
  final String estado; // 'Pendiente', 'En camino', 'Entregado', 'Anulado'
  final List<CarritoItem> productos;
  final int total; // 👈 Mantenemos como int (asumimos que es en pesos, sin decimales)
  final String direccion;
  final String email;
  final String nombreCliente;

  Order({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.productos,
    required this.total,
    required this.direccion,
    required this.email,
    required this.nombreCliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'estado': estado,
      'productos': productos.map((p) => p.toMap()).toList(),
      'total': total,
      'direccion': direccion,
      'email': email,
      'nombreCliente': nombreCliente,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    final productos = (map['productos'] as List<dynamic>)
        .map((item) => CarritoItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: map['id'] as String,
      fecha: map['fecha'] as String,
      estado: map['estado'] as String,
      productos: productos,
      total: (map['total'] as num).toInt(), // 👈 Conversión segura desde JSON (puede ser double o int)
      direccion: map['direccion'] as String,
      email: map['email'] as String,
      nombreCliente: map['nombreCliente'] as String,
    );
  }
}