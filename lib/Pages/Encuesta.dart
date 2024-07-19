import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technoo/Pages/Home.dart';

class EncuestaPage extends StatefulWidget {
  const EncuestaPage({Key? key}) : super(key: key);

  @override
  State<EncuestaPage> createState() => _EncuestaPageState();
}

class _EncuestaPageState extends State<EncuestaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each question response
  String _respuesta1 = '';
  String _respuesta2 = '';
  String _respuesta3 = '';
  String _respuesta4 = '';
  String _respuesta5 = '';
  String _respuesta6 = '';
  String _respuesta7 = '';
  String _respuesta8 = '';

  // Valor por defecto para las respuestas
  String _defaultRespuesta = '';

  // Comentarios
  TextEditingController _comentariosController = TextEditingController();

  // Total de puntos
  int _total = 0;

  int? _userId;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? correo = prefs.getString('username');
    int? id = prefs.getInt('id');
    print('Correo en SharedPreferences: $correo');
    print('ID en SharedPreferences: $id');

    if (correo != null && id != null) {
      setState(() {
        _userId = id; // Asignar el valor de id a _userId
      });
    }
  }

  Future<void> insertarRespuestas() async {
    final String valorRespuesta1 = getValue(_respuesta1);
    final String valorRespuesta2 = getValue(_respuesta2);
    final String valorRespuesta3 = getValue(_respuesta3);
    final String valorRespuesta4 = getValue(_respuesta4);
    final String valorRespuesta5 = getValue(_respuesta5);
    final String valorRespuesta6 = getValue(_respuesta6);
    final String valorRespuesta7 = getValue(_respuesta7);
    final String valorRespuesta8 = getValue(_respuesta8);

    final String comentarios = _comentariosController.text;

    final url =
        'https://www.kolibri-apps.com/assists/webservice/Empleados/insertar_respuestas';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'idEm': _userId.toString(),
          'respuesta1': _respuesta1,
          'valor_respuesta1': valorRespuesta1,
          'respuesta2': _respuesta2,
          'valor_respuesta2': valorRespuesta2,
          'respuesta3': _respuesta3,
          'valor_respuesta3': valorRespuesta3,
          'respuesta4': _respuesta4,
          'valor_respuesta4': valorRespuesta4,
          'respuesta5': _respuesta5,
          'valor_respuesta5': valorRespuesta5,
          'respuesta6': _respuesta6,
          'valor_respuesta6': valorRespuesta6,
          'respuesta7': _respuesta7,
          'valor_respuesta7': valorRespuesta7,
          'respuesta8': _respuesta8,
          'valor_respuesta8': valorRespuesta8,
          'total': _total.toString(),
          'comentarios': comentarios,
        },
      );

      final responseBody = json.decode(response.body);
      if (responseBody['res'] == true) {
        _showDialog('Éxito', 'Respuestas insertadas correctamente.', true);
      } else {
        _showDialog('Error', responseBody['message']);
      }
    } catch (e) {
      _showDialog('Error', 'Error al insertar respuestas: $e');
    }
  }

  String getValue(String respuesta) {
    switch (respuesta.toLowerCase()) {
      case 'sí':
        return '1';
      case 'no':
        return '2';
      case 'tal vez':
        return '3';
      case 'bajo':
        return '1';
      case 'moderado':
        return '2';
      case 'alto':
        return '3';
      default:
        return '0';
    }
  }

  void _calculateTotal() {
    _total = int.parse(getValue(_respuesta1)) +
        int.parse(getValue(_respuesta2)) +
        int.parse(getValue(_respuesta3)) +
        int.parse(getValue(_respuesta4)) +
        int.parse(getValue(_respuesta5)) +
        int.parse(getValue(_respuesta6)) +
        int.parse(getValue(_respuesta7)) +
        int.parse(getValue(_respuesta8));
  }

  void _showDialog(String title, String message, [bool success = false]) {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
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

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuesta')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPreguntaField(
                  '¿Te sientes satisfecho con tu trabajo actual?',
                  (value) {
                    setState(() {
                      _respuesta1 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta1,
                ),
                _buildPreguntaField(
                  '¿Tienes claridad en tus responsabilidades diarias?',
                  (value) {
                    setState(() {
                      _respuesta2 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta2,
                ),
                _buildPreguntaField(
                  '¿Te sientes motivado en tu entorno laboral?',
                  (value) {
                    setState(() {
                      _respuesta3 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta3,
                ),
                _buildPreguntaField(
                  '¿Consideras que tienes oportunidades de crecimiento?',
                  (value) {
                    setState(() {
                      _respuesta4 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta4,
                ),
                _buildPreguntaField(
                  '¿Recibes apoyo suficiente de tus compañeros?',
                  (value) {
                    setState(() {
                      _respuesta5 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta5,
                ),
                _buildPreguntaField(
                  '¿Cuál es tu nivel de estrés actualmente?',
                  (value) {
                    setState(() {
                      _respuesta6 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta6,
                  opciones: ['bajo', 'moderado', 'alto'],
                ),
                _buildPreguntaField(
                  '¿Te sientes presionado en tu jornada laboral?',
                  (value) {
                    setState(() {
                      _respuesta7 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta7,
                ),
                _buildPreguntaField(
                  '¿Alguna vez has pensado en renunciar?',
                  (value) {
                    setState(() {
                      _respuesta8 = value ?? _defaultRespuesta;
                      _calculateTotal();
                    });
                  },
                  _respuesta8,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _comentariosController,
                    decoration: InputDecoration(
                      labelText: 'Nota (opcional)',
                      hintText: 'Ingrese un comentario',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  // Centra el botón en la pantalla
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _validateRespuestas()) {
                        insertarRespuestas();
                      } else {
                        _showDialog('Error',
                            'Por favor, responde todas las preguntas.');
                      }
                    },
                    child: Text(
                      '       Enviar      ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateRespuestas() {
    return _respuesta1.isNotEmpty &&
        _respuesta2.isNotEmpty &&
        _respuesta3.isNotEmpty &&
        _respuesta4.isNotEmpty &&
        _respuesta5.isNotEmpty &&
        _respuesta6.isNotEmpty &&
        _respuesta7.isNotEmpty &&
        _respuesta8.isNotEmpty;
  }

  Widget _buildPreguntaField(
    String pregunta,
    void Function(String?)? onChanged,
    String groupValue, {
    List<String> opciones = const ['sí', 'no', 'tal vez'],
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(pregunta, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: opciones.map((option) {
              return Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: groupValue,
                    onChanged:
                        onChanged != null ? (value) => onChanged(value) : null,
                  ),
                  Text(option),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
