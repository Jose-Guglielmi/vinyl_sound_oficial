import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
