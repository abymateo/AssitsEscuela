import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technoo/Pages/Login.dart';
import 'package:technoo/Pages/Perfil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _loggedInUser = '';
  late String _correoUser = '';
  late String _fotouser = '';
  final String defaultImage =
      'assets/profile_default.png.png'; // Ruta de la imagen predeterminada

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre = prefs.getString('username');
    String? apellidopa = prefs.getString('apellidoPaterno');
    String? apellidoma = prefs.getString('apellidoMaterno');
    String? correo = prefs.getString('email');
    String? foto = prefs.getString('foto');
    // Asegúrate de tener bien el nombre de la clave
    int? id = prefs.getInt('id');
    print('Correo en SharedPreferences: $nombre');
    print('ID en SharedPreferences: $id');
    print('Correo en SharedPreferences: $correo');
    print('foto en SharedPreferences: $foto');

    if (correo != null && id != null) {
      setState(() {
        _loggedInUser = '$nombre $apellidopa $apellidoma';
        _correoUser = '$correo';
        _fotouser = '$foto';
        // Puedes actualizar otros estados aquí según sea necesario
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        // onPressed: () {
        // Navigator.pop(context);
        //},
        //icon: const Icon(LineAwesomeIcons.angle_left),
        // ),
        title: const Text("Ajustes"),
        centerTitle: true,
        //  actions: [
        // IconButton(
        // onPressed: () {},
        //icon: Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon),
        // )
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Mostrar la foto del usuario
            // Mostrar la foto del usuario
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text('Imagen de perfil'),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      body: Center(
                        child: Image.network(
                          'https://www.kolibri-apps.com/assists/app/static/img/$_correoUser/$_fotouser',
                          height: 200, // Ajusta el tamaño de la imagen
                          errorBuilder: (context, error, stackTrace) {
                            // En caso de error, mostrar la imagen predeterminada
                            return Image.network(
                              'https://www.kolibri-apps.com/assists/app/static/images/perfil.jpg',
                              height: 200, // Ajusta el tamaño de la imagen
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'imagen',
                child: Image.network(
                  'https://www.kolibri-apps.com/assists/app/static/img/$_correoUser/$_fotouser',
                  height: 200, // Ajusta el tamaño de la imagen
                  errorBuilder: (context, error, stackTrace) {
                    // En caso de error, mostrar la imagen predeterminada
                    return Image.network(
                      'https://www.kolibri-apps.com/assists/app/static/images/perfil.jpg',
                      height: 200, // Ajusta el tamaño de la imagen
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),
            // Mostrar el nombre del usuario
            Text(
              _loggedInUser,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _correoUser,
              textAlign: TextAlign.center,
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            menuProfileWidget(
              title: const Text("Editar perfil"),
              icon: LineAwesomeIcons.user_check,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Perfil()),
                );
              },
            ),
            menuProfileWidget(
              title: const Text("Acerca de la aplicación"),
              icon: LineAwesomeIcons.app_net,
              onPress: () {
                // Mostrar diálogo con información de la aplicación
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('About Application'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('App Name: Assist '),
                          Text('Version: v0.901'),
                          // Agrega más información si es necesario
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            menuProfileWidget(
              title: const Text("Cerrar sesión"),
              icon: LineAwesomeIcons.alternate_sign_out,
              texColor: Colors.red,
              onPress: () {
                // Acción para cerrar sesión
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}

class menuProfileWidget extends StatelessWidget {
  final Widget title;
  final IconData icon;
  final VoidCallback onPress;
  final Color? texColor;

  const menuProfileWidget({
    required this.title,
    required this.icon,
    required this.onPress,
    this.texColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: title,
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Icon(
            LineAwesomeIcons.angle_right,
            color: Colors.grey,
          ),
        ),
        onTap: onPress,
      ),
    );
  }
}
