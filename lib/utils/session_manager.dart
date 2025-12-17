// lib/utils/session_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetmovil/models/user.dart';
import 'package:streetmovil/models/order.dart';
import 'package:streetmovil/models/devolucion.dart';

class SessionManager {
  static const String _adminEmail = 'streetcaps511@gmail.com';

  // === SESIÓN ACTUAL ===
  Future<void> setLoggedInUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_email', email);
  }

  Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('current_user_email');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
  }

  Future<bool> isLoggedIn() async {
    final email = await getLoggedInUserEmail();
    return email != null;
  }

  // === USUARIOS ===
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${user.email}';
    await prefs.setString(key, jsonEncode(user.toMap()));
  }

  Future<User?> getUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_${email}';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return User.fromMap(map);
  }

  Future<bool> isUserRegistered(String email) async {
    final user = await getUser(email);
    return user != null;
  }

  Future<bool> isAdmin() async {
    final email = await getLoggedInUserEmail();
    return email?.toLowerCase() == _adminEmail;
  }

  // === PERFIL (AHORA INCLUYE DOCUMENTO) ===
  Future<void> saveProfileData({
    required String name,
    required String username,
    required String phone,
    required String department,
    required String city,
    required String address,
    required String docType,
    required String docNumber,
  }) async {
    final email = await getLoggedInUserEmail();
    if (email == null) return;

    final user = User(
      email: email,
      name: name,
      username: username,
      phone: phone,
      department: department,
      city: city,
      address: address,
      docType: docType,
      docNumber: docNumber,
      isAdmin: email.toLowerCase() == _adminEmail,
    );

    await saveUser(user);
  }

  Future<Map<String, String>> getProfileData() async {
    final email = await getLoggedInUserEmail();
    if (email == null) return {};

    final user = await getUser(email);
    if (user == null) return {};

    return {
      'name': user.name,
      'username': user.username,
      'phone': user.phone,
      'department': user.department,
      'city': user.city,
      'address': user.address,
      'docType': user.docType,
      'docNumber': user.docNumber,
    };
  }

  // === PEDIDOS ===
  String _getOrdersKey(String userEmail) => 'orders_$userEmail';

  Future<void> saveOrder(Order order) async {
    final email = await getLoggedInUserEmail();
    if (email == null || await isAdmin()) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _getOrdersKey(email);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    list.insert(0, order.toMap());
    await prefs.setString(key, jsonEncode(list));
  }

  // ✅ Nuevo método para guardar pedido manualmente (usado por OrderSuccessScreen)
  Future<void> saveOrderDataManually(Map<String, dynamic> orderData) async {
    final email = await getLoggedInUserEmail();
    if (email == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _getOrdersKey(email);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    list.insert(0, orderData);
    await prefs.setString(key, jsonEncode(list));
  }

  Future<List<Order>> getOrders() async {
    final email = await getLoggedInUserEmail();
    if (email == null) return [];

    final prefs = await SharedPreferences.getInstance();

    if (await isAdmin()) {
      final keys = prefs.getKeys().where((k) => k.startsWith('orders_')).toList();
      final allOrders = <Order>[];
      for (final key in keys) {
        final json = prefs.getString(key) ?? '[]';
        final list = jsonDecode(json) as List;
        allOrders.addAll(list.map((e) => Order.fromMap(e as Map<String, dynamic>)));
      }
      allOrders.sort((a, b) => b.id.compareTo(a.id));
      return allOrders;
    }

    final key = _getOrdersKey(email);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Order.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateOrderStatus(String userEmail, String orderId, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getOrdersKey(userEmail);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    for (var i = 0; i < list.length; i++) {
      if (list[i]['id'] == orderId) {
        list[i]['estado'] = newStatus;
        break;
      }
    }
    await prefs.setString(key, jsonEncode(list));
  }

  // === DEVOLUCIONES ===
  String _getDevolucionesKey(String userEmail) => 'devoluciones_$userEmail';

  Future<void> saveDevolucion(Devolucion devolucion) async {
    final email = await getLoggedInUserEmail();
    if (email == null || await isAdmin()) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _getDevolucionesKey(email);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    list.insert(0, devolucion.toMap());
    await prefs.setString(key, jsonEncode(list));
  }

  Future<List<Devolucion>> getDevoluciones() async {
    final email = await getLoggedInUserEmail();
    if (email == null) return [];

    final prefs = await SharedPreferences.getInstance();

    if (await isAdmin()) {
      final keys = prefs.getKeys().where((k) => k.startsWith('devoluciones_')).toList();
      final all = <Devolucion>[];
      for (final key in keys) {
        final json = prefs.getString(key) ?? '[]';
        final list = jsonDecode(json) as List;
        all.addAll(list.map((e) => Devolucion.fromMap(e as Map<String, dynamic>)));
      }
      all.sort((a, b) => b.id.compareTo(a.id));
      return all;
    }

    final key = _getDevolucionesKey(email);
    final jsonString = prefs.getString(key) ?? '[]';
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => Devolucion.fromMap(e as Map<String, dynamic>)).toList();
  }
}