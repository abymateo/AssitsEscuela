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

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();

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
  bool mostrarContrasena = false;
  bool _isTelefonoValid = true;
  bool _isCpValid = true;

  String selectedFotoFileName = ' Selecionar Archivo';
  final Permission permissionStorage = Permission.storage;

  void storagePermissionStatus() async {
    final storageStatus = await permissionStorage.request();
    if (storageStatus.isGranted) {
      print('Permiso de almacenamiento concedido.');
    } else {
      print('Permiso de almacenamiento denegado.');
    }
  }

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
        _showErrorDialog(responseBody['message']);
      }
    } on TimeoutException catch (e) {
      _showErrorDialog('Tiempo de espera agotado');
    } on Error catch (e) {
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
              backgroundColor:
                  Color.fromARGB(255, 169, 170, 170).withOpacity(0.5),
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
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  // Validación de contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
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
      if (nombre.text.isEmpty ||
          apellidopa.text.isEmpty ||
          apellidoma.text.isEmpty ||
          telefono.text.isEmpty ||
          colonia.text.isEmpty ||
          calle.text.isEmpty ||
          cp.text.isEmpty) {
        hasEmptyFields = true;
      }

      // Validar longitud de teléfono
      _isTelefonoValid = _validateTelefonoLength(telefono.text);

      // Validar código postal
      _isCpValid = cp.text.length == 5;
    });
  }

  bool _validateTelefonoLength(String telefono) {
    return telefono.length == 10;
  }

  bool _validateCpLength(String cp) {
    return cp.length == 5;
  }

  // Criterios de validación para la contraseña
  bool hasMinLength(String value) => value.length >= 8;
  bool hasSpecialChar(String value) =>
      value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool hasUpperCase(String value) => value.contains(RegExp(r'[A-Z]'));
  bool hasLowerCase(String value) => value.contains(RegExp(r'[a-z]'));
  bool hasNumber(String value) => value.contains(RegExp(r'\d'));
  bool noSequentialNumbers(String value) {
    for (int i = 0; i < value.length - 2; i++) {
      if (int.tryParse(value[i]) != null &&
          int.tryParse(value[i + 1]) != null &&
          int.tryParse(value[i + 2]) != null) {
        int first = int.parse(value[i]);
        int second = int.parse(value[i + 1]);
        int third = int.parse(value[i + 2]);

        if (second == first + 1 && third == second + 1) {
          return false;
        }
      }
    }
    return true;
  }

//para que solo habilite el boton cuando se cumpla los criterios de la password
  bool passwordCriteriaMet() {
    String password = contra.text;

    return hasMinLength(password) &&
        hasSpecialChar(password) &&
        noSequentialNumbers(password) &&
        hasUpperCase(password) &&
        hasLowerCase(password) &&
        hasNumber(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Registrar'),
          ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Registro",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                  validator: (value) => validateNotEmpty(value, 'nombre'),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                  validator: (value) =>
                      validateNotEmpty(value, 'apellido paterno'),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                  validator: (value) =>
                      validateNotEmpty(value, 'apellido materno'),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: telefono,
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
                      _isTelefonoValid = _validateTelefonoLength(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: cp,
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
                  validator: (value) =>
                      validateNotEmpty(value, 'codigo postal'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                        5), // Limitar a 10 caracteres
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isCpValid = _validateCpLength(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                  validator: (value) => validateNotEmpty(value, 'colonia'),
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                  validator: (value) => validateNotEmpty(value, 'calle'),
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
                    hintText: 'Correo',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  validator: validateEmail,
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          mostrarContrasena = !mostrarContrasena;
                        });
                      },
                      icon: Icon(
                        mostrarContrasena
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  obscureText: !mostrarContrasena,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: validatePassword,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPasswordCriteria(
                      'Mínimo 8 caracteres',
                      hasMinLength(contra.text),
                    ),
                    buildPasswordCriteria(
                      'Mínimo un carácter especial',
                      hasSpecialChar(contra.text),
                    ),
                    buildPasswordCriteria(
                      'No seguir formato 123...',
                      noSequentialNumbers(contra.text),
                    ),
                    buildPasswordCriteria(
                      'Al menos una letra mayúscula',
                      hasUpperCase(contra.text),
                    ),
                    buildPasswordCriteria(
                      'Al menos una letra minúscula',
                      hasLowerCase(contra.text),
                    ),
                    buildPasswordCriteria(
                      'Al menos un número',
                      hasNumber(contra.text),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              buildFilePicker(
                onFilePicked: _pickFotoFile,
                labelText: 'Foto',
                selectedFile: fotoFile,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: passwordCriteriaMet()
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          ingresar(
                            nombre: nombre.text,
                            apellidop: apellidopa.text,
                            apellidoma: apellidoma.text,
                            telefono: telefono.text,
                            cp: cp.text,
                            colonia: colonia.text,
                            calle: calle.text,
                            correo: correo.text,
                            contra: contra.text,
                            fotoFile: fotoFile,
                          );
                        }
                      }
                    : null, // Si los criterios no se cumplen, onPressed es null (botón deshabilitado)
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordCriteria(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check : Icons.close,
          color: met ? Colors.green : Colors.red,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: met ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
