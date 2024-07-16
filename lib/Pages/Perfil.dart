import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technoo/Pages/Home.dart';
import 'package:technoo/Pages/settings.dart';

class Usuario {
  String nombre;
  String correo;
  String pass;
  String telefono;
  String apellidop;
  String apellidom;
  String calle;
  String colonia;
  String cp;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.pass,
    required this.apellidop,
    required this.apellidom,
    required this.telefono,
    required this.colonia,
    required this.calle,
    required this.cp,
  });
}

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _apellidopaController = TextEditingController();
  final TextEditingController _apellidomaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  bool _isTelefonoValid = true;
  bool _isCpValid = true;
  File? fotoFile;
  String selectedFotoFileName = 'Seleccionar Archivo';
  late Usuario _usuario;
  bool _hasChanges = false; // Bandera para controlar cambios

  @override
  void initState() {
    super.initState();
    _usuario = Usuario(
      nombre: '',
      correo: '',
      pass: '',
      apellidop: '',
      apellidom: '',
      telefono: '',
      colonia: '',
      calle: '',
      cp: '',
    );

    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? correo = prefs.getString('username');
    int? id = prefs.getInt('id');

    if (correo != null && id != null) {
      await obtenerDatosUsuario(correo, id);
      setState(() {
        _nombreController.text = _usuario.nombre;
        _correoController.text = _usuario.correo;
        _passController.text = _usuario.pass;
        _apellidomaController.text = _usuario.apellidom;
        _apellidopaController.text = _usuario.apellidop;
        _telefonoController.text = _usuario.telefono;
        _coloniaController.text = _usuario.colonia;
        _calleController.text = _usuario.calle;
        _cpController.text = _usuario.cp;
      });
    }
  }

/*Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nombreController.text = prefs.getString('username') ?? '';
    _apellidopaController.text = prefs.getString('apellidoPaterno') ?? '';
    _apellidomaController.text = prefs.getString('apellidoMaterno') ?? '';
    _correoController.text = prefs.getString('email') ?? '';
    //_pickFotoFile() = prefs.getString('foto') ?? '';
  }*/

  Future<void> _guardarDatosLocales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _nombreController.text);
    await prefs.setString('apellidoPaterno', _apellidopaController.text);
    await prefs.setString('apellidoMaterno', _apellidomaController.text);
    await prefs.setString('email', _correoController.text);
    //await prefs.setString('foto', _controllerFoto.text);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidopaController.dispose();
    _apellidomaController.dispose();
    _correoController.dispose();
    // _controllerFoto.dispose();
    super.dispose();
  }

  Future<void> obtenerDatosUsuario(String correo, int id) async {
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/getEmpleado";

      var response = await http.post(Uri.parse(url), body: {
        'idEm': id.toString(),
      }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);

        setState(() {
          _nombreController.text = userData['data']['nombre'] ?? '';
          _correoController.text = userData['data']['correo'] ?? '';
          _passController.text = userData['data']['pass'] ?? '';
          _apellidomaController.text = userData['data']['apellidom'] ?? '';
          _apellidopaController.text = userData['data']['apellidop'] ?? '';
          _telefonoController.text = userData['data']['telefono'] ?? '';
          _coloniaController.text = userData['data']['colonia'] ?? '';
          _calleController.text = userData['data']['calle'] ?? '';
          _cpController.text = userData['data']['cp'] ?? '';

          _usuario = Usuario(
            nombre: userData['data']['nombre'] ?? '',
            correo: userData['data']['correo'] ?? '',
            pass: userData['data']['pass'] ?? '',
            apellidom: userData['data']['apellidom'] ?? '',
            apellidop: userData['data']['apellidop'] ?? '',
            telefono: userData['data']['telefono'] ?? '',
            colonia: userData['data']['colonia'] ?? '',
            calle: userData['data']['calle'] ?? '',
            cp: userData['data']['cp'] ?? '',
          );
        });
      } else {
        print("Error en la solicitud a la API");
      }
    } on TimeoutException catch (e) {
      print("La solicitud tardó mucho en cargar");
    } on Error catch (e) {
      print("Error durante la solicitud");
    }
  }

  Future<void> updateLocalUserInfo(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', userData['nombre'] ?? '');
    await prefs.setString('apellidoPaterno', userData['apellidop'] ?? '');
    await prefs.setString('apellidoMaterno', userData['apellidom'] ?? '');
    await prefs.setString('email', userData['correo'] ?? '');
    // Guarda cualquier otra información relevante
  }

  void actualizarPerfil({
    required String nombre,
    required String correo,
    required String contra,
    required String apellidop,
    required String apellidoma,
    required String telefono,
    required String cp,
    required String colonia,
    required String calle,
    required File? fotoFile,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');

    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/updateEmpleado";

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
        'idEm': id.toString(),
        'nombre': nombre,
        'apellidop': apellidop,
        'apellidom': apellidoma,
        'telefono': telefono,
        'cp': cp,
        'colonia': colonia,
        'calle': calle,
        'correo': correo,
        'pass': contra,
      });

      if (fotoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("foto", fotoFile.path),
        );
      }
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response body: $responseString');

      try {
        Map<String, dynamic> responseBody = jsonDecode(responseString);
        if (response.statusCode == 200) {
          if (responseBody.containsKey('res') && responseBody['res'] == false) {
            _showAlertDialog(
                'El tamaño del archivo excede el límite permitido');
          } else if (responseBody.containsKey('success') &&
              responseBody['success']) {
            // Recargar los datos del usuario después de una actualización exitosa
            await _getUserInfo();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext) => Home()),
            );
            _showAlertDialog('Datos actualizados correctamente');
          } else {
            _showAlertDialog('No has realizado ningún cambio');
          }
        } else {
          _showAlertDialog('Error en la solicitud al servidor');
        }
      } catch (e) {
        print('Error decoding JSON response: $e');
        _showAlertDialog('Error al decodificar la respuesta del servidor');
      }
    } on TimeoutException catch (e) {
      print("La solicitud tardó mucho en cargar");
      _showAlertDialog('Error al actualizar los datos');
    } on Error catch (e) {
      print("Error durante la solicitud");
      _showAlertDialog('Error al actualizar el perfil');
    }
  }

  /*void _showAlertDialog(String message) {
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
  }*/

  void _showUploadResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Validación de campos vacíos
  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu $fieldName';
    }
    return null;
  }

  void _validateAndSubmit() {
    setState(() {
      bool hasEmptyFields = false;

      // Validar cada campo requerido
      if (_nombreController.text.isEmpty ||
          _apellidopaController.text.isEmpty ||
          _apellidomaController.text.isEmpty ||
          _telefonoController.text.isEmpty ||
          _coloniaController.text.isEmpty ||
          _calleController.text.isEmpty ||
          _cpController.text.isEmpty) {
        hasEmptyFields = true;
      }

      // Validar longitud de teléfono
      _isTelefonoValid = _validateTelefonoLength(_telefonoController.text);

      // Validar código postal
      _isCpValid = _cpController.text.length == 5;

      // Actualizar estado de la bandera _hasChanges
      _hasChanges = !hasEmptyFields;
    });

    _guardarDatosLocales().then((_) {
      Navigator.pop(context, true); // Regresar a la pantalla anterior
    });
  }

  bool _validateTelefonoLength(String telefono) {
    return telefono.length == 10;
  }

  bool _validateCpLength(String cp) {
    return cp.length == 5;
  }

  /*void _validateAndSubmit() {
    setState(() {
      _isTelefonoValid = _telefonoController.text.length == 10;
      _isCpValid = _cpController.text.length == 5;
    });
  }*/

  Widget buildFilePicker({
    required Function() onFilePicked,
    required String labelText,
    required File? selectedFile,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 49, 49, 49),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: onFilePicked,
            style: ElevatedButton.styleFrom(
              primary: Color.fromARGB(255, 169, 170, 170).withOpacity(0.5),
              // padding: const EdgeInsets.all(16.0),

              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  selectedFile != null
                      ? 'Archivo seleccionado'
                      : 'Seleccionar Archivo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //funcion para subir la fotografia del empleado
  Future<void> _pickFotoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (!['jpg', 'jpeg', 'png'].contains(file.extension)) {
        _showUploadResultDialog(
            "Solo se permiten archivos jpg, jpeg o png para la foto");
        return;
      }
      File pickedFile = File(file.path!);

      if (pickedFile.existsSync()) {
        setState(() {
          fotoFile = pickedFile;
          selectedFotoFileName = '${file.name}';
          _markChanges(); // Aquí se añade la llamada para marcar que hay cambios
        });
      } else {
        _showUploadResultDialog("No se pudo seleccionar la fotografia");
      }
    } else {
      _showUploadResultDialog(
          "El usuario canceló la selección de archivo fotografia");
    }
  }

  void _showAlertDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                if (_hasChanges) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) => Home()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _markChanges() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Información Personal",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              'assets/linea.png',
              width: 180,
              height: 50,
            ),
            // Nombre
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Nombre',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'Nombre'),
                onChanged: (value) {
                  setState(() {
                    _usuario.nombre = value;
                    _markChanges();
                  });
                },
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _apellidopaController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Apellido Paterno',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) =>
                    validateNotEmpty(value, 'apellido paterno'),
                onChanged: (value) {
                  setState(() {
                    _usuario.apellidop = value;
                    _markChanges();
                  });
                },
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _apellidomaController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Apellido Materno',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) =>
                    validateNotEmpty(value, 'apellido materno'),
                onChanged: (value) {
                  setState(() {
                    _usuario.apellidom = value;
                    _markChanges();
                  });
                },
              ),
            ),
            // Apellido Materno
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Telefono',
                  errorText:
                      _isTelefonoValid ? null : 'Ingrese un teléfono válido',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'telefono'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                      10), // Limitar a 10 caracteres
                ],
                onChanged: (value) {
                  setState(() {
                    _usuario.telefono = value;
                    _markChanges();
                    _isTelefonoValid = _validateTelefonoLength(value);
                  });
                },
              ),
            ),
            // Apellido Materno
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _coloniaController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Colonia',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'colonia'),
                onChanged: (value) {
                  setState(() {
                    _usuario.colonia = value;
                    _markChanges();
                  });
                },
              ),
            ),
            // Apellido Materno
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _calleController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Calle',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'Calle'),
                onChanged: (value) {
                  setState(() {
                    _usuario.calle = value;
                    _markChanges();
                  });
                },
              ),
            ),
            // Apellido Materno
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _cpController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Codigo Postal',
                  errorText:
                      _isCpValid ? null : 'Ingresa un codigo postal correcto',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'codigo postal'),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                      5), // Limitar a 10 caracteres
                ],
                onChanged: (value) {
                  setState(() {
                    _usuario.cp = value;
                    _markChanges();
                    _isCpValid = _validateCpLength(value);
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                enabled: false,
                controller: _correoController,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Codigo Postal',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator: (value) => validateNotEmpty(value, 'codigo postal'),
                onChanged: (value) {
                  setState(() {
                    _usuario.correo = value;
                    _markChanges();
                  });
                },
              ),
            ),
            SizedBox(height: 5),
            buildFilePicker(
              labelText: 'Fotografia',
              selectedFile: fotoFile,
              onFilePicked: () {
                _pickFotoFile();
              },
            ),

            // Botón de guardar habilitado solo si hay cambios
            Center(
              child: ElevatedButton(
                onPressed: _hasChanges &&
                        _isTelefonoValid &&
                        !_nombreController.text.isEmpty &&
                        !_apellidopaController.text.isEmpty &&
                        !_apellidomaController.text.isEmpty &&
                        !_telefonoController.text.isEmpty &&
                        !_coloniaController.text.isEmpty &&
                        !_calleController.text.isEmpty &&
                        !_cpController.text.isEmpty
                    ? () {
                        actualizarPerfil(
                          nombre: _nombreController.text,
                          correo: _correoController.text,
                          contra: _passController.text,
                          apellidop: _apellidopaController.text,
                          apellidoma: _apellidomaController.text,
                          telefono: _telefonoController.text,
                          cp: _cpController.text,
                          colonia: _coloniaController.text,
                          calle: _calleController.text,
                          fotoFile: fotoFile,
                        );
                      }
                    : null, // Deshabilita el botón si no hay cambios o hay campos vacíos
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  ' Guardar ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
