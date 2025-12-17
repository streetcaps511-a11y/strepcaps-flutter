import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/producto_local.dart';
import 'package:streetmovil/models/categoria_local.dart';
import 'package:streetmovil/models/carrito_item.dart';
import 'package:streetmovil/providers/cart_provider.dart';
import 'package:streetmovil/utils/session_manager.dart';
import 'package:streetmovil/screens/home/cart_screen.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductoLocal producto;

  const ProductDetailScreen({super.key, required this.producto});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _tallaSeleccionada;
  int _cantidad = 1;

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text(
          'Acceso requerido',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Debes iniciar sesión para añadir productos al carrito.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItemCount = cart.items.length;
    final double cartTotal = cart.total;

    final categoria = categoriasFijas.firstWhere(
      (c) => c.id == widget.producto.categoriaId,
      orElse: () =>
          CategoriaLocal(id: '', nombre: 'General', descripcion: '', imageUrl: ''),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/gm_logo.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: AppColors.accent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/placeholder.jpg',
              image: widget.producto.imagenUrl,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.producto.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoria.nombre,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${_formatNumber(widget.producto.precio.toDouble())}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.producto.descripcion,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Talla',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: widget.producto.tallas.map((talla) {
                    final isSelected = _tallaSeleccionada == talla;
                    return GestureDetector(
                      onTap: () => setState(() => _tallaSeleccionada = talla),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.secondary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          talla,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Cantidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _cantidad > 1
                          ? () => setState(() => _cantidad--)
                          : null,
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Text(
                      '$_cantidad',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _cantidad++),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.secondary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cartTotal > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Carrito: \$${_formatNumber(cartTotal)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_tallaSeleccionada == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona una talla'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final email =
                          await SessionManager().getLoggedInUserEmail();
                      if (email == null) {
                        _showLoginRequiredDialog(context);
                        return;
                      }

                      cart.addItem(
                        CarritoItem(
                          id: widget.producto.id,
                          nombre: widget.producto.nombre,
                          imagenUrl: widget.producto.imagenUrl,
                          talla: _tallaSeleccionada!,
                          precio: widget.producto.precio.toDouble(),
                          cantidad: _cantidad,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('+ Añadir al Carrito'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Ahora acepta DOUBLE
  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
