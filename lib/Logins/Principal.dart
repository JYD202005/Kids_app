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
          title: const Text('Bienvenido a Sumar y Leer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_search_sharp),
              onPressed: () async {
                buscarUsuario(context);
              },
            ),
          ],
        ),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gifs/field3.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // Fondo oscuro
          ),
          Center(
            child: SingleChildScrollView(
              controller: ScrollController(),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Iniciar Sección',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '!Bienvenidoa ${_miniUser}!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      height: 60,
                      child: TextButton.icon(
                          onPressed: () {
                            inicio();
                          },
                          label: Text('Comenzar',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24)),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          )),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Loginregistro(),
                          ),
                        );
                      },
                      child: Center(
                        child:
                            Text("¿No Tienes Una Cuenta?, !Registrate Ahora!",
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLogin == true)
            Container(
              color: Colors.black87.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.orangeAccent[700]!),
                ),
              ),
            )
        ]));
  }

  Future<dynamic> buscarUsuario(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Buscar Usuario',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
            backgroundColor: Colors.indigo.withOpacity(0.8),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _correo,
                  decoration: InputDecoration(
                    labelText: 'Ingrese su correo registrado',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orangeAccent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: 'Ingrese su contraseña registrada',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.orangeAccent,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                    onPressed: () {
                      cambiousuario(_correo.text.trim(), _password.text.trim());

                      Navigator.pop(
                          context); // Cierra el diálogo después de buscar
                    },
                    label: const Text('Buscar',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
                    icon: const Icon(Icons.search, color: Colors.white),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    )),
              ],
            ),
          );
        });
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
