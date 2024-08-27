import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class CancionesView extends StatelessWidget {
  const CancionesView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final HomeState? state = context.findAncestorStateOfType<HomeState>();

    return ListView.builder(
        itemCount: audioProvider.listaCanciones.length,
        itemBuilder: (context, index) {
          Cancion cancion = audioProvider.listaCanciones[index];

          return GestureDetector(
            onTap: () {
              audioProvider.cancionSeleccionado = Cancion();
              audioProvider.cancionSeleccionado = cancion;
              audioProvider.actualizarUrl(cancion.videoId);
              if (state != null) {
                state.cambiarSelectedIndex(3);
                audioProvider.reproduciendo = false;
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
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
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 17,
                              ),
                            ),
                            ScrollingText(
                              text: cancion.author,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 17),
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
                                color: Color.fromARGB(255, 100, 100, 100),
                                fontSize: 15),
                          ),
                          (cancion.isExplicit)
                              ? const Icon(Icons.explicit)
                              : Container(),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
