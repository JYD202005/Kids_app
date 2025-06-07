import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kids_apps2/Logins/guardadolocal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

typedef RegistroFunction = Future<void> Function();

class Loginregistro extends StatefulWidget {
  const Loginregistro({super.key});

  @override
  State<Loginregistro> createState() => _LoginregistroState();
}

class _LoginregistroState extends State<Loginregistro> {
  final TextEditingController nombreDelUsuario = TextEditingController();
  final TextEditingController nombreDelPadre = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController passwordRecuperacion = TextEditingController();
  final TextEditingController codigoVerificacion = TextEditingController();

  bool _isLoading = false;
  bool _esperandoVerificacion = false;
  bool unico = false;
  final storage = CodigoLocalService();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Registro del Niño',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 24.0,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gifs/field3.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(
                      controller: nombreDelUsuario,
                      label: 'Nombre Del Niño',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: nombreDelPadre,
                      label: 'Nombre Del Papa',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _email,
                      label: 'Email De Atencion',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: passwordRecuperacion,
                      label: 'Contraseña De La Cuenta',
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _handleRegistro,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text(
                          'Completar Registro',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_esperandoVerificacion || _isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: codigoVerificacion,
                        label: 'Código de verificación',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _handleVerificacion,
                        icon: const Icon(Icons.verified_outlined),
                        label: const Text('Verificar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para construir los campos
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.lightBlueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Separar lógica de los botones para que sea más limpio

  void _handleRegistro() async {
    if (_isLoading || _esperandoVerificacion || unico) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Espera $_segundosRestantes segundos para continuar'),
        ),
      );
      return;
    }
    await registrarUsuario(
      email: _email.text.trim(),
      password: passwordRecuperacion.text.trim(),
      nombreNino: nombreDelUsuario.text.trim(),
      nombrePadre: nombreDelPadre.text.trim(),
    );
  }

  void _handleVerificacion() async {
    setState(() => _isLoading = true);
    final exitoso = await verificacion();
    setState(() {
      _isLoading = false;
      _esperandoVerificacion = !exitoso;
    });
    if (exitoso) {
      await completarRegistro(
        email: _email.text.trim(),
        password: passwordRecuperacion.text.trim(),
        nombreNino: nombreDelUsuario.text.trim(),
        nombrePadre: nombreDelPadre.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código incorrecto. Intenta nuevamente.'),
        ),
      );
      codigoVerificacion.clear();
    }
  }

  Future<void> registrarUsuario({
    required String email,
    required String password,
    required String nombreNino,
    required String nombrePadre,
  }) async {
    if (!mounted) return;

    // Validar restricciones
    if (!Restricciones(
      nombreDelUsuario: nombreDelUsuario,
      nombreDelPadre: nombreDelPadre,
      email: _email,
      passwordRecuperacion: passwordRecuperacion,
    )) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _isLoading = true;
      _esperandoVerificacion = false;
      unico = true;
    });
    // Enviar email de verificación
    final emailEnviado = await sendEmail(
      email: email,
      time: DateTime.now().toString(),
      nombrePadre: nombrePadre,
      nombreNino: nombreNino,
    );
    iniciarTimerConProgreso();
    if (!emailEnviado) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el email de verificación.'),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Cambiar a estado de espera de verificación
    setState(() {
      _isLoading = false;
      _esperandoVerificacion = true;
    });
  }

  Future<void> completarRegistro({
    required String email,
    required String password,
    required String nombreNino,
    required String nombrePadre,
  }) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      final uid = authResponse.user!.id;

      await supabase.from('Users').insert({
        'UID': uid,
        'miniUser': nombreNino,
        'User': nombrePadre,
        'email': email,
        'contra': password,
      });
      try {
        await storage.guardarCodigo(uid);
        await storage.guardarnNombre(nombreNino);
      } catch (e) {
        print("Error al guardar el código localmente: $e");
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );
      detenerTimers();
      clearFields();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de autenticación: ${e.message}')),
      );
      detenerTimers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
      detenerTimers();
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _esperandoVerificacion = false;
        unico = false; // Reiniciar el estado de único
      });
    }
  }

  bool Restricciones({
    required TextEditingController nombreDelUsuario,
    required TextEditingController nombreDelPadre,
    required TextEditingController email,
    required TextEditingController passwordRecuperacion,
  }) {
    final emailTexto = email.text.trim();
    final nombreUsuarioTexto = nombreDelUsuario.text.trim();
    final nombrePadreTexto = nombreDelPadre.text.trim();
    final passwordTexto = passwordRecuperacion.text.trim();

    if (nombreUsuarioTexto.isEmpty ||
        nombrePadreTexto.isEmpty ||
        emailTexto.isEmpty ||
        passwordTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, completa todos los campos correctamente.',
          ),
        ),
      );
      return false; // Algún campo está vacío
    }

    if (!emailTexto.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Por favor, ingresa un correo con terminación @gmail.com',
        ),
      ));
      return false;
    }

    if (passwordTexto.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Por favor, ingresa una contraseña de al menos 6 caracteres',
        ),
      ));
      return false; // La contraseña es menor a 6 caracteres
    }
    // Validar formato de email: al menos 6 caracteres antes de @gmail.com
    if (!emailTexto.endsWith('@gmail.com') ||
        emailTexto.split('@')[0].length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El correo debe tener al menos 6 caracteres antes de @gmail.com',
          ),
        ),
      );
      return false;
    }
    return true; // Todo ok
  }

  void clearFields() {
    nombreDelUsuario.clear();
    nombreDelPadre.clear();
    _email.clear();
    passwordRecuperacion.clear();
    codigoVerificacion.clear();
    setState(() {
      _codigoVerificacion = '';
      _isLoading = false; // Reiniciar el estado de carga
    });
  }

  final serviceId = 'service_g6gjsb5';
  final templateId = 'template_fpjdbbl';
  final userId = 'ZrikpMYZA23QTtkjP';

  String _codigoVerificacion = '';
  Future<bool> sendEmail({
    required String email,
    required String time,
    required String nombrePadre,
    required String nombreNino,
  }) async {
    try {
      final random = Random();
      setState(() {
        _codigoVerificacion = (100000 + random.nextInt(900000)).toString();
      });
      print('Código de verificación generado: $_codigoVerificacion');

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_email': email,
            'time': time,
            'name_father': nombrePadre,
            'user': nombreNino,
            'verification_code': _codigoVerificacion,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Email enviado correctamente');
        return true;
      } else {
        print('Error al enviar el email: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Excepción al enviar email: $e');
      return false;
    }
  }

  Future<bool> verificacion() async {
    if (!mounted) return false;
    String codigo = codigoVerificacion.text.trim();
    return codigo.isNotEmpty && codigo == _codigoVerificacion;
  }

  int _segundosRestantes = 0;
  Timer? _timerProgreso;
  Timer? _timerCodigo;

  void iniciarTimerConProgreso() {
    int segundosRestantes = 45;
    int segundosCodigo = 900;

    if (!mounted) return;

    _timerProgreso = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("Faltan $segundosRestantes segundos");

      segundosRestantes--;
      setState(() {
        _segundosRestantes = segundosRestantes;
      });

      if (segundosRestantes < 0) {
        timer.cancel();
        print("¡Timer terminado!");
        setState(() {
          unico = false;
        });
      }
    });

    _timerCodigo = Timer.periodic(const Duration(seconds: 1), (timer) {
      print("Faltan $segundosCodigo segundos reinicio codigo");

      segundosCodigo--;

      if (segundosCodigo < 0) {
        timer.cancel();
        print("¡Timer terminado Código!");
        setState(() {
          _codigoVerificacion = '';
        });
      }
    });
  }

  void detenerTimers() {
    if (_timerProgreso != null && _timerProgreso!.isActive) {
      _timerProgreso!.cancel();
      print("Timer de progreso detenido manualmente");
    }

    if (_timerCodigo != null && _timerCodigo!.isActive) {
      _timerCodigo!.cancel();
      print("Timer de código detenido manualmente");
    }
    setState(() {
      unico = false; // Reiniciar el estado de único
    });
  }
}
