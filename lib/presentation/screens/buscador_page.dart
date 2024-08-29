import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/canciones_view_v2.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/search_text_field.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/sin_resultados.dart';

import '../widgets/artistas_view.dart';

class BuscadorPage extends StatelessWidget {
  const BuscadorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF022527),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Buscador",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: SearchTextField(),
            ),
            const Text(
              "Artistas",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0xFFEAEFCE),
                ),
                child: (audioProvider.listaCanciones.isNotEmpty)
                    ? const ArtistasView()
                    : const SinResultados(),
              ),
            ),
            const Text(
              "Canciones",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: const Color(0xFFEAEFCE),
                  ),
                  child: (audioProvider.listaCanciones.isNotEmpty)
                      ? const CancionesViewV2()
                      : const SinResultados(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
