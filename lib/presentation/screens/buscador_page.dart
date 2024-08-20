import 'package:flutter/material.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/search_text_field.dart';

import '../widgets/artistas_view.dart';
import '../widgets/canciones_view.dart';

class BuscadorPage extends StatelessWidget {
  const BuscadorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF022527),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
              child: Text(
                "Buscador",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: SearchTextField(),
            ),
            const Text(
              "Artistas",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
              child: Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color(0xFFEAEFCE),
                ),
                child: const Expanded(child: ArtistasView()),
              ),
            ),
            const Text(
              "Canciones",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: const Color(0xFFEAEFCE),
                  ),
                  child: const CancionesView(),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
