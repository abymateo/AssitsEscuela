import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

//import 'user_info.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technoo/Pages/RecoverPass.dart';

import 'package:technoo/RegistroPage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:technoo/Pages/ChangePasswordScreen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;
  final Permission permissionLocation = Permission.location;
  final Permission permissionCamera = Permission.camera;
  final Permission permissionStorage = Permission.storage;

//funcion para que llame a las dos funciones cuando presione el boton de ingresar
  void _loginAndCheckPermission() {
    _login();
    locationPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                "Inicio de sesión",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset(
                'assets/linea.png',
                width: 120,
                height: 50,
              ),
              SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Correo Electrónico',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Contraseña',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                    activeColor: Color(0xFF0094F8),
                  ),
                  Text(
                    'Recordarme',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginAndCheckPermission,
                  child: Text(
                    'Ingresar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF0094F8),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              //recuperar contraseña
              Container(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // builder: (context) => RecoverPass()),
                              builder: (context) => ChangePasswordScreen()),
                        );
                        // Acción al presionar el texto de registro
                        // Navegar a la pantalla de registro
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFF0094F8),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No tienes cuenta? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //  cameraPermissionStatus();
                      //     storagePermissionStatus();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistroPage()),
                      );
                      // Acción al presionar el texto de registro
                      // Navegar a la pantalla de registro
                    },
                    child: Text(
                      'Registrarme',
                      style: TextStyle(
                        color: Color(0xFF0094F8),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Obtener la ubicación al inicio
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? apellidopa = prefs.getString('apellidoPaterno');
    String? apellidoma = prefs.getString('apellidoMaterno');
    if (username != null && username.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/Home');
    }
  }

//pemisos de localización
  void locationPermissionStatus() async {
    // Request location permission
    final status = await permissionLocation.request();
    if (status == PermissionStatus.granted) {
      // Get the current location
      final position = await Geolocator.getCurrentPosition();
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    } else {
      // Permission denied
      print('Location permission denied.');
    }
  }

//para permisos de archivos

  void storagePermissionStatus() async {
    // Solicitar permiso de almacenamiento
    final storageStatus = await permissionStorage.request();

    if (storageStatus.isGranted) {
      // Permiso de almacenamiento concedido
      print('Permiso de almacenamiento concedido.');
      // Puedes acceder a archivos aquí si es necesario
    } else {
      // Permiso de almacenamiento denegado
      print('Permiso de almacenamiento denegado.');
    }
  }

  //permisos para la camara
  void cameraPermissionStatus() async {
    // Request camera permission
    final status = await permissionCamera.request();
    if (status.isGranted) {
      // Open the camera
      print('Opening camera...');
    } else {
      // Permission denied
      print('Camera permission denied.');
    }
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/existsEmpleadoo";
      var response = await http.post(Uri.parse(url), body: {
        'correo': username,
        'pass': md5.convert(utf8.encode(password)).toString(),
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['res']) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //estos datos los extrae de la base de datos, los almacena en una varible en shared preferences
          print("Datoss: $data");
          // Guardar el nombre de usuario
          String nombreUsuario = data['user']['nombre'];
          prefs.setString('username', nombreUsuario);
          print("Nombre de usuario: $nombreUsuario");

          // Guardar el apellido paterno del usuario
          String apellidoPaterno = data['user']['apellidop'];
          prefs.setString('apellidoPaterno', apellidoPaterno);
          print("Apellido Paterno: $apellidoPaterno");

          // Guardar el apellido materno del usuario
          String apellidoMaterno = data['user']['apellidom'];
          prefs.setString('apellidoMaterno', apellidoMaterno);
          print("Apellido Materno: $apellidoMaterno");

          // Guardar el correo electrónico del usuario
          String correoElectronico = data['user']['correo'];
          prefs.setString('email', correoElectronico);
          print("Correo Electrónico: $correoElectronico");

          // Guardar el ID de usuario
          int idUsuario = int.parse(data['user']['idEm']);
          prefs.setInt('id', idUsuario);
          print("ID de usuario: $idUsuario");

          // Guardar el correo electrónico del usuario
          String foto = data['user']['foto'];
          prefs.setString('foto', foto);
          print("foto: $foto");

          Navigator.pushReplacementNamed(context, '/Home');
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Credenciales Invalidas'),
                content: Text('La credenciales proporcionadas no son válidas'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        print("HTTP Request Error: ${response.statusCode}");
      }
    } catch (e) {
      print("HTTP Request Error: $e");
    }
  }
}
