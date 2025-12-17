// lib/screens/admin/admin_devolucion_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/devolucion.dart' as model;

class AdminDevolucionDetailScreen extends StatefulWidget {
  final model.Devolucion devolucion;

  const AdminDevolucionDetailScreen({super.key, required this.devolucion});

  @override
  State<AdminDevolucionDetailScreen> createState() => _AdminDevolucionDetailScreenState();
}

class _AdminDevolucionDetailScreenState extends State<AdminDevolucionDetailScreen> {
  late String _currentStatus;
  final TextEditingController _motivoRechazoController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.devolucion.estado;
  }

  @override
  void dispose() {
    _motivoRechazoController.dispose();
    super.dispose();
  }

  Future<void> _rechazarConMotivo() async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text('Motivo del rechazo', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _motivoRechazoController,
          decoration: const InputDecoration(
            hintText: 'Escribe el motivo...',
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          maxLength: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              final motivo = _motivoRechazoController.text.trim();
              if (motivo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El motivo es obligatorio'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context, motivo);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _actualizarEstadoConMotivo('No Aprobada', motivoRechazo: result);
    }
  }

  Future<void> _actualizarEstadoConMotivo(String nuevoEstado, {String? motivoRechazo}) async {
    await _firestore
        .collection('devoluciones')
        .where('id', isEqualTo: widget.devolucion.id)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        final data = {'estado': nuevoEstado};
        if (motivoRechazo != null) {
          data['motivoRechazo'] = motivoRechazo;
        }
        doc.reference.update(data);
      }
    });

    if (!mounted) return;
    setState(() {
      _currentStatus = nuevoEstado;
    });

    final mensaje = nuevoEstado == 'Aprobada' ? 'Devolución aprobada' : 'Devolución rechazada';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: AppColors.accent));
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.devolucion.producto;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Detalle de Devolución', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Devolución #${widget.devolucion.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.devolucion.fecha,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Información del Cliente',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Cliente', widget.devolucion.clienteNombre),
                _buildInfoRow('Email', widget.devolucion.clienteEmail),
                _buildInfoRow('Pedido Relacionado', widget.devolucion.pedidoId),
                _buildInfoRow('Motivo de Devolución', widget.devolucion.motivo),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Estado:',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: _buildStatusBadge(_currentStatus)),
                const SizedBox(height: 24),

                // 🖼️ Producto con imagen
                Center(
                  child: Text(
                    'Producto a devolver',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (producto.imagenUrl.isNotEmpty)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              producto.imagenUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const CircularProgressIndicator(color: AppColors.accent);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported, size: 40, color: Colors.white70);
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(producto.nombre, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Talla: ${producto.talla}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ Botones (solo si Pendiente)
                if (_currentStatus == 'Pendiente')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _actualizarEstadoConMotivo('Aprobada'),
                            icon: const Icon(Icons.check, size: 18, color: Colors.white),
                            label: const Text('Aprobar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _rechazarConMotivo(),
                            icon: const Icon(Icons.close, size: 18, color: Colors.white),
                            label: const Text('Rechazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ✅ Mostrar motivo de rechazo si está rechazada
                if (_currentStatus == 'No Aprobada' && widget.devolucion.motivoRechazo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Devolución rechazada', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Motivo: ${widget.devolucion.motivoRechazo}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    final color = _getStatusColor(estado);
    String texto = estado == 'No Aprobada' ? 'Rechazada' : estado;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Aprobada':
        return Colors.green;
      case 'No Aprobada':
        return Colors.red;
      case 'Pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}