// lib/screens/devoluciones/devolucion_form_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/models/carrito_item.dart';
import 'package:streetmovil/models/order.dart' as model;
import 'package:streetmovil/utils/session_manager.dart'; // ✅ Importa SessionManager

class DevolucionFormScreen extends StatefulWidget {
  final model.Order pedido;
  final CarritoItem producto;

  const DevolucionFormScreen({
    super.key,
    required this.pedido,
    required this.producto,
  });

  @override
  State<DevolucionFormScreen> createState() => _DevolucionFormScreenState();
}

class _DevolucionFormScreenState extends State<DevolucionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _motivoSeleccionado;
  String _motivoOtro = '';
  bool _isSubmitting = false;
  bool _devolucionYaSolicitada = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionManager _sessionManager = SessionManager(); // ✅

  final List<String> _motivos = [
    'Talla incorrecta',
    'Color no coincide con la imagen',
    'Producto defectuoso',
    'No es lo que esperaba',
    'Llegó dañado',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _checkIfDevolutionExists();
  }

  Future<void> _checkIfDevolutionExists() async {
    // ✅ Usar SessionManager para obtener el email
    final email = await _sessionManager.getLoggedInUserEmail();
    if (email == null) return;

    final snapshot = await _firestore
        .collection('devoluciones')
        .where('clienteEmail', isEqualTo: email.toLowerCase())
        .where('pedidoId', isEqualTo: widget.pedido.id)
        .where('producto.id', isEqualTo: widget.producto.id)
        .get();

    setState(() {
      _devolucionYaSolicitada = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> _enviarSolicitud() async {
    if (_isSubmitting) return;

    if (_motivoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un motivo')),
      );
      return;
    }

    if (_motivoSeleccionado == 'Otro' && _motivoOtro.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor describe el motivo')),
      );
      return;
    }

    // ✅ Usar SessionManager para obtener el email y nombre
    final email = await _sessionManager.getLoggedInUserEmail();
    if (email == null) return;

    final profile = await _sessionManager.getProfileData();
    final nombreCliente = profile['nombreCliente'] ?? profile['username'] ?? email.split('@').first;

    setState(() => _isSubmitting = true);

    final motivoFinal = _motivoSeleccionado == 'Otro' ? _motivoOtro : _motivoSeleccionado!;

    final devolucionId = 'DEV-${DateTime.now().millisecondsSinceEpoch}';

    final devolucionData = {
      'id': devolucionId,
      'pedidoId': widget.pedido.id,
      'fecha': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      'estado': 'Pendiente',
      'motivo': motivoFinal,
      'producto': {
        'id': widget.producto.id,
        'nombre': widget.producto.nombre,
        'imagenUrl': widget.producto.imagenUrl,
        'talla': widget.producto.talla,
        'cantidad': widget.producto.cantidad,
        'precio': widget.producto.precio,
      },
      'clienteNombre': nombreCliente,
      'clienteEmail': email.toLowerCase(), // ✅ Usa el email de SessionManager
    };

    await _firestore.collection('devoluciones').doc(devolucionId).set(devolucionData);

    if (!mounted) return;

    setState(() {
      _devolucionYaSolicitada = true;
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitud de devolución enviada'),
        backgroundColor: AppColors.accent,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Solicitar Devolución', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Producto con imagen
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.producto.imagenUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 24, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.producto.nombre, style: const TextStyle(color: Colors.white, fontSize: 16)),
                          Text('Cantidad: ${widget.producto.cantidad}', style: const TextStyle(color: Colors.white70)),
                          Text('Precio: \$${widget.producto.precio.toInt()}', style: const TextStyle(color: AppColors.accent)),
                          Text('Pedido: ${widget.pedido.id}', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Motivo de la devolución:', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _motivos.map((motivo) {
                  final isSelected = _motivoSeleccionado == motivo;
                  return GestureDetector(
                    onTap: _devolucionYaSolicitada
                        ? null
                        : () {
                            setState(() {
                              _motivoSeleccionado = motivo;
                              if (motivo != 'Otro') _motivoOtro = '';
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : AppColors.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent, width: isSelected ? 2 : 1),
                      ),
                      child: Text(
                        motivo,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.accent,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_motivoSeleccionado == 'Otro')
                Column(
                  children: [
                    TextField(
                      maxLines: 3,
                      onChanged: (value) => setState(() => _motivoOtro = value),
                      decoration: InputDecoration(
                        labelText: 'Describe el motivo...',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.secondary.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _devolucionYaSolicitada || _isSubmitting ? null : _enviarSolicitud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _devolucionYaSolicitada ? AppColors.secondary.withOpacity(0.5) : AppColors.accent,
                    foregroundColor: _devolucionYaSolicitada ? Colors.white70 : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : _devolucionYaSolicitada
                          ? const Text('Devolución Solicitada')
                          : const Text('Enviar Solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}