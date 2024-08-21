import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/artist.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';

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

        final String nombre = (artista.title.length <= 8)
            ? artista.title
            : "${artista.title.substring(0, 8)}...";
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      artista.thumbnail,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: Text(nombre),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
