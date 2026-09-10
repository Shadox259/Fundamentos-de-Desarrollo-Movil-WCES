import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const MyHomePage(title: 'Registro de Preferencias'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedRadio = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container( //Sección 1
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 199, 223, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              Text(
                                'Sección 1: Información General',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Completa los siguientes datos personales básicos',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container( //Sección 2
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 199, 255, 208),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.green),
                              Text(
                                'Sección 2: Datos Personales',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Nombre completo',
                              hintText: 'Escribe tu nombre',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Edad',
                              hintText: 'Escribe tu edad',
                              prefixIcon: Icon(Icons.calendar_month),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container( //Sección 3
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 226, 188),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_mosaic, color: Colors.orange),
                              Text(
                                'Sección 3: Distribución en Filas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration( 
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 255, 193, 193),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.red,),
                                Text(
                                  'Fila 1 - Color Rojo',
                                ),
                              ]
                            )
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration( 
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 250, 255, 193),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.yellow,),
                                Text(
                                  'Fila 2 - Color Amarillo',
                                ),
                              ]
                            )
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration( 
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 193, 241, 255),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.blue,),
                                Text(
                                  'Fila 3 - Color Azúl',
                                ),
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container( //Sección 4
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 188, 239),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.grid_on, color: Colors.purple),
                              Text(
                                'Sección 4: Cuatro Hijos en Colores',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 255, 193, 193),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        'Hijo 1',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 255, 243, 193),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        'Hijo 2',
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 205, 255, 193),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        'Hijo 3',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color.fromARGB(255, 230, 193, 255),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(
                                        'Hijo 4',
                                        style: TextStyle(color: Colors.deepPurple),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container( //Sección 5
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 188, 193, 199),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.control_point, color: Colors.blueGrey),
                              Text(
                                'Sección 5: Controles UI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Género:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Masculino',
                                    groupValue: _selectedRadio,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRadio = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                  'Masculino',
                                ),
                              ]),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'Femenino',
                                    groupValue: _selectedRadio,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedRadio = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                  'Femenino'
                                ),
                              ]),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Intereses:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Column(
                            spacing: 16,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Deporte'),
                                  Spacer()
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Música'),
                                  Spacer()
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Cine'),
                                  Spacer()
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Lectura'),
                                  Spacer()
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'País:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.public,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'México',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 40),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text('Mostrar Preferencias',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,))
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text('Guardar Progreso',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}