// lib/screens/home/qr_code_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/carrito_item.dart';
import 'package:streetmovil/screens/home/attach_receipt_screen.dart';

class QrCodePaymentScreen extends StatelessWidget {
  final String address;
  final List<CarritoItem> cartItems;

  const QrCodePaymentScreen({
    super.key,
    required this.address,
    required this.cartItems,
  });

  int get _total {
    return cartItems.fold(0, (sum, item) => sum + (item.precio * item.cantidad).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final items = cartItems;

    // ✅ Tamaño dinámico basado en ancho de pantalla
    double qrSize = MediaQuery.of(context).size.width * 0.4; // 40% del ancho
    if (qrSize > 200) qrSize = 200; // Máximo 200
    if (qrSize < 120) qrSize = 120; // Mínimo 120

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Código QR de Pago',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ QR Simulado con emojis ⬛⬜ (ajustable)
                    SizedBox(
                      width: qrSize,
                      height: qrSize,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('⬛⬛⬛⬛⬛', style: TextStyle(fontSize: 32, color: Colors.white)),
                            const Text('⬛⬜⬜⬜⬛', style: TextStyle(fontSize: 32, color: Colors.white)),
                            const Text('⬛⬜⬛⬜⬛', style: TextStyle(fontSize: 32, color: Colors.white)),
                            const Text('⬛⬜⬜⬜⬛', style: TextStyle(fontSize: 32, color: Colors.white)),
                            const Text('⬛⬛⬛⬛⬛', style: TextStyle(fontSize: 32, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Código QR Simulado',
                      style: TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escanea este código con tu app bancaria para completar el pago.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pago exitoso'), backgroundColor: AppColors.accent),
                        );
                        // ✅ PASAMOS cartItems y total a AttachReceiptScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttachReceiptScreen(
                            cartItems: cartItems, // ✅
                            total: _total,       // ✅
                          )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirmar Pago', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Pedido',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...items.map((item) {
                    final subtotal = item.precio * item.cantidad;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // ✅ Emoji pequeño para producto
                          const Icon(Icons.shopping_bag, color: AppColors.accent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.nombre} x${item.cantidad}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                  style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.accent, thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${_total.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}