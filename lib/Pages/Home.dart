import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:technoo/Pages/Login.dart';

import 'package:technoo/Pages/attendance.dart'; // Importa el archivo attendance.dart
import 'package:technoo/Pages/settings.dart'; // Importa el archivo settings.dart

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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();
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
    if (username != null && username.isNotEmpty) {
      setState(() {
        _loggedInUser = '';
      });
    }
  }

  /* Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }*/
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
        //return _buildHomePage();
        return SeccionesPage();
      case 2:
        // return _buildHomePage();
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
                // Cambia el tamaño del mapa aquí
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
                  zoomControlsEnabled: true, // Habilita los controles de zoom
                  mapType: MapType.hybrid, // Change to other map types
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

/*
  Widget _buildHomePage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido',
              style: TextStyle(
                color: Color.fromARGB(255, 57, 16, 133),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20), // Espacio entre el texto y el botón
            ElevatedButton(
              onPressed: () {
                // Acción para cerrar sesión
                _logout(context);
              },
              child: Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Color de fondo del botón
                onPrimary: Colors.white, // Color del texto del botón
              ),
            ),
          ],
        ),
      ),
    );
  }*/

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
