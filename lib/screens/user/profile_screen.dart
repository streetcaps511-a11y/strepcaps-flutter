// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/utils/session_manager.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';
import 'package:streetmovil/screens/home/catalog_screen.dart';
import 'package:streetmovil/screens/orders/orders_screen.dart';
import 'package:streetmovil/screens/devoluciones/devoluciones_screen.dart';
import 'package:streetmovil/screens/home/cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionManager _sessionManager = SessionManager();
  bool _isEditing = false;

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _docTypeController = TextEditingController();
  final _docNumberController = TextEditingController();

  String _email = '';
  String _nameFromEmail = '';

  final List<String> _departamentos = [
    'Antioquia',
    'Atlántico',
    'Bogotá D.C.',
    'Bolívar',
    'Cundinamarca',
    'Magdalena',
    'Norte de Santander',
    'Santander',
    'Valle del Cauca',
    'Tolima',
  ];

  final List<String> _ciudades = [
    'Medellín',
    'Barranquilla',
    'Bogotá',
    'Cartagena',
    'Villavicencio',
    'Santa Marta',
    'Cúcuta',
    'Bucaramanga',
    'Cali',
    'Ibagué',
  ];

  final List<String> _docTypes = [
    'Cédula de Identidad',
    'Tarjeta de Identidad',
    'Pasaporte',
    'Cédula de Extranjería',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final email = await _sessionManager.getLoggedInUserEmail() ?? '';
    final profile = await _sessionManager.getProfileData();

    if (!mounted) return;

    setState(() {
      _email = email;
      _nameFromEmail = email.split('@').first;

      _usernameController.text = profile['username']?.isNotEmpty == true 
          ? profile['username']! 
          : _nameFromEmail;

      _phoneController.text = profile['phone'] ?? '';
      _departmentController.text = profile['department'] ?? '';
      _cityController.text = profile['city'] ?? '';
      _addressController.text = profile['address'] ?? '';
      _docTypeController.text = profile['docType'] ?? '';
      _docNumberController.text = profile['docNumber'] ?? '';
    });
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveChanges() async {
    await _sessionManager.saveProfileData(
      name: _usernameController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
      docType: _docTypeController.text.trim(),
      docNumber: _docNumberController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados'),
        backgroundColor: AppColors.accent,
      ),
    );

    await _loadData();
    _toggleEdit();
  }

  Future<void> _logout() async {
    await _sessionManager.clearSession();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        title: Image.asset(
          'assets/images/gm_logo.png',
          width: 60,
          height: 60,
        ),
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _usernameController.text.isEmpty ? _nameFromEmail : _usernameController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    _email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category, color: AppColors.accent),
              title: const Text('Catálogo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen()),
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
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
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
                  MaterialPageRoute(builder: (_) => const DevolucionesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileHeader(),
          const SizedBox(height: 20),
          if (!_isEditing) _editAndCartButtons(),
          const SizedBox(height: 20),

          _buildDocTypeDropdown(enabled: _isEditing),
          _buildField('Número de Documento', _docNumberController, enabled: _isEditing),
          _buildField('Usuario', _usernameController, enabled: _isEditing),
          _buildField('Correo', TextEditingController(text: _email), enabled: false),
          _buildField('Teléfono', _phoneController, enabled: _isEditing),
          _buildDropdownField('Departamento', _departmentController, _departamentos, enabled: _isEditing),
          _buildDropdownField('Ciudad', _cityController, _ciudades, enabled: _isEditing),
          _buildField('Dirección', _addressController, enabled: _isEditing),

          if (_isEditing) const SizedBox(height: 20),
          if (_isEditing) _actionButtons(),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.accent,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            _usernameController.text.isEmpty ? _nameFromEmail : _usernameController.text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(_email, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _editAndCartButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Mi Carrito'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _toggleEdit,
          icon: const Icon(Icons.edit),
          label: const Text('Editar Perfil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _toggleEdit,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Guardar', style: TextStyle(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.secondary.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        onChanged: enabled ? (value) {
          if (value != null) {
            setState(() {
              controller.text = value;
            });
          }
        } : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.secondary.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        isExpanded: true,
        dropdownColor: AppColors.secondary,
        style: const TextStyle(color: Colors.white),
        hint: const Text('Selecciona una opción', style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildDocTypeDropdown({bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _docTypeController.text.isNotEmpty ? _docTypeController.text : null,
        onChanged: enabled ? (String? value) {
          if (value != null) {
            setState(() {
              _docTypeController.text = value;
            });
          }
        } : null,
        decoration: InputDecoration(
          labelText: 'Tipo de Documento',
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.secondary.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
        items: _docTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        isExpanded: true,
        dropdownColor: AppColors.secondary,
        style: const TextStyle(color: Colors.white),
        hint: const Text('Selecciona tipo de documento', style: TextStyle(color: Colors.white70)),
      ),
    );
  }
}