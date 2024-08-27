import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';

import '../widgets/scrolling_text.dart';

class Biblioteca extends StatefulWidget {
  const Biblioteca({super.key});

  @override
  State<Biblioteca> createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();

    Future<void> _showDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nueva Playlist'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Título'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Seleccionar Imagen'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  // Aquí puedes manejar el aceptar, por ejemplo, guardar la información
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    final audioProvider = Provider.of<AudioProvider>(context);

    final listaMeGustas = audioProvider.listaCancionesMeGustas;

    return Scaffold(
      backgroundColor: const Color(0xFF022527),
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Tus Playlists',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _showDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    color: const Color(0xFFEAEFCE),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                            ),
                            height: 50,
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    "Crear Nueva PlayList",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildPlaylistCard(
                        'Mis Favoritos', '${listaMeGustas.length}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función auxiliar para construir cada tarjeta de playlist
  Widget _buildPlaylistCard(String title, String subtitle) {
    return Card(
      color: const Color(0xFFEAEFCE),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                height: 150,
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScrollingText(
                          text: title,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 45,
                    color: Color.fromARGB(255, 32, 75, 33),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
