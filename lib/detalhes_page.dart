import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';

import 'caminhada.dart';
import 'storage.dart';

class DetalhesPage extends StatefulWidget {
  final Caminhada caminhada;

  const DetalhesPage({super.key, required this.caminhada});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Caminhada c;

  @override
  void initState() {
    super.initState();

    c = widget.caminhada;
  }

  Future<void> tirarFoto() async {
    final picker = ImagePicker();

    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (foto == null) {
      return;
    }

    setState(() {
      c.foto = foto.path;
    });

    await atualizarCaminhada(c);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Foto salva com sucesso!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(c.titulo)),

      body: Column(
        children: [
          // FOTO
          SizedBox(
            height: 180,
            width: double.infinity,

            child: c.foto != null && File(c.foto!).existsSync()
                ? Image.file(File(c.foto!), fit: BoxFit.cover)
                : Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 70,
                        color: Color.fromARGB(255, 4, 50, 156),
                      ),
                      onPressed: tirarFoto,
                    ),
                  ),
          ),

          // INFORMAÇÕES
          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              children: [
                Text(
                  c.titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Informacao(
                      icone: Icons.straighten,
                      titulo: 'Distância',
                      valor: '${c.distancia.round()} m',
                    ),

                    _Informacao(
                      icone: Icons.local_fire_department,
                      titulo: 'Calorias',
                      valor: '${c.calorias} kcal',
                    ),

                    _Informacao(
                      icone: Icons.timer,
                      titulo: 'Tempo',
                      valor: '${c.tempo} min',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MAPA
          Expanded(
            child: FlutterMap(
              options: MapOptions(initialCenter: c.origem, initialZoom: 16),

              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                  userAgentPackageName: 'com.example.caminhadas',
                ),

                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: c.trajeto,

                      strokeWidth: 5,

                      color: const Color.fromARGB(255, 79, 94, 205),
                    ),
                  ],
                ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: c.origem,

                      width: 45,

                      height: 45,

                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                    Marker(
                      point: c.destino,

                      width: 45,

                      height: 45,

                      child: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 125, 182, 222),
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Informacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _Informacao({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: const Color.fromARGB(255, 5, 45, 131)),

        const SizedBox(height: 4),

        Text(titulo, style: const TextStyle(fontSize: 12)),

        const SizedBox(height: 2),

        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
