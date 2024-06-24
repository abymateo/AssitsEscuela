import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:technoo/Pages/Asistencia.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SeccionesPage extends StatelessWidget {
  SeccionesPage({Key? key}) : super(key: key) {
    _getUserInfo(); // Llama a _getUserInfo en el constructor
  }

  String _loggedInUser = ''; // Variable para almacenar el usuario logueado
  int? _userId;
  bool horaComida = false;
  bool horaSalida = false; // Variable para almacenar el ID del usuario

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? correo = prefs.getString('username');
    int? id = prefs.getInt('id');
    print('Correo en SharedPreferences: $correo');
    print('ID en SharedPreferences: $id');

    if (correo != null && id != null) {
      _loggedInUser = 'Usuario: $correo';
      _userId = id; // Asignar el valor de id a _userId
    }
  }

  Future<void> _showAlertDialog(String message, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Cierra el indicador de carga
              },
            ),
          ],
        );
      },
    );
  }

  // Función que registra la hora de la comida
  Future<void> registroComida(bool horaComida, BuildContext context) async {
    try {
      if (_userId != null) {
        print(
            'Enviando solicitud con los siguientes parámetros para registrar hora de comida');

        var url =
            "https://www.kolibri-apps.com/assists/webservice/Empleados/registrarComida";

        // Muestra el indicador de carga mientras se procesa la solicitud
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        var response = await http.post(Uri.parse(url), body: {
          'idEm': _userId.toString(),
          'Comida': horaComida ? '1' : '0',
        }).timeout(const Duration(seconds: 90));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> userData = json.decode(response.body);
          print('UserData: $userData');

          // Mostrar mensaje de éxito o error
          _showAlertDialog(
              userData['mensaje'], context); // Pasa el contexto al AlertDialog
        } else {
          _showAlertDialog(
              'Error al iniciar hora de comida: ${response.body}', context);
        }
      } else {
        _showAlertDialog('No se encontró ID de usuario.', context);
      }
    } on TimeoutException catch (e) {
      print("La solicitud tardó mucho en cargar");
    } on Error catch (e) {
      print("Error durante la solicitud");
    }
  }

  // Función que registra la hora de salida
  Future<void> registroSalida(bool horaSalida, BuildContext context) async {
    try {
      if (_userId != null) {
        print(
            'Enviando solicitud con los siguientes parámetros para registrar hora de salida');
        print('hora de salida: $horaSalida');
        var url =
            "https://www.kolibri-apps.com/assists/webservice/Empleados/registrarSalida";
        // Muestra el indicador de carga mientras se procesa la solicitud
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        var response = await http.post(Uri.parse(url), body: {
          'idEm': _userId.toString(),
          'HoraSalida': horaSalida ? '1' : '0',
        }).timeout(const Duration(seconds: 90));

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> userData = json.decode(response.body);
          print('UserData: $userData');

          // Mostrar mensaje de éxito o error
          _showAlertDialog(
              userData['mensaje'], context); // Pasa el contexto al AlertDialog
        } else {
          _showAlertDialog(
              'Error al registrar hora de salida ${response.body}', context);
        }
      } else {
        _showAlertDialog('No se encontró ID de usuario.', context);
      }
    } on TimeoutException catch (e) {
      print("La solicitud tardó mucho en cargar");
    } on Error catch (e) {
      print("Error durante la solicitud");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Forzar orientación a retrato
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 3),
            Center(
              child: Text(
                'Assist',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
            SizedBox(height: 20),
            _CustomCard(
              title: 'Entrada',
              subtitle: 'Presiona para hacer tu check de entrada',
              imageUrl:
                  'https://www.kolibri-apps.com/assists/app/static/img_flutter_app/entrada.jpeg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Asistencia()),
                );
              },
            ),
            _CustomCard(
              title: 'Comida',
              subtitle: 'Presiona para registrar tu hora de comida',
              imageUrl:
                  'https://www.kolibri-apps.com/assists/app/static/img_flutter_app/comida.jpeg',
              onTap: () {
                registroComida(
                    true, context); // Cambia true/false según sea necesario
              },
            ),
            _CustomCard(
              title: 'Salida',
              subtitle: 'Presiona para hacer tu check de salida',
              imageUrl:
                  'https://www.kolibri-apps.com/assists/app/static/img_flutter_app/salida.jpeg',
              onTap: () {
                registroSalida(
                    true, context); // Cambia true/false según sea necesario
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const _CustomCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
