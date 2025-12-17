// lib/screens/home/catalog_screen.dart
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/categoria_local.dart';
import 'package:streetmovil/screens/home/product_screen.dart';
import 'package:streetmovil/screens/home/cart_screen.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';
import 'package:streetmovil/screens/user/profile_screen.dart';
import 'package:streetmovil/screens/orders/orders_screen.dart';
import 'package:streetmovil/screens/devoluciones/devoluciones_screen.dart';
import 'package:streetmovil/utils/session_manager.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final SessionManager _sessionManager = SessionManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Image.asset(
          'assets/images/gm_logo.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
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
        child: FutureBuilder<String?>(
          future: _sessionManager.getLoggedInUserEmail(),
          builder: (context, snapshot) {
            final isLoggedIn = snapshot.hasData && snapshot.data != null;
            final email = snapshot.data ?? '';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.secondary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isLoggedIn ? email : 'Invitado',
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.accent, height: 1),

                if (!isLoggedIn)
                  ListTile(
                    leading: const Icon(Icons.login, color: AppColors.accent),
                    title: const Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),

                if (isLoggedIn) ...[
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.accent),
                    title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag, color: AppColors.accent),
                    title: const Text('Mis Pedidos', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrdersScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh, color: AppColors.accent),
                    title: const Text('Mis Devoluciones', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DevolucionesScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await _sessionManager.clearSession();
                      Navigator.pop(context);
                      // ✅ Cambiado: ir a LoginScreen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 32) / 2;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: itemWidth / 160,
                    ),
                    itemCount: categoriasFijas.length,
                    itemBuilder: (context, index) {
                      final categoria = categoriasFijas[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductScreen(
                                categoriaId: categoria.id,
                                nombreCategoria: categoria.nombre,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                categoria.imageUrl,
                                fit: BoxFit.cover,
                              ),
                              Container(color: Colors.black.withOpacity(0.5)),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    ),
                                  ),
                                  child: Text(
                                    categoria.nombre,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
        },
        child: const Icon(Icons.shopping_cart, color: AppColors.primary),
      ),
    );
  }
}