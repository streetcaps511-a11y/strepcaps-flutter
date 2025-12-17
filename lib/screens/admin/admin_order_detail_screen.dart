// lib/screens/admin/admin_order_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/order.dart' as model;

class AdminOrderDetailScreen extends StatefulWidget {
  final model.Order order;

  const AdminOrderDetailScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late String _currentStatus;
  final List<String> _estadosValidos = [
    'Pendiente',
    'En camino',
    'Entregado',
    'Anulado'
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.estado;
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    if (_currentStatus == 'Anulado') return;

    final confirm = await _showConfirmDialog(
      '¿Estás seguro?',
      'Esta acción no se puede deshacer.',
    );

    if (confirm != true) return;

    await _firestore
        .collection('orders')
        .where('email', isEqualTo: widget.order.email)
        .where('id', isEqualTo: widget.order.id)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'estado': nuevoEstado});
      }
    });

    if (!mounted) return;

    setState(() {
      _currentStatus = nuevoEstado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a: $nuevoEstado'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text(
          'Detalle del Pedido',
          style: TextStyle(color: Colors.white),
        ),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Detalle del Pedido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Selecciona una opción para gestionar',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'Información General',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Número de Pedido', widget.order.id),
                _buildInfoRow('Fecha', widget.order.fecha),
                _buildInfoRow('Cliente', widget.order.nombreCliente),
                _buildInfoRow('Email', widget.order.email),
                _buildInfoRow('Dirección', widget.order.direccion),
                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'Estado actual:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: _buildStatusBadge(_currentStatus)),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Cambiar estado:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: _getAvailableStatusButtons(),
                ),
                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    'Productos:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.accent, height: 16),
                  itemCount: widget.order.productos.length,
                  itemBuilder: (context, index) {
                    final item = widget.order.productos[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            item.imagenUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 20,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.nombre,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text(
                                'Talla: ${item.talla} • Cantidad: ${item.cantidad}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${_formatNumber(item.precio.toInt() * item.cantidad)}',
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 15),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Total: ',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18)),
                      Text(
                        '\$${_formatNumber(widget.order.total)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_currentStatus == 'Anulado')
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este pedido ha sido anulado. No se pueden realizar más cambios.',
                              style: TextStyle(color: Colors.red),
                            ),
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

  List<Widget> _getAvailableStatusButtons() {
    return _estadosValidos.map((estado) {
      bool isDisabled = false;
      bool isSelected = _currentStatus == estado;

      if (_currentStatus == 'Entregado' && estado != 'Anulado') {
        isDisabled = true;
      }
      if (_currentStatus == 'Anulado') {
        isDisabled = true;
      }

      final color = _getStatusColor(estado);

      return GestureDetector(
        onTap: isDisabled ? null : () => _actualizarEstado(estado),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled
                ? AppColors.secondary.withOpacity(0.3)
                : isSelected
                    ? color.withOpacity(0.2)
                    : AppColors.secondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey.withOpacity(0.5)
                  : color,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            estado,
            style: TextStyle(
              color: isDisabled
                  ? Colors.grey
                  : isSelected
                      ? color
                      : color.withOpacity(0.8),
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusBadge(String estado) {
    final color = _getStatusColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Entregado':
        return Colors.green;
      case 'En camino':
        return Colors.blue;
      case 'Pendiente':
        return Colors.orange;
      case 'Anulado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
