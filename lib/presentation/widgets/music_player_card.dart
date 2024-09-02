import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class MusicPlayerCard extends StatefulWidget {
  const MusicPlayerCard({super.key});

  @override
  State<MusicPlayerCard> createState() => _MusicPlayerCardState();
}

class _MusicPlayerCardState extends State<MusicPlayerCard> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final HomeState? state = context.findAncestorStateOfType<HomeState>();

    Cancion cancion = audioProvider.cancionSeleccionado;

    return GestureDetector(
      onTap: () {
        if (state != null) {
          state.cambiarSelectedIndex(3);
          audioProvider.miniReproduciendo = false;
        }
      },
      child: Container(
        color: const Color.fromARGB(255, 2, 37, 39),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
                color:
                    const Color(0xFFeaefce), // Color de fondo del reproductor
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color.fromARGB(75, 255, 255, 255),
                    width: 1) // Bordes redondeados
                ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen del álbum o artista
                  ClipOval(
                    // Bordes redondeados para la imagen
                    child: Image.network(
                      cancion
                          .thumbnail, // Reemplaza con la URL de la imagen real
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                      width: 16), // Espacio entre la imagen y el texto
                  // Detalles de la canción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScrollingText(
                          text: cancion.title,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ScrollingText(
                          text: cancion.author,
                          style: const TextStyle(
                            color: Color.fromARGB(179, 0, 0, 0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Controles de reproducción
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_previous),
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    icon: Icon(audioProvider.player.playing
                        ? Icons.pause
                        : Icons.play_arrow),
                    color: const Color.fromARGB(255, 0, 0, 0),
                    onPressed: () {
                      setState(() {
                        try {
                          if (audioProvider.player.playing) {
                            audioProvider.pause();
                          } else {
                            audioProvider.play();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Error al reproducir la canción')),
                          );
                        }
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.skip_next),
                    // ignore: prefer_const_constructors
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    onPressed: () {
                      audioProvider.stop();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
