// lib/screens/home/product_screen.dart
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/producto_local.dart';
import 'package:streetmovil/models/categoria_local.dart';
import 'package:streetmovil/screens/home/product_detail_screen.dart';
import 'package:streetmovil/screens/home/cart_screen.dart';

class ProductScreen extends StatefulWidget {
  final String categoriaId;
  final String nombreCategoria;

  const ProductScreen({super.key, required this.categoriaId, required this.nombreCategoria});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductoLocal> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  void _loadProductos() {
    final productos = productosFijos.where((p) => p.categoriaId == widget.categoriaId).toList();
    setState(() {
      _productos = productos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoria = categoriasFijas.firstWhere(
      (c) => c.id == widget.categoriaId,
      orElse: () => CategoriaLocal(id: '', nombre: '', descripcion: 'Colección de gorras exclusivas', imageUrl: ''),
    );

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _productos.isEmpty
          ? Center(child: Text('No hay productos en ${widget.nombreCategoria}', style: const TextStyle(color: Colors.white70)))
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombreCategoria,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoria.descripcion,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProductDetailScreen(producto: producto)),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  producto.imagenUrl,
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
                                      producto.nombre,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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