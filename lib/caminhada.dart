import 'package:latlong2/latlong.dart';

class Caminhada {
  int id;
  String titulo;
  LatLng origem;
  LatLng destino;
  List<LatLng> trajeto;
  double distancia;
  int calorias;
  int tempo;
  String? foto;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.origem,
    required this.destino,
    required this.trajeto,
    required this.distancia,
    required this.calorias,
    required this.tempo,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'origem': [origem.latitude, origem.longitude],
      'destino': [destino.latitude, destino.longitude],
      'trajeto': trajeto
          .map((ponto) => [ponto.latitude, ponto.longitude])
          .toList(),
      'distancia': distancia,
      'calorias': calorias,
      'tempo': tempo,
      'foto': foto,
    };
  }

  factory Caminhada.fromMap(Map<String, dynamic> mapa) {
    return Caminhada(
      id: mapa['id'],
      titulo: mapa['titulo'],

      origem: LatLng(mapa['origem'][0], mapa['origem'][1]),

      destino: LatLng(mapa['destino'][0], mapa['destino'][1]),

      trajeto: (mapa['trajeto'] as List)
          .map((ponto) => LatLng(ponto[0], ponto[1]))
          .toList(),

      distancia: (mapa['distancia'] as num).toDouble(),

      calorias: mapa['calorias'],

      tempo: mapa['tempo'],

      foto: mapa['foto'],
    );
  }
}
