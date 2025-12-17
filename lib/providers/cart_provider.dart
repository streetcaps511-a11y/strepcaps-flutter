import 'package:flutter/foundation.dart';
import 'package:streetmovil/models/carrito_item.dart';

class CartProvider with ChangeNotifier {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  void addItem(CarritoItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.id == item.id && i.talla == item.talla,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id, String talla) {
    _items.removeWhere((item) => item.id == id && item.talla == talla);
    notifyListeners();
  }

  void updateQuantity(String id, String talla, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id && item.talla == talla);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad = newQuantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}