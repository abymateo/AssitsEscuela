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
  List<dynamic> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');

    if (id != null) {
      await _fetchPedidos(id); // Llama a la función para obtener los pedidos
    } else {
      print('ID no encontrado en SharedPreferences');
    }
  }

  Future<void> _fetchPedidos(int id) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/getPedidosPorEmpleado";
      var body = jsonEncode({'idEm': id.toString()});
      print('Request Body: $body'); // Debugging line

      var response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Body: ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['res']) {
          setState(() {
            _pedidos = data['data'];
            _isLoading = false;
          });
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Error al obtener pedidos: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error al obtener pedidos: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
      ),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga
          : _pedidos.isEmpty
              ? Center(
                  child: Text(
                      'No hay pedidos disponibles.')) // Mensaje si no hay pedidos
              : ListView.builder(
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) {
                    var pedido = _pedidos[index];
                    return ListTile(
                      title: Text(pedido['nombre_producto']),
                      subtitle: Text('Cantidad: ${pedido['cantidad']}'),
                      trailing: Text('Folio: ${pedido['folio']}'),
                    );
                  },
                ),
    );
  }
}
