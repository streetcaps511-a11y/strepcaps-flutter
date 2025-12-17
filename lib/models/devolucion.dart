import 'package:streetmovil/models/carrito_item.dart';

class Devolucion {
  final String id;
  final String pedidoId;
  final String fecha;
  final String estado; // 'Pendiente', 'Aprobada', 'No Aprobada'
  final String motivo;
  final CarritoItem producto;
  final String clienteNombre;
  final String clienteEmail;
  final String? motivoRechazo; // ✅ NUEVO: motivo del rechazo

  Devolucion({
    required this.id,
    required this.pedidoId,
    required this.fecha,
    required this.estado,
    required this.motivo,
    required this.producto,
    required this.clienteNombre,
    required this.clienteEmail,
    this.motivoRechazo, // opcional
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedidoId': pedidoId,
      'fecha': fecha,
      'estado': estado,
      'motivo': motivo,
      'producto': producto.toMap(),
      'clienteNombre': clienteNombre,
      'clienteEmail': clienteEmail,
      if (motivoRechazo != null) 'motivoRechazo': motivoRechazo,
    };
  }

  factory Devolucion.fromMap(Map<String, dynamic> map) {
    return Devolucion(
      id: map['id'] as String,
      pedidoId: map['pedidoId'] as String,
      fecha: map['fecha'] as String,
      estado: map['estado'] as String,
      motivo: map['motivo'] as String,
      producto: CarritoItem.fromMap(map['producto'] as Map<String, dynamic>),
      clienteNombre: map['clienteNombre'] as String,
      clienteEmail: map['clienteEmail'] as String,
      motivoRechazo: map['motivoRechazo'] as String? ?? null,
    );
  }
}


class ProductoLocal {
  final String id;
  final String nombre;
  final String descripcion;
  final int precio;
  final String imagenUrl;
  final String categoriaId;
  final List<String> tallas;
  final int stock;

  ProductoLocal({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoriaId,
    required this.tallas,
    required this.stock,
  });
}