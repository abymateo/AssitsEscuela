import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:technoo/Pages/Login.dart';
import 'package:technoo/Pages/attendance.dart'; // Importa el archivo attendance.dart
import 'package:technoo/Pages/settings.dart'; // Importa el archivo settings.dart
import 'package:technoo/Pages/Encuesta.dart'; // Importa el archivo Encuesta.dart

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _center = LatLng(0, 0); // Valor predeterminado

  Marker? _currentLocationMarker;

  String _locationMessage = '';
  String _loggedInUser = '';
  int _selectedIndex = 0;
  int? _userId;

  bool _alertShown = false; // Bandera para controlar si la alerta ya se mostró

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo(); // Obtener la información del usuario
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _currentLocationMarker = Marker(
        markerId: MarkerId('current_location'),
        position: _center,
        infoWindow: InfoWindow(title: 'Tu ubicación actual'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    int? id = prefs.getInt('id');
    if (username != null && username.isNotEmpty) {
      setState(() {
        _loggedInUser = username;
        _userId = id; // Establecer el ID de usuario obtenido
      });
      _checkLastAttendance(); // Llamar a la verificación de asistencia después de obtener el ID
    } else {
      print('No se encontró información de usuario en SharedPreferences');
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return SeccionesPage();
      case 2:
        return SettingsPage();
      default:
        return Container();
    }
  }

  Widget _buildHomePage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _loggedInUser,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_center.latitude == 0 && _center.longitude == 0)
              CircularProgressIndicator(),
            if (_center.latitude != 0 && _center.longitude != 0)
              Container(
                height: 670,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 18.0,
                  ),
                  markers: {
                    if (_currentLocationMarker != null) _currentLocationMarker!,
                  },
                  zoomControlsEnabled: true,
                  mapType: MapType.hybrid,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLastAttendance() async {
    if (_userId == null) {
      print('Usuario no identificado');
      return;
    }

    final url =
        'https://www.kolibri-apps.com/assists/webservice/Empleados/get_ultima_asistencia';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'idEm': _userId.toString(),
        },
      );

      final responseBody = json.decode(response.body);
      print(responseBody); // Imprimir la respuesta para depurar

      if (responseBody['status'] == true) {
        String lastAttendance = responseBody['last_attendance'];
        DateTime lastDate =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(lastAttendance);
        DateTime currentDate = DateTime.now();

        print('Fecha actual: $currentDate');
        print('Última asistencia: $lastDate');

        if (currentDate.difference(lastDate).inDays >= 3 && !_alertShown) {
          print('Mostrar alerta');
          _showAlert();
        } else {
          print('No es necesario mostrar alerta');
        }
      } else {
        print(responseBody['message']);
      }
    } catch (e) {
      print('Error al verificar la asistencia: $e');
    }
  }

  void _showAlert() {
    print('Mostrando alerta');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta de Asistencia'),
          content: Text(
            'No has registrado asistencia en los últimos 3 días. Por favor, responde el cuestionario.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EncuestaPage()),
                );
                // Guardar en SharedPreferences que la alerta ya se mostró
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('alertShown', true);
                setState(() {
                  _alertShown = true; // Actualizar la bandera local
                });
              },
              child: const Text('Ir'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Marcar la alerta como completada en SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('alertShown', true);
                setState(() {
                  _alertShown = true; // Actualizar la bandera local
                });
              },
              child: const Text('Ya lo realicé'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home, size: 20),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.clipboardCheck, size: 20),
            label: 'Asistencia',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.cogs, size: 20),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
