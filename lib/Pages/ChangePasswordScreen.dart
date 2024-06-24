import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

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

  String _tempCode = '';
  Timer? _timer;
  int _seconds = 60;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
      });
      if (_seconds == 0) {
        _timer?.cancel();
      }
    });
  }

  void _sendTempCode() async {
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
          builder: (context) => NewPasswordScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('El código temporal no coincide'),
      ));
    }
  }

  void _changePassword() {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      // Cambiar la contraseña aquí
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Contraseña cambiada con éxito'),
      ));
      Navigator.pop(context); // Regresa a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Las contraseñas no coinciden'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingrese su correo electrónico:'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendTempCode,
              child: Text('Enviar Código Temporal'),
            ),
            SizedBox(height: 16.0),
            Text('Ingrese el código temporal enviado:'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tempCodeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                TextButton(
                  onPressed: _seconds == 0 ? _sendTempCode : null,
                  child:
                      Text(_seconds == 0 ? 'Reenviar código' : '$_seconds s'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _validateTempCode,
              child: Text('Validar Código Temporal'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordScreen extends StatelessWidget {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Contraseña'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingrese su nueva contraseña:'),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            Text('Confirme su nueva contraseña:'),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes implementar la lógica para cambiar la contraseña
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Contraseña cambiada con éxito'),
                ));
                Navigator.pop(context); // Regresa a la pantalla anterior
              },
              child: Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

String generateTempCode() {
  var rng = Random();
  return rng.nextInt(999999).toString().padLeft(6, '0');
}

void sendTempCode(String email, String code) async {
  final smtpServer = gmail('luisdeanda320@gmail.com', 'tjrfrtrsysfbtbgd');
  final message = Message()
    ..from = Address('luisdeanda320@gmail.com', 'Luis')
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
