import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technoo/Pages/Home.dart';
import 'package:flutter/services.dart';

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
    required this.apellidom,
    required this.apellidop,
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
  final TextEditingController _idController = TextEditingController();
  // File? inefrontFile;
  //File? inebackFile;
  // File? curpFile;
  // File? comprobanteFile;
  File? fotoFile;
//  String selectedInefrontFileName = 'Seleccionar Archivo';
//  String selectedInebackFileName = 'Seleccionar Archivo';
//  String selectedCurpFileName = 'Seleccionar Archivo';
//  String selectedComprobanteFileName = ' Selecionar Archivo';
  String selectedFotoFileName = ' Selecionar Archivo';

  late Usuario _usuario;

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
    //  required File? inefrontFile,
    //  required File? inebackFile,
    //  required File? curpFile,
    //  required File? comprobanteFile,
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
            Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext) => Home()),
            );
            _showAlertDialog('Datos actualizados correctamente');
          } else {
            _showAlertDialog('Error al actualizar los datos');
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

  void _showAlertDialog(String message) {
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

  // Para validar los documentos
  Future<bool> validarDocumentosEmpleado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('idEm');

    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/validarDocumentos";

      var response = await http.post(Uri.parse(url), body: {
        'idEm': id.toString(),
      }).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['registrados'];
      } else {
        print("Error en la solicitud a la API");
        return false;
      }
    } on TimeoutException catch (e) {
      print("La solicitud tardó mucho en cargar");
      return false;
    } on Error catch (e) {
      print("Error durante la solicitud");
      return false;
    }
  }

  void _showUploadResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
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
        });
      } else {
        _showUploadResultDialog("No se pudo seleccionar la fotografia");
      }
    } else {
      _showUploadResultDialog(
          "El usuario canceló la selección de archivo fotografia");
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
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
            SizedBox(height: 30),
            Card(
              color: Color.fromARGB(255, 253, 253, 253),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                      ),
                    ),*/
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ingressa nombre',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _apellidopaController,
                      decoration: InputDecoration(
                        labelText: 'Apellido paterno',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _apellidomaController,
                      decoration: InputDecoration(
                        labelText: 'Apellido materno',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _telefonoController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), // Solo permite números
                        LengthLimitingTextInputFormatter(
                            10), // Limita la longitud a 10 caracteres
                      ],
                      decoration: InputDecoration(
                        labelText: 'Telefono',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.phone_android,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _cpController,
                      decoration: InputDecoration(
                        labelText: 'Codigo Postal',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.house,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _coloniaController,
                      decoration: InputDecoration(
                        labelText: 'Colonia',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.house,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _calleController,
                      decoration: InputDecoration(
                        labelText: 'Calle',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.house,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _correoController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Correo Electronico',
                        hintText: 'Ingresa información',
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Verifica si los documentos del usuario están registrados
                    FutureBuilder<bool>(
                      future: validarDocumentosEmpleado(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError || !snapshot.data!) {
                            // Si hay un error o los documentos no están registrados, muestra los campos de archivo
                            return Column(
                              children: [
                                buildFilePicker(
                                  labelText: 'Fotografia',
                                  selectedFile: fotoFile,
                                  onFilePicked: () {
                                    _pickFotoFile();
                                  },
                                ),
                              ],
                            );
                          } else {
                            // Si los documentos están registrados, no se muestran campos adicionales
                            return SizedBox.shrink();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _usuario.nombre = _nombreController.text;
                  _usuario.correo = _correoController.text;
                  _usuario.pass = _passController.text;
                  _usuario.telefono = _telefonoController.text;
                  _usuario.colonia = _coloniaController.text;
                  _usuario.calle = _calleController.text;
                  _usuario.cp = _cpController.text;
                  _usuario.apellidop = _apellidopaController.text;
                  _usuario.apellidom = _apellidomaController.text;

                  actualizarPerfil(
                    nombre: _usuario.nombre,
                    correo: _usuario.correo,
                    contra: _usuario.pass,
                    apellidop: _usuario.apellidop,
                    apellidoma: _usuario.apellidom,
                    telefono: _usuario.telefono,
                    colonia: _usuario.colonia,
                    calle: _usuario.calle,
                    cp: _usuario.cp,
                    fotoFile: fotoFile,
                  );
                },
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

void main() {
  runApp(MaterialApp(
    home: Perfil(),
  ));
}
