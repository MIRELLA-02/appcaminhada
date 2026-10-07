import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'caminhada.dart';
import 'storage.dart';

class NovaPage extends StatefulWidget {
  const NovaPage({super.key});

  @override
  State<NovaPage> createState() => _NovaPageState();
}

class _NovaPageState extends State<NovaPage> {
  LatLng? origem;
  LatLng? destino;

  List<LatLng> trajeto = [];

  double distancia = 0;

  int tempo = 0;

  final tituloController = TextEditingController();

  bool carregando = true;
  bool calculando = false;

  // 65 calorias aproximadamente por km
  int get calorias {
    return ((distancia / 1000) * 65).round();
  }

  @override
  void initState() {
    super.initState();

    pegarLocalizacao();
  }

  @override
  void dispose() {
    tituloController.dispose();

    super.dispose();
  }

  Future<void> pegarLocalizacao() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      setState(() {
        origem = LatLng(-22.713, -46.818);

        carregando = false;
      });

      return;
    }

    LocationPermission permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      setState(() {
        // Localização de referência
        // caso a permissão seja recusada
        origem = LatLng(-22.713, -46.818);

        carregando = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Localização não permitida. Usando localização de referência.',
            ),
          ),
        );
      }

      return;
    }

    final posicao = await Geolocator.getCurrentPosition();

    setState(() {
      origem = LatLng(posicao.latitude, posicao.longitude);

      carregando = false;
    });
  }

  Future<void> escolherDestino(LatLng ponto) async {
    if (origem == null) {
      return;
    }

    setState(() {
      destino = ponto;
      calculando = true;
      trajeto = [];
    });

    final url =
        'https://routing.openstreetmap.de/routed-foot/route/v1/foot/'
        '${origem!.longitude},${origem!.latitude};'
        '${ponto.longitude},${ponto.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final resposta = await http.get(Uri.parse(url));

      if (resposta.statusCode != 200) {
        throw Exception();
      }

      final dados = jsonDecode(resposta.body);

      if (dados['routes'] == null || dados['routes'].isEmpty) {
        throw Exception();
      }

      final rota = dados['routes'][0];

      final coordenadas = rota['geometry']['coordinates'] as List;

      final pontos = coordenadas
          .map(
            (ponto) => LatLng(
              (ponto[1] as num).toDouble(),
              (ponto[0] as num).toDouble(),
            ),
          )
          .toList();

      final distanciaRota = (rota['distance'] as num).toDouble();

      final duracaoSegundos = (rota['duration'] as num).toDouble();

      setState(() {
        distancia = distanciaRota;

        trajeto = pontos;

        tempo = (duracaoSegundos / 60).round();

        calculando = false;
      });
    } catch (e) {
      setState(() {
        calculando = false;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível traçar o trajeto.')),
      );
    }
  }

  void abrirModal() {
    tituloController.clear();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Salvar caminhada'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Distância: ${distancia.round()} m'),

              const SizedBox(height: 5),

              Text('Calorias: $calorias kcal'),

              const SizedBox(height: 5),

              Text('Tempo: $tempo min'),

              const SizedBox(height: 20),

              TextField(
                controller: tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da caminhada',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
          ],
        );
      },
    );
  }

  Future<void> salvar() async {
    if (tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Digite um título.')));

      return;
    }

    if (origem == null || destino == null || trajeto.isEmpty) {
      return;
    }

    final caminhada = Caminhada(
      id: DateTime.now().millisecondsSinceEpoch,

      titulo: tituloController.text.trim(),

      origem: origem!,

      destino: destino!,

      trajeto: trajeto,

      distancia: distancia,

      calorias: calorias,

      tempo: tempo,
    );

    await salvarCaminhada(caminhada);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (carregando || origem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nova caminhada')),

        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova caminhada'),

        actions: [
          if (destino != null && trajeto.isNotEmpty)
            TextButton(
              onPressed: abrirModal,
              child: const Text(
                'Salvar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),

            child: calculando
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),

                      SizedBox(width: 10),

                      Text('Calculando trajeto...'),
                    ],
                  )
                : Text(
                    destino == null
                        ? 'Clique no mapa para escolher o destino'
                        : 'Distância: ${distancia.round()} m  •  '
                              'Calorias: $calorias kcal  •  '
                              'Tempo: $tempo min',
                    textAlign: TextAlign.center,

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),

          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: origem!,

                initialZoom: 16,

                onTap: (tapPosition, ponto) {
                  escolherDestino(ponto);
                },
              ),

              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                  userAgentPackageName: 'com.example.caminhadas',
                ),

                if (trajeto.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: trajeto,

                        strokeWidth: 5,

                        color: Colors.green,
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: origem!,

                      width: 45,

                      height: 45,

                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                    if (destino != null)
                      Marker(
                        point: destino!,

                        width: 45,

                        height: 45,

                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
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
