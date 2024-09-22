import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class CancionesViewPlaylists extends StatelessWidget {
  const CancionesViewPlaylists({
    super.key,
    required this.indexPlay,
  });

  final int indexPlay;

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final HomeState? state = context.findAncestorStateOfType<HomeState>();

    return ListView.builder(
      itemCount: audioProvider.listasDePlaylists[indexPlay].canciones.length,
      itemBuilder: (context, index) {
        Cancion cancion =
            audioProvider.listasDePlaylists[indexPlay].canciones[index];

        return Dismissible(
          key: Key(cancion.videoId),
          direction: DismissDirection
              .endToStart, // Configura la dirección del deslizamiento
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Llama a la función que deseas ejecutar cuando se deslice
              _mostrarPopDePreguntaSioNo(context, cancion, audioProvider);

              return false; // Devuelve false para que el item no se elimine de la lista
            }
            return false;
          },
          background: Container(
            alignment: Alignment.centerRight,
            color: const Color.fromARGB(255, 127, 1, 74),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () {
              audioProvider.empezarEscucharCancion(cancion);
              if (state != null) {
                state.cambiarSelectedIndex(3);
                audioProvider.miniReproduciendo = false;
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      cancion.thumbnail,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScrollingText(
                            text: cancion.title,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 17,
                            ),
                          ),
                          ScrollingText(
                            text: cancion.author,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 196, 196, 196),
                                fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          cancion.duration,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 247, 247),
                              fontSize: 15),
                        ),
                        (cancion.isExplicit)
                            ? const Icon(
                                Icons.explicit,
                                color: Color.fromARGB(255, 255, 255, 255),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarPopDePreguntaSioNo(BuildContext context, Cancion cancion,
      AudioProvider audioProvider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Desea Borrarlo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin acción
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                onSwipeRight(context, cancion, audioProvider);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Función que se llama cuando se desliza hacia la derecha
  void onSwipeRight(
      BuildContext context, Cancion cancion, AudioProvider audioProvider) {
    audioProvider.borrarCancionDePlaylist("Favoritos", cancion.videoId);

    // Aquí puedes implementar la funcionalidad que deseas
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cancion.title} Se agrego a la cola de reproduccion'),
        showCloseIcon: true,
      ),
    );
    // Puedes agregar otras acciones aquí
  }
}
