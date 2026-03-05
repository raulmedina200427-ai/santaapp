
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:santabus/firebase_options.dart'; 
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SantaBusApp());
}

class SantaBusApp extends StatelessWidget {
  const SantaBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SantaBus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        textTheme: GoogleFonts.interTightTextTheme(),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final TextEditingController _emailLogin = TextEditingController();
  final TextEditingController _passLogin = TextEditingController();
  final TextEditingController _emailReg = TextEditingController();
  final TextEditingController _passReg = TextEditingController();
  final TextEditingController _passConfirm = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  String? _nombreArchivo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
    Future<void> _resetPassword() async {
   final TextEditingController _resetEmailController = TextEditingController();

    showDialog(
      context: context,
    builder: (context) => AlertDialog(
      title: const Text("Recuperar contraseña"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Ingresa tu correo electrónico para enviarte las instrucciones de cambio."),
          const SizedBox(height: 15),
          TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(
              labelText: "Correo",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), //pop-up
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            
            Navigator.pop(context); // Cierra el pop-up
            _showMessage("Se ha enviado la solicitud a su correo: ${_resetEmailController.text}");
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Enviar", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
    
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailLogin.text.trim(),
        password: _passLogin.text.trim(),
      );

   
      if (_emailLogin.text.trim() == "1999999@santabus.com" && _passLogin.text.trim() == "1234") {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RutasMenuWidget()),
        );
      } else {
       
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RutasMenuWidget()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Error al iniciar sesión");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (_passReg.text != _passConfirm.text) {
      _showMessage("Las contraseñas no coinciden");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailReg.text.trim(),
        password: _passReg.text.trim(),
      );
      _showMessage("Cuenta creada con éxito");
      _tabController.animateTo(0); 
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Error al registrar");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.blue),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Text(
                    'SANTA APP',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Ingresar'), Tab(text: 'Registrarse')],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),
            SizedBox(
              height: 500,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildForm(
                    controllerEmail: _emailLogin,
                    controllerPass: _passLogin,
                    buttonText: 'Entrar',
                    onPressed: _login,
                  ),
                  _buildForm(
                    controllerEmail: _emailReg,
                    controllerPass: _passReg,
                    controllerConfirm: _passConfirm,
                    buttonText: 'Crear Cuenta',
                    onPressed: _register,
                    isRegister: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm({
  required TextEditingController controllerEmail,
  required TextEditingController controllerPass,
  TextEditingController? controllerConfirm,
  required String buttonText,
  required VoidCallback onPressed,
  bool isRegister = false,
}) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controllerEmail,
            decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controllerPass,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
          ),
          if (!isRegister) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _resetPassword,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    fontSize: 13, 
                    color: Colors.blue, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value!),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("Recuérdame", style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
          if (isRegister) ...[
            const SizedBox(height: 16),
            TextField(
              controller: controllerConfirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar Contraseña', border: OutlineInputBorder()),
            ),
            
            // boton 
            const SizedBox(height: 20),
            const Text(
              "Comprobante de domicilio",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            
             InkWell(
        onTap: () async {
          // 1. Llamamos al selector de archivos (PDF)
          FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      // 2. Si el usuario selecciona un archivo, actualizamos el nombre
      setState(() {
        _nombreArchivo = result.files.single.name;
      });
      _showMessage("Archivo seleccionado: $_nombreArchivo");
    } else {
      // 3. Si cancela, no hacemos nada o avisamos
      _showMessage("No se seleccionó ningún archivo");
    }
  },
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(
        color: _nombreArchivo == null ? Colors.blue : Colors.green,
        width: 2, // Le damos un poco más de grosor para que resalte
      ),
      borderRadius: BorderRadius.circular(8),
      color: _nombreArchivo == null 
          ? Colors.blue.withOpacity(0.05) 
          : Colors.green.withOpacity(0.05),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _nombreArchivo == null ? Icons.picture_as_pdf : Icons.check_circle,
          color: _nombreArchivo == null ? Colors.blue : Colors.green,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            _nombreArchivo ?? "Seleccionar Comprobante",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _nombreArchivo == null ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  ),
),
           
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : Text(buttonText),
            ),
          ),
        ],
      ),
    ),
  );
}
}

// --- VISTA DE RUTAS ---
class RutasMenuWidget extends StatelessWidget {
  const RutasMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        title: const Text('Rutas Disponibles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthPage())),
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Hola, Estudiante 1999999\nSelecciona tu ruta:', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus, color: Colors.blue, size: 30),
                    title: Text('Ruta Santa Catarina #${index + 1}'),
                    subtitle: const Text('Disponible - 15 asientos libres'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                       Navigator.push(
                        context,
                          MaterialPageRoute(builder: (context) => DetalleRutaWidget(indexRuta: index + 1)),
                      );                   
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Mi QR"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}
class DetalleRutaWidget extends StatefulWidget {
  final int indexRuta;
  const DetalleRutaWidget({super.key, required this.indexRuta});

  @override
  State<DetalleRutaWidget> createState() => _DetalleRutaWidgetState();
}

class _DetalleRutaWidgetState extends State<DetalleRutaWidget> {
  int? asientoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8), // [cite: 69]
      appBar: AppBar(
        backgroundColor: Colors.blue, // [cite: 60]
        title: Text('Detalle Ruta #${widget.indexRuta}', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // MAPA SIMULADO (Cuadro blanco)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // [cite: 136]
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '(Aquí se verá el mapa de donde está la ruta)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // INFORMACIÓN DE LA RUTA 
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Información sobre la ruta", // 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text("Paradas: Unidad Universitaria, Centro Santa Catarina, La Fama."),
                    const Text("Horario: 07:00 AM - 09:00 AM"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // LISTA DE 15 ASIENTOS [cite: 15]
              const Text("Selecciona tu asiento (15 disponibles)", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 15, // Los 15 asientos solicitados
                itemBuilder: (context, index) {
                  bool estaSeleccionado = asientoSeleccionado == index;
                  return GestureDetector(
                    onTap: () => setState(() => asientoSeleccionado = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: estaSeleccionado ? Colors.green : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Center(
                        child: Text('${index + 1}',
                            style: TextStyle(
                              color: estaSeleccionado ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // BOTÓN GENERAR QR 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: asientoSeleccionado == null 
                      ? null 
                      : () => _mostrarQR(context),
                  icon: const Icon(Icons.qr_code),
                  label: const Text("RESERVAR Y GENERAR QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tu pase de abordar"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 150), // Representación del QR 
            const SizedBox(height: 10),
            Text("Asiento #${asientoSeleccionado! + 1}"),
            const Text("Ruta Santa Catarina"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
        ],
      ),
    );
  }
}