import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:technoo/Pages/Login.dart'; // Asegúrate de importar correctamente tu página de inicio de sesión

class RecoverPass extends StatefulWidget {
  const RecoverPass({Key? key}) : super(key: key);

  @override
  State<RecoverPass> createState() => _RecoverPassState();
}

class _RecoverPassState extends State<RecoverPass> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tempCodeController = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController contran = TextEditingController();
  TextEditingController confirmarcontra = TextEditingController();
  bool _showPassword = false;

  bool _showPassword2 = false;

  String _tempCode = '';
  Timer? _timer;
  int _seconds = 60;

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
      });
      if (_seconds == 0) {
        _timer?.cancel();
      }
    });
  }

  // Alertas
  void _showDialog(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (BuildContext) => MyHomePage()),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    String messageToShow = errorMessage;
    if (errorMessage.contains("Connection failed")) {
      messageToShow = "Error de conexión. La contraseña no se pudo actualizar.";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(messageToShow),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /* void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }*/

  // Función para enviar los datos de recuperación
  Future<void> enviarDatosRecuperacion(String correo, String contran) async {
    try {
      // Primero verifica si el correo está registrado en la base de datos
      //var existe = await verificarExistenciaCorreo(correo);

      //if (!existe) {
      // Si el correo no está registrado, muestra una alerta y detén el proceso
      //_showErrorDialog('El correo electrónico no está registrado.');
      //return;
      //}
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/updatePass";

      var response = await http.post(
        Uri.parse(url),
        body: {
          'correo': correo,
          'pass': contran,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext) => MyHomePage()),
        );
        _showDialog('', 'Contraseña actualizada exitosamente', true);
      } else {
        if (responseBody['message'] ==
            'El correo electrónico no está registrado.') {
          _showErrorDialog('El correo electrónico no está registrado.');
        } else {
          _showErrorDialog(responseBody['message']);
        }
        _showErrorDialog(responseBody['message']);
      }
    } catch (e) {
      _showErrorDialog(
          'Error de conexión, la contraseña no se pudo actualizar');
    }
  }

// Función para verificar si el correo existe en la base de datos
  Future<bool> verificarExistenciaCorreo(String correo) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/existsCorreo";

      var response = await http.post(
        Uri.parse(url),
        body: {'correo': correo},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      Map<String, dynamic> responseBody = jsonDecode(response.body);
      return responseBody['exists'];
    } catch (e) {
      print('Error al verificar la existencia del correo: $e');
      return false; // En caso de error, asumimos que el correo no existe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Recuperar Contraseña",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            /*  Image.asset(
              'assets/linea.png',
              width: 120,
              height: 50,
            ),*/
            SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: correo,
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
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contran,
                obscureText: !_showPassword, // Para ocultar la contraseña
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Nueva Contraseña',
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
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: confirmarcontra,
                obscureText: !_showPassword2, // Para ocultar la contraseña
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'confirmar contraseña',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword2
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showPassword2 = !_showPassword2;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (correo.text.isNotEmpty &&
                    contran.text.isNotEmpty &&
                    confirmarcontra.text.isNotEmpty) {
                  if (contran.text == confirmarcontra.text) {
                    enviarDatosRecuperacion(correo.text, contran.text);
                  } else {
                    _showDialog('Error', 'Las contraseñas no coinciden', false);
                  }
                } else {
                  _showDialog(
                      'Error', 'Por favor, completa todos los campos', false);
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Actualizar Contraseña',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
