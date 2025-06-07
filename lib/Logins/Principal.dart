import 'package:flutter/material.dart';
import 'package:kids_apps2/Logins/guardadolocal.dart';
import 'package:kids_apps2/Logins/loginRegistro.dart';
import 'package:kids_apps2/mainView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  final storage = CodigoLocalService();
  final supabase = Supabase.instance.client;

  final TextEditingController _correo = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _miniUser = '';
  bool _isLogin = false;
  @override
  void initState() {
    super.initState();
    main();
  }

  void main() async {
    String mini = await storage.obtenerNombre() ?? '';
    setState(() {
      _miniUser = mini;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        toolbarHeight: 70,
        title: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20, // Reducido desde 36
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        blurRadius: 0,
                        color: Colors.white,
                        offset: Offset(-1.5, -1.5)),
                    Shadow(
                        blurRadius: 0,
                        color: Colors.white,
                        offset: Offset(1.5, -1.5)),
                    Shadow(
                        blurRadius: 0,
                        color: Colors.white,
                        offset: Offset(1.5, 1.5)),
                    Shadow(
                        blurRadius: 0,
                        color: Colors.white,
                        offset: Offset(-1.5, 1.5)),
                    Shadow(
                        blurRadius: 4,
                        color: Colors.black45,
                        offset: Offset(2, 2)),
                  ],
                ),
                children: [
                  TextSpan(text: 'LEER ', style: TextStyle(color: Colors.blue)),
                  TextSpan(
                      text: 'y\n',
                      style: TextStyle(color: Colors.green, fontSize: 18)),
                  TextSpan(text: 'SUMAR', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_search_sharp,
              color: Colors.white, // Cambia el color aquí
            ),
            onPressed: () async {
              buscarUsuario(context);
            },
          ),
        ],
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
            color: Colors.black.withOpacity(0.6),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Bienvenido(a) $_miniUser!',
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 220,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        String UID = await storage.obtenerCodigo() ?? '';
                        String NOMBRE = await storage.obtenerNombre() ?? '';
                        if (!UID.isEmpty && !NOMBRE.isEmpty) {
                          inicio();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No se encontró el usuario en el dispositivo')),
                          );
                          setState(() {
                            _isLogin = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text(
                        'Comenzar',
                        style: TextStyle(fontSize: 24),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Loginregistro()),
                      );
                    },
                    child: Text(
                      '¿No tienes una cuenta? ¡Regístrate ahora!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLogin == true)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<dynamic> buscarUsuario(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple.shade400.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Buscar Usuario',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(_correo, 'Ingrese su correo registrado'),
              const SizedBox(height: 20),
              _buildInputField(_password, 'Ingrese su contraseña registrada',
                  obscure: true),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  cambiousuario(_correo.text.trim(), _password.text.trim());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.search),
                label: const Text('Buscar', style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orangeAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void cambiousuario(String email, String password) async {
    final response = await supabase
        .from('Users') // tu tabla, ajusta el nombre si es diferente
        .select('miniUser, UID') // columnas que quieres obtener
        .eq('email', email) // filtro por email
        .eq('contra', password)
        .limit(1)
        .maybeSingle();
    if (response != null) {
      final uid = response['UID'];
      final miniUser = response['miniUser'];

      try {
        await storage.guardarCodigo(uid);
        await storage.guardarnNombre(miniUser);
      } catch (e) {
        print("Error al cambiar el código localmente: $e");
      }
      setState(() {
        _miniUser = miniUser;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Usuario no encontrado o credenciales incorrectas')),
      );
      print('Usuario no encontrado o credenciales incorrectas');
    }
  }

  void inicio() async {
    if (!mounted) return;
    setState(() {
      _isLogin = true;
    });
    String UID = await storage.obtenerCodigo() ?? '';
    String NOMBRE = await storage.obtenerNombre() ?? '';
    if (UID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se encontró el usuario en el dispositivo')),
      );
      return;
    }
    final response = await supabase
        .from('Users') // tu tabla, ajusta el nombre si es diferente
        .select('UID,miniUser') // columnas que quieres obtener
        .eq('UID', UID) // filtro por email
        .limit(1)
        .maybeSingle();

    if (response != null) {
      final uid = response['UID'];
      setState(() {
        _miniUser = response['miniUser'];
      });
      if (uid == UID && _miniUser == NOMBRE) {
        final response = await supabase
            .from('Users') // tu tabla, ajusta el nombre si es diferente
            .select('email, contra') // columnas que quieres obtener
            .eq('UID', uid) // filtro por email
            .limit(1)
            .maybeSingle();
        if (response != null) {
          final contra = response['contra'];
          final email = response['email'];
          final authResponse =
              await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: contra,
          );

          if (authResponse.user != null) {
            print('Inicio de sesión exitoso con UID: ${authResponse.user!.id}');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ActivitiesScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al iniciar sesión')),
            );
          }
        }
      }
    }
  }
}
