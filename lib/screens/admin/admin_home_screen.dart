// lib/screens/admin/admin_home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/screens/admin/admin_orders_list_screen.dart';
import 'package:streetmovil/screens/admin/admin_devoluciones_list_screen.dart';
import 'package:streetmovil/screens/admin/admin_profile_screen.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Image.asset('assets/images/gm_logo.png', width: 60, height: 60, fit: BoxFit.contain),
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
        child: FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final email = user?.email ?? 'streetcaps511@gmail.com';
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.secondary),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(radius: 30, backgroundColor: AppColors.accent, child: Icon(Icons.admin_panel_settings, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      Text(email, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const Text('Panel Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Divider(color: AppColors.accent, height: 1),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.accent),
                  title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfileScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_bag, color: AppColors.accent),
                  title: const Text('Pedidos', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersListScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.accent),
                  title: const Text('Devoluciones', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDevolucionesListScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut(); // ✅ Logout de Firebase
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Panel de Administrador',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona una opción para gestionar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _buildAdminCard(context, icon: Icons.shopping_bag_outlined, title: 'Gestionar Pedidos', color: Colors.blue, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOrdersListScreen()));
                    }),
                    _buildAdminCard(context, icon: Icons.refresh_outlined, title: 'Gestionar Devoluciones', color: Colors.green, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDevolucionesListScreen()));
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    final maxWidth = MediaQuery.of(context).size.width * 0.42;
    final maxCardSize = maxWidth.clamp(140.0, 200.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: maxCardSize,
        height: maxCardSize,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}