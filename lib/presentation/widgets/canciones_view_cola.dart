import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class CancionesViewCola extends StatelessWidget {
  const CancionesViewCola({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final HomeState? state = context.findAncestorStateOfType<HomeState>();

    return ListView.builder(
      itemCount: audioProvider.listaCancionesPorReproducir.length,
      itemBuilder: (context, index) {
        Cancion cancion = audioProvider.listaCancionesPorReproducir[index];

        return Dismissible(
          key: Key(cancion.videoId),
          direction: DismissDirection
              .endToStart, // Configura la dirección del deslizamiento
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Llama a la función que deseas ejecutar cuando se deslice
              onSwipeRight(context, cancion, audioProvider);
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
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: (audioProvider.estaCancionEnReproduccion(cancion)
                      ? const Color.fromARGB(60, 255, 255, 255)
                      : Colors.transparent)),
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
                                  color: Color.fromARGB(255, 173, 173, 173),
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
                                color: Color.fromARGB(255, 255, 252, 252),
                                fontSize: 15),
                          ),
                          (cancion.isExplicit)
                              ? const Icon(
                                  Icons.explicit,
                                  color: Colors.white,
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.playlist_add,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Función que se llama cuando se desliza hacia la derecha
  void onSwipeRight(
      BuildContext context, Cancion cancion, AudioProvider audioProvider) {
    audioProvider.eliminarCancionDeListaPorReproducir(cancion);
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
