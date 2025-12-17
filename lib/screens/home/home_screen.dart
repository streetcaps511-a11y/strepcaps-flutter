// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';
import 'package:streetmovil/screens/home/catalog_screen.dart';
import 'package:streetmovil/screens/user/profile_screen.dart'; 
import 'package:streetmovil/screens/orders/orders_screen.dart';
import 'package:streetmovil/screens/devoluciones/devoluciones_screen.dart';
import 'package:streetmovil/utils/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionManager _sessionManager = SessionManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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

                ListTile(
                  leading: const Icon(Icons.category, color: AppColors.accent),
                  title: const Text('Catálogo', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogScreen()),
                    );
                  },
                ),

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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
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

      // 👇 FONDO CON OVERLAY OSCURO
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.network(
              'https://ucarecdn.com/5af41491-7fb7-4409-9aa8-4c5df7b51413/-/format/auto/-/preview/3000x3000/-/quality/lighter/6F7A1531.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Capa negra con transparencia
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55), // ajusta 0.4 - 0.7 si quieres
            ),
          ),

          // Contenido
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/gm_logo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Bienvenido a GM Caps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La mejor colección de gorras exclusivas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CatalogScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver Categorías',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
