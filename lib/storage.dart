import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'caminhada.dart';

Future<List<Caminhada>> listarCaminhadas() async {
  final prefs = await SharedPreferences.getInstance();

  final json = prefs.getString('caminhadas');

  if (json == null) {
    return [];
  }

  final lista = jsonDecode(json) as List;

  return lista.map((mapa) => Caminhada.fromMap(mapa)).toList();
}

Future<void> _gravar(List<Caminhada> lista) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'caminhadas',
    jsonEncode(lista.map((caminhada) => caminhada.toMap()).toList()),
  );
}

Future<void> salvarCaminhada(Caminhada caminhada) async {
  final lista = await listarCaminhadas();

  lista.add(caminhada);

  await _gravar(lista);
}

Future<void> atualizarCaminhada(Caminhada caminhada) async {
  final lista = await listarCaminhadas();

  final indice = lista.indexWhere((item) => item.id == caminhada.id);

  if (indice != -1) {
    lista[indice] = caminhada;
  }

  await _gravar(lista);
}
