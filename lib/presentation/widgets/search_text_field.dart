import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Artistas, Canciones....',
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.black,
        ), // Ícono de búsqueda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
          borderSide: BorderSide.none, // Sin borde externo visible
        ),
        filled: true, // Fondo rellenado
        fillColor: const Color(0xFFEAEFCE), // Color de fondo
      ),
      onFieldSubmitted: (value) {
        audioProvider.apiYoutube(value, 0);
        audioProvider.apiYoutube(value, 1);
      },
    );
  }
}
