// lib/screens/devoluciones/devoluciones_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/devolucion.dart' as model;
import 'package:streetmovil/screens/devoluciones/devolucion_detail_screen.dart';
import 'package:streetmovil/utils/session_manager.dart';

import 'package:streetmovil/screens/auth/login_screen.dart';
import 'package:streetmovil/screens/user/profile_screen.dart';
import 'package:streetmovil/screens/orders/orders_screen.dart';

class DevolucionesScreen extends StatefulWidget {
  const DevolucionesScreen({super.key});

  @override
  State<DevolucionesScreen> createState() => _DevolucionesScreenState();
}

class _DevolucionesScreenState extends State<DevolucionesScreen> {
  late Future<List<model.Devolucion>> _devolucionesFuture;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _devolucionesFuture = _loadDevoluciones();
  }

Future<List<model.Devolucion>> _loadDevoluciones() async {
  final email = await _sessionManager.getLoggedInUserEmail();
  if (email == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('devoluciones')
      .where('clienteEmail', isEqualTo: email.toLowerCase())
      .get();

  final List<model.Devolucion> devoluciones = [];
  for (var doc in snapshot.docs) {
    try {
      devoluciones.add(model.Devolucion.fromMap(doc.data()));
    } catch (e) {
      debugPrint('Error al parsear: $e');
    }
  }

  // ✅ Función para convertir "dd/mm/yyyy" a DateTime
  DateTime _parseFecha(String fecha) {
    final partes = fecha.split('/');
    if (partes.length != 3) return DateTime(1970);
    final dia = int.tryParse(partes[0]) ?? 1;
    final mes = int.tryParse(partes[1]) ?? 1;
    final anio = int.tryParse(partes[2]) ?? 1970;
    return DateTime(anio, mes, dia);
  }

  // ✅ Ordenar por fecha real (más recientes primero)
  devoluciones.sort((a, b) => _parseFecha(b.fecha).compareTo(_parseFecha(a.fecha)));
  return devoluciones;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Mis Devoluciones', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.accent),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.secondary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: AppColors.accent, child: Icon(Icons.person, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  const Text('Mi Cuenta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(color: AppColors.accent, height: 1),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.accent),
              title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: AppColors.accent),
              title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await _sessionManager.clearSession();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<model.Devolucion>>(
          future: _devolucionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.accent));
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text('Error al cargar devoluciones', style: TextStyle(color: Colors.white)));
            }

            final devoluciones = snapshot.data!;

            if (devoluciones.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No has solicitado devoluciones aún',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: devoluciones.length,
              itemBuilder: (context, index) {
                final dev = devoluciones[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevolucionDetailScreen(devolucionId: dev.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dev.producto.nombre, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Pedido: ${dev.pedidoId}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(dev.fecha, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(dev.estado).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(dev.estado)),
                          ),
                          child: Text(
                            _getEstadoTexto(dev.estado),
                            style: TextStyle(color: _getStatusColor(dev.estado), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Aprobada': return Colors.green;
      case 'No Aprobada': return Colors.red;
      case 'Pendiente': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'Aprobada': return 'Aprobada';
      case 'No Aprobada': return 'Rechazada';
      case 'Pendiente': return 'Pendiente';
      default: return estado;
    }
  }
}