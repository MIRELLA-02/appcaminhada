import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'caminhada.dart';
import 'storage.dart';
import 'splash_page.dart';
import 'nova_page.dart';
import 'detalhes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Caminhada> lista = [];

  @override
  void initState() {
    super.initState();

    carregar();
  }

  Future<void> carregar() async {
    final dados = await listarCaminhadas();

    setState(() {
      lista = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final claro = temaNotifier.value == ThemeMode.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Caminhadas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 0, 22, 144)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.directions_walk, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Caminhadas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Splash'),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(claro ? Icons.dark_mode : Icons.light_mode),
              title: Text(claro ? 'Tema Escuro' : 'Tema Claro'),
              onTap: () {
                temaNotifier.value = claro ? ThemeMode.dark : ThemeMode.light;

                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),

      body: lista.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 90,
                    color: const Color.fromARGB(232, 121, 161, 255),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Nenhuma caminhada cadastrada',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Clique no + para adicionar uma caminhada.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),

              itemCount: lista.length,

              itemBuilder: (context, i) {
                final c = lista[i];

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),

                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesPage(caminhada: c),
                        ),
                      );

                      carregar();
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          c.foto != null && File(c.foto!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(c.foto!),
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.directions_walk,
                                  size: 70,
                                  color: Color.fromARGB(255, 82, 132, 219),
                                ),

                          const SizedBox(height: 8),

                          Text(
                            c.titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${c.distancia.round()} m',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NovaPage()),
          );

          carregar();
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
