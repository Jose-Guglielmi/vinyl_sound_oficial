import 'package:flutter/material.dart';

class MusicPlayerCard extends StatelessWidget {
  const MusicPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 2, 37, 39),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
              color: const Color.fromARGB(
                  255, 2, 37, 39), // Color de fondo del reproductor
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color.fromARGB(75, 255, 255, 255),
                  width: 1) // Bordes redondeados
              ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen del álbum o artista
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20), // Bordes redondeados para la imagen
                  child: Image.network(
                    'https://via.placeholder.com/100', // Reemplaza con la URL de la imagen real
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16), // Espacio entre la imagen y el texto
                // Detalles de la canción
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Love",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Pharrel Williams",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Controles de reproducción
                const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.pause,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
