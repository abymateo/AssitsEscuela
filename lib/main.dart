import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:technoo/Pages/Home.dart';

import 'package:technoo/Pages/Login.dart';
import 'package:technoo/Pages/attendance.dart'; // Importa el archivo attendance.dart
import 'package:technoo/Pages/settings.dart'; // Importa el archivo settings.dart

import 'package:technoo/Pages/Asistencia.dart';

//import 'home.dart';
//import 'user_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      ///title: 'Geolocator & Login Example',
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/Home': (context) => Home(),
        '/Asistencia': (context) => Asistencia(),
        '/attendance': (context) => SeccionesPage(),
        '/settings': (context) => const SettingsPage(),
        // '/userInfo': (context) => UserInfoScreen(),
      },
    );
  }
}
