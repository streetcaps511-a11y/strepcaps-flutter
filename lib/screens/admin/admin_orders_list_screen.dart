// lib/screens/admin/admin_orders_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/order.dart' as model;
import 'package:streetmovil/screens/admin/admin_order_detail_screen.dart';

class AdminOrdersListScreen extends StatefulWidget {
  const AdminOrdersListScreen({super.key});

  @override
  State<AdminOrdersListScreen> createState() => _AdminOrdersListScreenState();
}

class _AdminOrdersListScreenState extends State<AdminOrdersListScreen> {
  late Future<List<model.Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<model.Order>> _loadOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();

      final List<model.Order> orders = [];
      for (var doc in snapshot.docs) {
        try {
          // ✅ Eliminado el filtro: todos los documentos se parsean
          orders.add(model.Order.fromMap(doc.data()));
        } catch (e) {
          debugPrint('Error al parsear pedido ${doc.id}: $e');
        }
      }

      orders.sort((a, b) => b.id.compareTo(a.id));
      return orders;
    } catch (e) {
      debugPrint('Error al cargar pedidos del admin: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Pedidos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<model.Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('No hay pedidos', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: AppColors.secondary,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    'Pedido ${order.id}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente: ${order.nombreCliente}', style: const TextStyle(color: Colors.white70)),
                      Text('Fecha: ${order.fecha}', style: const TextStyle(color: Colors.white70)),
                      Text('Total: \$${_formatNumber(order.total)}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 4),
                      _buildStatusBadge(order.estado),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    Color color;
    switch (estado) {
      case 'Entregado':
        color = Colors.green;
        break;
      case 'En camino':
        color = Colors.blue;
        break;
      case 'Pendiente':
        color = Colors.orange;
        break;
      case 'Anulado':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        estado,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}