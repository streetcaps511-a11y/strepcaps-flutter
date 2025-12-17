// lib/screens/home/attach_receipt_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/carrito_item.dart';
import 'package:streetmovil/screens/home/order_success_screen.dart';
import 'package:streetmovil/utils/session_manager.dart';

class AttachReceiptScreen extends StatefulWidget {
  final List<CarritoItem> cartItems;
  final int total;

  const AttachReceiptScreen({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  State<AttachReceiptScreen> createState() => _AttachReceiptScreenState();
}

class _AttachReceiptScreenState extends State<AttachReceiptScreen> {
  bool _receiptUploaded = false;
  bool _isLoading = false;

  Future<void> _finalizeOrder() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1. Obtener datos del perfil
      final sessionManager = SessionManager();
      final emailValue = await sessionManager.getLoggedInUserEmail() ?? 'No disponible';
      final profile = await sessionManager.getProfileData();

      if (emailValue == 'No disponible' || emailValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: usuario no identificado'), backgroundColor: Colors.red),
        );
        return;
      }

      // 2. Crear datos del pedido
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      final fecha = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
      final nombreCliente = profile['username']?.isNotEmpty == true
          ? profile['username']!
          : emailValue.split('@').first;
      final direccion =
          '${profile['address'] ?? ''}, ${profile['city'] ?? ''}, ${profile['department'] ?? ''}';

      // 3. Guardar en Firestore
      final productosFirestore = widget.cartItems.map((item) {
        return {
          'nombre': item.nombre,
          'precio': item.precio,
          'cantidad': item.cantidad,
          'talla': item.talla,
          'imagenUrl': item.imagenUrl,
          'id': item.id,
        };
      }).toList();

      final orderDataFirestore = {
        'id': orderId,
        'fecha': fecha,
        'estado': 'Pendiente',
        'productos': productosFirestore,
        'total': widget.total,
        'direccion': direccion,
        'email': emailValue,
        'nombreCliente': nombreCliente,
      };

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set(orderDataFirestore);

      // 4. Guardar localmente
      final orderDataLocal = {
        'id': orderId,
        'fecha': fecha,
        'estado': 'Pendiente',
        'productos': widget.cartItems.map((item) => item.toMap()).toList(),
        'total': widget.total,
        'direccion': direccion,
        'email': emailValue,
        'nombreCliente': nombreCliente,
      };

      await sessionManager.saveOrderDataManually(orderDataLocal);

      // 5. Navegar
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderSuccessScreen(
          items: widget.cartItems,
          total: widget.total,
        )),
      );
    } catch (e) {
      debugPrint('Error al finalizar pedido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el pedido'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Adjuntar Comprobante',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de pago seleccionado:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Código QR',
                      style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Adjunta tu comprobante de pago',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Simula la subida de tu comprobante de pago',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _receiptUploaded = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Comprobante adjuntado'), backgroundColor: AppColors.accent),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text('Adjuntar comprobante', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary.withOpacity(0.6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (_receiptUploaded) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Comprobante adjuntado',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _receiptUploaded && !_isLoading
                      ? _finalizeOrder
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _receiptUploaded ? AppColors.accent : AppColors.secondary.withOpacity(0.5),
                    foregroundColor: _receiptUploaded ? AppColors.primary : Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)
                      : const Text('Finalizar Pedido', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}