// lib/screens/admin/admin_devoluciones_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/devolucion.dart' as model;
import 'package:streetmovil/screens/admin/admin_devolucion_detail_screen.dart';

class AdminDevolucionesListScreen extends StatefulWidget {
  const AdminDevolucionesListScreen({super.key});

  @override
  State<AdminDevolucionesListScreen> createState() => _AdminDevolucionesListScreenState();
}

class _AdminDevolucionesListScreenState extends State<AdminDevolucionesListScreen> {
  late Future<List<model.Devolucion>> _devolucionesFuture;

  @override
  void initState() {
    super.initState();
    _devolucionesFuture = _loadDevoluciones();
  }

  Future<List<model.Devolucion>> _loadDevoluciones() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('devoluciones')
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) => model.Devolucion.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Devoluciones', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<model.Devolucion>>(
        future: _devolucionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.refresh_outlined, size: 60, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('No hay devoluciones', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            );
          }

          final devoluciones = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devoluciones.length,
            itemBuilder: (context, index) {
              final d = devoluciones[index];
              return Card(
                color: AppColors.secondary,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(d.producto.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente: ${d.clienteNombre}', style: const TextStyle(color: Colors.white70)),
                      Text('Pedido: ${d.pedidoId}', style: const TextStyle(color: Colors.white70)),
                      Text('Fecha: ${d.fecha}', style: const TextStyle(color: Colors.white70)),
                      Text('Motivo: ${d.motivo}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      _buildStatusBadge(d.estado),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.accent),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminDevolucionDetailScreen(devolucion: d),
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
    String texto = estado;
    switch (estado) {
      case 'Aprobada':
        color = Colors.green;
        break;
      case 'No Aprobada':
        color = Colors.red;
        texto = 'Rechazada';
        break;
      case 'Pendiente':
        color = Colors.orange;
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
        texto,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}