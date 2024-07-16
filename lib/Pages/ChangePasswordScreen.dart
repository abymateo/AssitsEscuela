import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:technoo/Pages/Login.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _tempCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isTempCodeEntered = false;

  String _tempCode = '';
  Timer? _timer;
  int _seconds = 60;

  bool _isTimerActive = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /*void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
      });
      if (_seconds == 0) {
        _timer?.cancel();
      }
    });
  }*/
  void _startTimer() {
    setState(() {
      _seconds = 60;
      _isTimerActive = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
      });
      if (_seconds == 0) {
        _timer?.cancel();
        setState(() {
          _isTimerActive = false;
        });
      }
    });
  }

  Future<void> _sendTempCode() async {
    if (isValidEmail(_emailController.text)) {
      _tempCode = generateTempCode();
      sendTempCode(_emailController.text, _tempCode);
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Código temporal enviado a ${_emailController.text}'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor ingrese un correo electrónico válido'),
      ));
    }
  }

  void _validateTempCode() {
    if (validateTempCode(_tempCodeController.text, _tempCode)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(_emailController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El código temporal no coincide'),
      ));
    }
  }

  Future<bool> verificarExistenciaCorreo() async {
    String email = _emailController.text.trim();
    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/existsCorreo2";

      var response = await http.post(
        Uri.parse(url),
        body: {'correo': email},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }

        Map<String, dynamic> responseBody = jsonDecode(response.body);
        return responseBody['exists'];
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar la existencia del correo: $e');
      return false;
    }
  }

  void onEnviarCodigoTempPressed() async {
    bool existeCorreo = await verificarExistenciaCorreo();
    if (existeCorreo) {
      _sendTempCode();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El correo electrónico no está registrado.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Text('Cambiar Contraseña'),
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Cambiar Contraseña",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 35),
                Text(
                  'Ingrese su correo electrónico para cambiar la contraseña:',
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Correo Electrónico',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 7.0),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: onEnviarCodigoTempPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Enviar Código Temporal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Ingrese el código temporal enviado a su correo electrónico:',
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                          controller: _tempCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Ingrese el código',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isTempCodeEntered = value.isNotEmpty;
                            });
                          }),
                    ),
                    TextButton(
                      onPressed: _seconds == 0 ? _sendTempCode : null,
                      child: Text(
                        _seconds == 0 ? 'Reenviar código' : '$_seconds s',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 87, 164, 226),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: (_isTempCodeEntered && _isTimerActive)
                      ? _validateTempCode
                      : null,
                  // onPressed: _validateTempCode,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Validar Código Temporal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String generateTempCode() {
    var rng = Random();
    return rng.nextInt(999999).toString().padLeft(6, '0');
  }

  void sendTempCode(String email, String code) async {
    final smtpServer = gmail('itsolutionscv2024@gmail.com', 'ykwcbjaanhsqfgbs');
    final message = Message()
      ..from = Address('itsolutionscv2024@gmail.com', 'ITSOLUTIONS')
      ..recipients.add(email)
      ..subject = 'Código Temporal para Cambiar Contraseña'
      ..text = 'Su código temporal es: $code';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  bool validateTempCode(String enteredCode, String tempCode) {
    return enteredCode == tempCode;
  }
}

class NewPasswordScreen extends StatefulWidget {
  final String email;

  NewPasswordScreen(this.email);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool mostrarContrasena = false;
  bool mostrarContrasena2 = false;
  bool isButtonEnabled = false; // Estado para habilitar/deshabilitar el botón

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

  void _showDialog(
      BuildContext context, String title, String message, bool success) {
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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (route) => false); // Go back to previous screen
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    String messageToShow = errorMessage;
    if (errorMessage.contains("Connection failed")) {
      messageToShow = "Error de conexión. La contraseña no se pudo actualizar.";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(messageToShow),
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

  void _changePassword(BuildContext context) async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showDialog(
          context, 'Error', 'Por favor ingrese ambas contraseñas', false);
      return;
    }

    if (newPassword != confirmPassword) {
      _showDialog(context, 'Error', 'Las contraseñas no coinciden', false);
      return;
    }

    try {
      var url =
          "https://www.kolibri-apps.com/assists/webservice/Empleados/updatePass";
      var response = await http.post(
        Uri.parse(url),
        body: {'correo': widget.email, 'pass': newPassword},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }

        Map<String, dynamic> responseBody = jsonDecode(response.body);
        bool success = responseBody['success'];

        if (success) {
          _showDialog(
              context, 'Éxito', 'Contraseña actualizada correctamente', true);
        } else {
          String errorMessage = responseBody['message'];
          _showErrorDialog(context, errorMessage);
        }
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cambiar la contraseña: $e');
      _showErrorDialog(context,
          'Error al cambiar la contraseña. Por favor intente nuevamente.');
    }
  }

  void checkPasswordCriteria() {
    setState(() {
      isButtonEnabled = passwordCriteriaMet();
    });
  }

//para que solo habilite el boton cuando se cumpla los criterios de la password
  bool passwordCriteriaMet() {
    String password = _newPasswordController.text;

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
        title: Text('Nueva Contraseña'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ingrese su nueva contraseña:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Contraseña',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
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
                      setState(() {
                        checkPasswordCriteria();
                      }); // Actualiza el estado cuando cambia el texto
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
                        hasMinLength(_newPasswordController.text),
                      ),
                      buildPasswordCriteria(
                        'Mínimo un carácter especial',
                        hasSpecialChar(_newPasswordController.text),
                      ),
                      buildPasswordCriteria(
                        'No seguir formato 123...',
                        noSequentialNumbers(_newPasswordController.text),
                      ),
                      buildPasswordCriteria(
                        'Al menos una letra mayúscula',
                        hasUpperCase(_newPasswordController.text),
                      ),
                      buildPasswordCriteria(
                        'Al menos una letra minúscula',
                        hasLowerCase(_newPasswordController.text),
                      ),
                      buildPasswordCriteria(
                        'Al menos un número',
                        hasNumber(_newPasswordController.text),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Confirmar Contraseña',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            mostrarContrasena2 = !mostrarContrasena2;
                          });
                        },
                        icon: Icon(
                          mostrarContrasena2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    obscureText: !mostrarContrasena2,
                    onChanged: (value) {
                      setState(
                          () {}); // Actualiza el estado cuando cambia el texto
                    },
                    // validator: validateConfirmPassword,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed:
                      isButtonEnabled ? () => _changePassword(context) : null,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Cambiar Contraseña',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
