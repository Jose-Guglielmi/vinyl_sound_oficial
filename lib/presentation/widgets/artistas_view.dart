import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/artist.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class ArtistasView extends StatelessWidget {
  const ArtistasView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final List<Artist> listaArtistas = audioProvider.listaArtistas;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: listaArtistas.length,
      itemBuilder: (context, index) {
        Artist artista = listaArtistas[index];

        return Row(
          children: [
            SizedBox(
              width: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.network(
                        artista.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                      child: ScrollingText(
                        text: artista.title,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
