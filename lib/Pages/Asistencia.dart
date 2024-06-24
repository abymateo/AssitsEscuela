import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class Asistencia extends StatefulWidget {
  @override
  _AsistenciaState createState() => _AsistenciaState();
}

class _AsistenciaState extends State<Asistencia> {
  String _locationMessage = '';
  String _loggedInUser = '';
  double _currentLatitud = 0.0;
  double _currentLongitud = 0.0;
  TextEditingController comentarioController = TextEditingController();
  int? _userId;
  bool buttonPressed = false;
  ButtonState stateTextWithIcon = ButtonState.idle;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? correo = prefs.getString('username');
    String? apellidopa = prefs.getString('apellidoPaterno');
    String? apellidoma = prefs.getString('apellidoMaterno');
    int? id = prefs.getInt('id');
    print('Correo en SharedPreferences: $correo');
    print('ID en SharedPreferences: $id');

    if (correo != null && id != null) {
      setState(() {
        _loggedInUser = 'Usuario: $correo $apellidopa $apellidoma';
        _userId = id; // Asignar el valor de id a _userId
      });
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLatitud = position.latitude;
        _currentLongitud = position.longitude;
        _locationMessage =
            'Latitude: $_currentLatitud, Longitude: $_currentLongitud';
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _showAlertDialog(String message) async {
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> validaCoordenadas(
      int id, double _currentLatitud, double _currentLongitud) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/validarCoordenadas";

      var response = await http.post(Uri.parse(url), body: {
        'idEm': id.toString(),
        'lon': _currentLongitud.toString(),
        'lat': _currentLatitud.toString(),
      }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);

        if (userData['mensaje'] == 'Las coordenadas coinciden.') {
          // Coordenadas válidas, procede a enviar la asistencia
          await realizaAsistencia(
              id, _currentLatitud, _currentLongitud, comentarioController.text);
        } else {
          setState(() {
            buttonPressed = false;
            stateTextWithIcon = ButtonState.fail;
          });
          _showAlertDialog(
              'Error al realizar la asistencia: ${userData['mensaje']}');
        }
      } else {
        setState(() {
          buttonPressed = false;
          stateTextWithIcon = ButtonState.fail;
        });
        _showAlertDialog('Error al realizar la asistencia: ${response.body}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        buttonPressed = false;
        stateTextWithIcon = ButtonState.fail;
      });
      _showAlertDialog('La solicitud tardó mucho en cargar');
    } on Error catch (e) {
      setState(() {
        buttonPressed = false;
        stateTextWithIcon = ButtonState.fail;
      });
      _showAlertDialog('Error durante la solicitud');
    }
  }

  Future<void> realizaAsistencia(int id, double _currentLatitud,
      double _currentLongitud, String comentario) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/asistencia";

      var response = await http.post(Uri.parse(url), body: {
        'idEm': id.toString(),
        'lon': _currentLongitud.toString(),
        'lat': _currentLatitud.toString(),
        'comentario': comentario,
      }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);

        if (userData['mensaje'] == 'Asistencia registrada exitosamente.') {
          setState(() {
            print('Cambiando estado del botón...');

            buttonPressed = false;
            stateTextWithIcon = ButtonState.success;
          });

          _showAlertDialog('Asistencia registrada exitosamente.');
          setState(() {}); // Forzar la actualización del widget
        } else if (userData['mensaje'] ==
            'Ya se realizo la asistencia para hoy.') {
          setState(() {
            buttonPressed = false;
            stateTextWithIcon = ButtonState.fail;
          });
          _showAlertDialog('Error, Ya se realizo la asistencia para hoy!!');
        } else {
          setState(() {
            buttonPressed = false;
            stateTextWithIcon = ButtonState.fail;
          });
          _showAlertDialog(userData['mensaje']);
        }
      } else {
        setState(() {
          buttonPressed = false;
          stateTextWithIcon = ButtonState.fail;
        });
        Map<String, dynamic> errorData = json.decode(response.body);
        _showAlertDialog(
            'Error al realizar la asistencia: ${errorData['mensaje']}');
      }
    } on TimeoutException catch (e) {
      setState(() {
        buttonPressed = false;
        stateTextWithIcon = ButtonState.fail;
      });
      _showAlertDialog('La solicitud tardó mucho en cargar');
    } on Error catch (e) {
      setState(() {
        buttonPressed = false;
        stateTextWithIcon = ButtonState.fail;
      });
      _showAlertDialog('Error durante la solicitud');
    } finally {
      setState(() {
        buttonPressed = false;
        stateTextWithIcon = ButtonState.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            _loggedInUser,
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: comentarioController,
              decoration: InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'Ingrese un comentario',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int? id = prefs.getInt('id');
              if (id != null) {
                if (!buttonPressed) {
                  setState(() {
                    buttonPressed = true;
                    stateTextWithIcon = ButtonState.loading;
                  });
                  await _getLocation();
                  validaCoordenadas(id, _currentLatitud, _currentLongitud);
                }
              } else {
                _showAlertDialog('No se encontró ID de usuario.');
              }
            },
            style: ElevatedButton.styleFrom(
              elevation:
                  0, // Establece la elevación a 0 para eliminar el sombreado
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: buttonPressed ? 0.5 : 1.0,
                  child: ProgressButton.icon(
                    iconedButtons: {
                      ButtonState.idle: const IconedButton(
                        text: 'Enviar',
                        icon: Icon(Icons.send, color: Colors.white),
                        color: Colors.blue,
                      ),
                      ButtonState.loading: const IconedButton(
                        text: 'Cargando',
                        color: Colors.blue,
                      ),
                      ButtonState.fail: IconedButton(
                        text: 'Error',
                        icon: Icon(Icons.cancel, color: Colors.white),
                        color: Colors.red.shade300,
                      ),
                      ButtonState.success: IconedButton(
                        text: 'Enviado',
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        color: Colors.green.shade400,
                      ),
                    },
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      int? id = prefs.getInt('id');
                      if (id != null) {
                        if (!buttonPressed) {
                          setState(() {
                            buttonPressed = true;
                            stateTextWithIcon = ButtonState.loading;
                          });
                          await _getLocation();
                          validaCoordenadas(
                              id, _currentLatitud, _currentLongitud);
                        }
                      } else {
                        _showAlertDialog('No se encontró ID de usuario.');
                      }
                    },
                    state: stateTextWithIcon,
                  ),
                ),
                SizedBox(height: 20),
                buttonPressed ? const Text('') : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onPressedIconWithText() {
    setState(() {
      if (buttonPressed) {
        print(
            'Aqui ya lo presionaste aqui puedes manejar el mensaje como quieras');
        return;
      }

      buttonPressed = true;
      stateTextWithIcon = ButtonState.loading;
    });

    Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        stateTextWithIcon = ButtonState.success;
      });
    });
  }
}
