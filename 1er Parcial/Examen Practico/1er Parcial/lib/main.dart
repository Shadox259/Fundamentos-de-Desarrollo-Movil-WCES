import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Viaje',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  String? _destinoSeleccionado;
  String _transporteSeleccionado = 'Avion';
  bool _hotelIncluido = false;
  bool _tourGuiado = false;
  bool _seguroViaje = false;
  bool _notificaciones = false;
  double _presupuesto = 500;
  DateTime? _fechaSeleccionada;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Cerrar',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _limpiarTodo() {
    setState(() {
      _nombreController.clear();
      _correoController.clear();
      _destinoSeleccionado = null;
      _transporteSeleccionado = 'Avion';
      _hotelIncluido = false;
      _tourGuiado = false;
      _seguroViaje = false;
      _notificaciones = false;
      _presupuesto = 500;
      _fechaSeleccionada = null;
    });
    _showSnackBar(context, 'Información limpiada');
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  double _calcularTotal() {
    double total = 0;
    if (_hotelIncluido) total += 1200;
    if (_tourGuiado) total += 600;
    if (_seguroViaje) total += 400;
    return total;
  }

  void _verResumen() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resumen del Viaje'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${_nombreController.text.isNotEmpty ? _nombreController.text : "No especificado"}'),
                const SizedBox(height: 4),
                Text('Correo: ${_correoController.text.isNotEmpty ? _correoController.text : "No especificado"}'),
                const SizedBox(height: 4),
                Text('Destino: ${_destinoSeleccionado ?? "No seleccionado"}'),
                const SizedBox(height: 4),
                Text('Transporte: $_transporteSeleccionado'),
                const SizedBox(height: 4),
                Text('Extras: ${_obtenerExtras()}'),
                const SizedBox(height: 4),
                Text('Notificaciones: ${_notificaciones ? "Activadas" : "Desactivadas"}'),
                const SizedBox(height: 4),
                Text('Presupuesto: \$${_presupuesto.toStringAsFixed(0)}'),
                const SizedBox(height: 4),
                Text('Fecha: ${_fechaSeleccionada != null ? _formatearFecha(_fechaSeleccionada!) : "No seleccionada"}'),
                const SizedBox(height: 8),
                Text(
                  'Total extras: \$${_calcularTotal().toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.airplane_ticket, color: Colors.blue),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String _obtenerExtras() {
    List<String> extras = [];
    if (_hotelIncluido) extras.add('Hotel');
    if (_tourGuiado) extras.add('Tour');
    if (_seguroViaje) extras.add('Seguro');
    return extras.isEmpty ? 'Ninguno' : extras.join(', ');
  }

  void _confirmarViaje() {
    if (_nombreController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _destinoSeleccionado == null ||
        _fechaSeleccionada == null) {
      _showSnackBar(context, '⚠️ Completa todos los campos obligatorios');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoletoScreen(
          nombre: _nombreController.text,
          correo: _correoController.text,
          destino: _destinoSeleccionado!,
          transporte: _transporteSeleccionado,
          extras: _obtenerExtras(),
          notificaciones: _notificaciones,
          presupuesto: _presupuesto,
          fecha: _fechaSeleccionada!,
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.deepPurple,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserva de Viaje'),
        backgroundColor: const Color.fromARGB(255, 175, 118, 190),
        foregroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _limpiarTodo,
            tooltip: 'Limpiar todo',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container( //Sección 1
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 217, 251),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: _buildSectionHeader(
                  icon: Icons.info_outline,
                  title: 'Sección 1 · Información General',
                  subtitle: 'Completa tu reserva paso a paso. Llena tus datos, elige destino y confirma tu viaje.',
                ),
              ),
              const SizedBox(height: 16),

              Container( //Sección 2
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 217, 251),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.person_outline,
                      title: 'Sección 2 · Datos del Viajero',
                      subtitle: '¿Quién se va de viaje?',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Ej: Ana Garcia',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        hintText: 'Ej: ana@correo.com',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container( //Sección 3
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 217, 251),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.explore_outlined,
                      title: 'Sección 3 · Destino y Transporte',
                      subtitle: 'Elige tu aventura',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDestinoCard(
                          icon: Icons.beach_access,
                          label: 'Playa',
                          color: Colors.blue,
                          destino: 'Playa',
                        ),
                        _buildDestinoCard(
                          icon: Icons.location_city,
                          label: 'Ciudad',
                          color: Colors.orange,
                          destino: 'Ciudad',
                        ),
                        _buildDestinoCard(
                          icon: Icons.landscape,
                          label: 'Montaña',
                          color: Colors.green,
                          destino: 'Montaña',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Transporte',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _transporteSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'Avion', child: Text('Avión')),
                        DropdownMenuItem(value: 'Autobus', child: Text('Autobús')),
                        DropdownMenuItem(value: 'Tren', child: Text('Tren')),
                        DropdownMenuItem(value: 'Barco', child: Text('Barco')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _transporteSeleccionado = value!;
                        });
                        _showSnackBar(context, 'Transporte: $value');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container( //Sección 4
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 217, 251),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.tune_outlined,
                      title: 'Sección 4 · Extras y Preferencias',
                      subtitle: 'Personaliza tu viaje',
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: _hotelIncluido ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _hotelIncluido ? Colors.blue : Colors.grey.shade300,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _hotelIncluido,
                        onChanged: (value) {
                          setState(() {
                            _hotelIncluido = value ?? false;
                          });
                          _showSnackBar(context,
                              'Hotel incluido: ${value! ? "Activado" : "Desactivado"} (+ \$1200)');
                        },
                        title: const Text('Hotel incluido (+ \$1200)'),
                        secondary: const Icon(Icons.hotel, color: Colors.blue),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _tourGuiado ? Colors.orange.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _tourGuiado ? Colors.orange : Colors.grey.shade300,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _tourGuiado,
                        onChanged: (value) {
                          setState(() {
                            _tourGuiado = value ?? false;
                          });
                          _showSnackBar(context,
                              'Tour guiado: ${value! ? "Activado" : "Desactivado"} (+ \$600)');
                        },
                        title: const Text('Tour guiado (+ \$600)'),
                        secondary: const Icon(Icons.tour, color: Colors.orange),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _seguroViaje ? Colors.green.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _seguroViaje ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _seguroViaje,
                        onChanged: (value) {
                          setState(() {
                            _seguroViaje = value ?? false;
                          });
                          _showSnackBar(context,
                              'Seguro de viaje: ${value! ? "Activado" : "Desactivado"} (+ \$400)');
                        },
                        title: const Text('Seguro de viaje (+ \$400)'),
                        secondary: const Icon(Icons.health_and_safety, color: Colors.green),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: _notificaciones ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _notificaciones ? Colors.blue : Colors.grey.shade300,
                        ),
                      ),
                      child: SwitchListTile(
                        value: _notificaciones,
                        onChanged: (value) {
                          setState(() {
                            _notificaciones = value;
                          });
                          _showSnackBar(context,
                              'Notificaciones: ${value ? "Activadas" : "Desactivadas"}');
                        },
                        title: const Text('Recibir notificaciones'),
                        subtitle: Text(
                          _notificaciones ? 'Activadas' : 'Desactivadas',
                          style: TextStyle(
                            color: _notificaciones ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        secondary: Icon(
                          _notificaciones ? Icons.notifications_active : Icons.notifications_off,
                          color: _notificaciones ? Colors.blue : Colors.grey,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Presupuesto:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_presupuesto.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '\$10000',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Slider(
                      value: _presupuesto,
                      min: 500,
                      max: 10000,
                      divisions: 20,
                      label: '\$${_presupuesto.toStringAsFixed(0)}',
                      onChanged: (value) {
                        setState(() {
                          _presupuesto = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2027),
                          locale: const Locale('es', 'ES'),
                        );
                        if (picked != null) {
                          setState(() {
                            _fechaSeleccionada = picked;
                          });
                          _showSnackBar(context,
                              'Fecha seleccionada: ${_formatearFecha(picked)}');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Text(
                              'Fecha del viaje',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              _fechaSeleccionada != null
                                  ? _formatearFecha(_fechaSeleccionada!)
                                  : 'Toca para elegir fecha',
                              style: TextStyle(
                                color: _fechaSeleccionada != null
                                    ? Colors.blue
                                    : Colors.grey,
                                fontWeight: _fechaSeleccionada != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container( //Sección 5
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 217, 251),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      icon: Icons.check_circle_outline,
                      title: 'Sección 5 · Confirmar',
                      subtitle: 'Revisa tus datos antes de despegar',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _verResumen,
                          icon: const Icon(Icons.visibility),
                          label: const Text('Ver Resumen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _confirmarViaje,
                          icon: const Icon(Icons.check),
                          label: const Text('Confirmar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinoCard({
    required IconData icon,
    required String label,
    required Color color,
    required String destino,
  }) {
    bool seleccionado = _destinoSeleccionado == destino;
    return InkWell(
      onTap: () {
        setState(() {
          _destinoSeleccionado = destino;
        });
        _showSnackBar(context, 'Destino: $label');
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: seleccionado ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? color : Colors.grey,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BoletoScreen extends StatelessWidget {
  final String nombre;
  final String correo;
  final String destino;
  final String transporte;
  final String extras;
  final bool notificaciones;
  final double presupuesto;
  final DateTime fecha;

  const BoletoScreen({
    super.key,
    required this.nombre,
    required this.correo,
    required this.destino,
    required this.transporte,
    required this.extras,
    required this.notificaciones,
    required this.presupuesto,
    required this.fecha,
  });

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    IconData destinoIcon;
    Color destinoColor;
    switch (destino) {
      case 'Playa':
        destinoIcon = Icons.beach_access;
        destinoColor = Colors.blue;
        break;
      case 'Ciudad':
        destinoIcon = Icons.location_city;
        destinoColor = Colors.orange;
        break;
      case 'Montaña':
        destinoIcon = Icons.landscape;
        destinoColor = Colors.green;
        break;
      default:
        destinoIcon = Icons.place;
        destinoColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Boleto'),
        backgroundColor: const Color.fromARGB(255, 175, 116, 195),
        foregroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(destinoIcon, color: destinoColor, size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Buen viaje, $nombre!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          destino,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: destinoColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.email, 'Correo', correo),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.airplane_ticket, 'Destino', destino),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.directions_car, 'Transporte', transporte),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.local_activity, 'Extras', extras),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.notifications,
                  'Notificaciones',
                  notificaciones ? 'Activadas' : 'Desactivadas',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.attach_money, 'Presupuesto',
                    '\$${presupuesto.toStringAsFixed(0)}'),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.calendar_month, 'Fecha', _formatearFecha(fecha)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}