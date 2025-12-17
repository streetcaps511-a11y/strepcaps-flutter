// lib/screens/auth/register_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:streetmovil/constants/app_colors.dart';
import 'package:streetmovil/screens/auth/login_screen.dart';
import 'package:streetmovil/utils/session_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedDocType = 'Cédula de Identidad';
  bool _isLoading = false;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/gm_logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Tipo de Documento
              DropdownButtonFormField<String>(
                value: _selectedDocType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Documento',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                items: const [
                  DropdownMenuItem(value: 'Cédula de Identidad', child: Text('Cédula de Identidad')),
                  DropdownMenuItem(value: 'Pasaporte', child: Text('Pasaporte')),
                  DropdownMenuItem(value: 'Tarjeta de Identidad', child: Text('Tarjeta de Identidad')),
                  DropdownMenuItem(value: 'Cédula de Extranjería', child: Text('Cédula de Extranjería')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDocType = value!;
                  });
                },
                validator: (value) => value == null ? 'Selecciona un tipo de documento' : null,
              ),
              const SizedBox(height: 15),

              // 2. Número de Documento
              TextFormField(
                controller: _docNumberController,
                decoration: InputDecoration(
                  labelText: 'Número de Documento',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => (value?.isEmpty ?? true) ? 'Requerido' : null,
              ),
              const SizedBox(height: 15),

              // 3. Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Requerido';
                  if (!value!.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 4. Usuario
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 15),

              // 5. Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Requerido';
                  if (value!.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // 6. Confirmar Contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.secondary,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Requerido';
                  if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Botón
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            await _registerUser();
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : const Text('Crear Cuenta', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    setState(() => _isLoading = true);

    try {
      // 1. Registrar en Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Guardar en SessionManager
      final sessionManager = SessionManager();
      final email = _emailController.text.trim();

      // ✅ ¡ESTA LÍNEA ES LA CLAVE! (faltaba antes)
      await sessionManager.setLoggedInUser(email);

      await sessionManager.saveProfileData(
        name: email.split('@').first,
        username: _usernameController.text.trim(),
        phone: '',
        department: '',
        city: '',
        address: '',
        docType: _selectedDocType,
        docNumber: _docNumberController.text.trim(),
      );

      // 3. Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada exitosamente!')),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      String message = 'Error al crear la cuenta';
      if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña debe tener al menos 6 caracteres';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado. Inténtalo de nuevo.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}