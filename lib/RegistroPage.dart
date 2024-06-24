import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:technoo/Pages/Login.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:geolocator/geolocator.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  TextEditingController nombre = TextEditingController();
  TextEditingController apellidopa = TextEditingController();
  TextEditingController apellidoma = TextEditingController();
  TextEditingController correo = TextEditingController();
  TextEditingController contra = TextEditingController();
  TextEditingController telefono = TextEditingController();
  TextEditingController cp = TextEditingController();
  TextEditingController colonia = TextEditingController();
  TextEditingController calle = TextEditingController();
  File? fotoFile;

  String selectedFotoFileName = ' Selecionar Archivo';
  /* File? inefrontFile;
  File? inebackFile;
  File? curpFile;
  File? comprobanteFile;
  
  String selectedInefrontFileName = 'Seleccionar Archivo';
  String selectedInebackFileName = 'Seleccionar Archivo';
  String selectedCurpFileName = 'Seleccionar Archivo';
  String selectedComprobanteFileName = ' Selecionar Archivo';
  
  final Permission permissionCamera = Permission.camera;*/
  final Permission permissionStorage = Permission.storage;

//para permisos de archivos

  void storagePermissionStatus() async {
    // Solicitar permiso de almacenamiento
    final storageStatus = await permissionStorage.request();

    if (storageStatus.isGranted) {
      // Permiso de almacenamiento concedido
      print('Permiso de almacenamiento concedido.');
      // Puedes acceder a archivos aquí si es necesario
    } else {
      // Permiso de almacenamiento denegado
      print('Permiso de almacenamiento denegado.');
    }
  }

/*
// Función para abrir la cámara y capturar una imagen
  Future<void> _pickFromCamera() async {
    final imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      // Aquí puedes manejar la imagen capturada
      // Por ejemplo, puedes mostrarla en un widget Image
      setState(() {
        // asignar la imagen capturada a una variable o hacer algo con ella
      });
    } else {
      // El usuario canceló la captura de la imagen
      print('El usuario canceló la captura de la imagen desde la cámara.');
    }
  }*/

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
          // _pickFromCamera();
        });
      } else {
        _showUploadResultDialog("No se pudo seleccionar la fotografia");
      }
    } else {
      _showUploadResultDialog(
          "El usuario canceló la selección de archivo fotografia");
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

  void _showDialog(String title, String message) {
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void ingresar({
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
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/registroEmpleado";

      print('Datos del formulario:');
      print('Nombre: ${nombre}');
      print('Apellido Paterno: ${apellidop}');
      print('Apellido Materno: ${apellidoma}');
      print('Apellido Materno: ${telefono}');
      print('Apellido Materno: ${cp}');
      print('Apellido Materno: ${colonia}');
      print('Apellido Materno: ${calle}');
      print('Correo: ${correo}');
      print('Contraseña: ${contra}');
      ;

      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields.addAll({
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
      print('Response body: ${responseString}');

      Map<String, dynamic> responseBody = jsonDecode(responseString);

      if (responseBody['res'] == true) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext) => MyHomePage()),
        );
        _showDialog('', 'Usuario registrado exitosamente');
      } else {
        print("Hubo un error");
        _showErrorDialog(responseBody['message']);
      }
    } on TimeoutException catch (e) {
      print("Tardo mucho en cargar");
      _showErrorDialog('Tiempo de espera agotado');
    } on Error catch (e) {
      print("Error: $e");
      _showErrorDialog('Ocurrió un error');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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

// Validación de formato de correo electrónico
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    // Expresión regular para validar formato de correo electrónico
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Registro",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Image.asset(
            //  'assets/linea.png',
            // width: 120,
            //   height: 50,
            //   ),
            SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nombre,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: apellidopa,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: apellidoma,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: telefono,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]')), // Solo permite números
                  LengthLimitingTextInputFormatter(
                      10), // Limita la longitud a 10 caracteres
                ],
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Teléfono',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: cp,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: colonia,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: calle,
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
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: correo,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Correo Electrónico',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
                validator:
                    validateEmail, // Utiliza tu función de validación aquí
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: contra,
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Contraseña',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            buildFilePicker(
              labelText: 'Fotografia',
              selectedFile: fotoFile,
              onFilePicked: () {
                _pickFotoFile();
              },
            ),
            SizedBox(height: 0),
            ElevatedButton(
              onPressed: () {
                print(nombre.text);
                print(contra.text);

                if (nombre.text.isNotEmpty &&
                    apellidopa.text.isNotEmpty &&
                    apellidoma.text.isNotEmpty &&
                    correo.text.isNotEmpty &&
                    contra.text.isNotEmpty &&
                    telefono.text.isNotEmpty &&
                    cp.text.isNotEmpty &&
                    colonia.text.isNotEmpty &&
                    calle.text.isNotEmpty != null) {
                  ingresar(
                    nombre: nombre.text,
                    correo: correo.text,
                    contra: contra.text,
                    apellidop: apellidopa.text,
                    apellidoma: apellidoma.text,
                    telefono: telefono.text,
                    cp: cp.text,
                    colonia: colonia.text,
                    calle: calle.text,
                    fotoFile: fotoFile,
                  );
                } else {
                  _showDialog('Error', 'Llena todos los campos');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
