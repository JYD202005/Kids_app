import 'package:shared_preferences/shared_preferences.dart';

class CodigoLocalService {
  static const String _clave = 'c';
  static const String _nombre = 'n';

  /// Guarda el código
  Future<void> guardarCodigo(String codigo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, codigo);
    print('Código guardado localmente: $codigo');
  }

  /// Obtiene el código
  Future<String?> obtenerCodigo() async {
    final prefs = await SharedPreferences.getInstance();
    print('Código obtenido localmente: $_clave');
    return prefs.getString(_clave);
  }

  /// Borra el código
  Future<void> borrarCodigo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }

  /// Guarda el código
  Future<void> guardarnNombre(String nombre) async {
    final prefs2 = await SharedPreferences.getInstance();
    await prefs2.setString(_nombre, nombre);
    print('Nombre guardado localmente: $nombre');
  }

  /// Obtiene el código
  Future<String?> obtenerNombre() async {
    final prefs2 = await SharedPreferences.getInstance();
    print('Nombre obtenido localmente: $_nombre');
    return prefs2.getString(_nombre);
  }

  /// Borra el código
  Future<void> borrarNombre() async {
    final prefs2 = await SharedPreferences.getInstance();
    await prefs2.remove(_nombre);
  }
}
