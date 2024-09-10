import 'package:flutter/material.dart';
import 'package:vinyl_sound_oficial/presentation/screens/playlist_screen.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff022527),
      body: PlaylistScreen(
        index: 0,
        favorite: true,
      ),
    );
  }
}
