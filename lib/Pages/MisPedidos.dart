import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MisPedidos extends StatefulWidget {
  @override
  _MisPedidosState createState() => _MisPedidosState();
}

class _MisPedidosState extends State<MisPedidos> {
  List<dynamic> _productos = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  String? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();

    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');

    if (id != null) {
      // await obtenerDatosUsuario('', id); // Llama a la función
    } else {
      print('ID no encontrado en SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
