import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Pedidos extends StatefulWidget {
  @override
  _PedidosState createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  List<dynamic> _productos = [];
  List<Map<String, dynamic>> _selectedProducts = [];
  String? _selectedProduct;
  final TextEditingController _quantityController = TextEditingController();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');

    if (id != null) {
      await obtenerDatosUsuario('', id); // Llama a la función
    } else {
      print('ID no encontrado en SharedPreferences');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/getAllProducts";
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['res']) {
          setState(() {
            _productos = data['data'];
          });
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error al obtener productos: $e');
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

  String? sucursalId; // Variable para almacenar el ID de la sucursal

  Future<void> obtenerDatosUsuario(String correo, int id) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/obtenerIdSucursal";

      var response = await http.post(Uri.parse(url), body: {
        'idEm': id.toString(),
      }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        if (userData['res']) {
          sucursalId = userData['data']['sucursal_id'];
          print('Sucursal ID obtenido: $sucursalId'); // Línea de depuración
        } else {
          print('Error al obtener sucursal: ${userData['message']}');
        }
      } else {
        print("Error en la solicitud a la API");
      }
    } catch (e) {
      print("Error durante la solicitud: $e");
    }
  }

//para verificar si hay almacen:
  Future<bool> verificarCantidadDisponibles() async {
    for (var producto in _selectedProducts) {
      var idProducto = producto['id_producto'];
      var cantidadSolicitada = int.parse(
          producto['cantidad'].toString()); // Asegúrate de que sea un entero

      // Busca el nombre del producto correspondiente en la lista de productos
      var productoEncontrado = _productos.firstWhere(
          (p) => p['id_producto'] == idProducto,
          orElse: () => null);
      var nombreProducto = productoEncontrado != null
          ? productoEncontrado['nombre']
          : 'Producto desconocido';

      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/verificarCantidad";

      var response = await http.post(Uri.parse(url), body: {
        'id_producto': idProducto.toString(),
        'cantidad': cantidadSolicitada.toString(),
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (!data['res'] ||
            (data['cantidad_disponible'] is String
                    ? int.parse(data['cantidad_disponible'])
                    : data['cantidad_disponible']) <
                cantidadSolicitada) {
          _showErrorDialog(
              'No hay suficiente cantidad del producto: $nombreProducto');
          return false; // Indica que no hay suficiente cantidad
        }
      } else {
        _showErrorDialog(
            'Error al verificar disponibilidad: ${response.statusCode}');
        return false;
      }
    }
    return true; // Indica que todas las cantidades están disponibles
  }

  Future<void> _submitPedido() async {
    if (_selectedProducts.isEmpty) {
      _showErrorDialog('No hay productos seleccionados.');
      return;
    }

    // Verificar la cantidad de productos disponibles
    bool haySuficientes = await verificarCantidadDisponibles();
    if (!haySuficientes) {
      return; // Si no hay suficientes, salimos de la función
    }
    // Imprimir el sucursalId para depuración
    print('ID de sucursal antes de enviar: $sucursalId');

    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/insertPedido";
      var response = await http.post(
        Uri.parse(url),
        body: jsonEncode(_selectedProducts),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['res']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          setState(() {
            _selectedProducts.clear();
          });
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error en la solicitud: $e');
    }
  }

  void _addProduct() {
    if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
      int cantidad = int.parse(_quantityController.text);
      if (sucursalId != null) {
        setState(() {
          _selectedProducts.add({
            'id_producto': _selectedProduct,
            'id_sucursal': sucursalId,
            'cantidad': cantidad,
          });
          _selectedProduct = null;
          _quantityController.clear();
        });
      } else {
        _showErrorDialog('ID de sucursal no disponible.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Selecciona un producto'),
              value: _selectedProduct,
              onChanged: (newValue) {
                setState(() {
                  _selectedProduct = newValue;
                });
              },
              items: _productos.map((producto) {
                return DropdownMenuItem<String>(
                  value: producto['id_producto'].toString(),
                  child: Text(producto['nombre']),
                );
              }).toList(),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ingrese la cantidad',
              ),
            ),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Agregar Producto'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  var producto = _selectedProducts[index];

                  // Encuentra el producto correspondiente en la lista de productos
                  var nombreProducto = _productos.firstWhere(
                    (prod) =>
                        prod['id_producto'].toString() ==
                        producto['id_producto'],
                    orElse: () => {
                      'nombre': 'Desconocido'
                    }, // Valor por defecto si no se encuentra
                  )['nombre'];

                  return ListTile(
                    title: Text(
                      'Producto: $nombreProducto - Cantidad: ${producto['cantidad']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _selectedProducts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            /*Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  var producto = _selectedProducts[index];
                  return ListTile(
                    title: Text(
                        'Producto ID: ${producto['id_producto']} - Cantidad: ${producto['cantidad']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _selectedProducts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),*/
          /*  ElevatedButton(
              onPressed: _selectedProducts.isEmpty ? null : _submitPedido,
              child: Text('Hacer Pedido'),
            ),*/


            
            ElevatedButton(
                  onPressed:  _selectedProducts.isEmpty ? null : _submitPedido,
                  child: Text(
                    'Hacer Pedido',
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
          ],
        ),
      ),
    );
  }
}
