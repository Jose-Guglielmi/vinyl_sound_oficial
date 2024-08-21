import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/screens/favorites_page.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/reproductor.dart';

import 'presentation/screens/buscador_page.dart';
import 'presentation/widgets/menu_inferior.dart';
import 'presentation/widgets/music_player_card.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  int selectIndex = 0;

  void cambiarSelectedIndex(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  Widget cambiarIndexSelect(int index) {
    switch (index) {
      case 0:
        return const BuscadorPage();
      case 1:
        return const FavoritesPage();
      case 2:
        return const FavoritesPage();
      case 3:
        return const Reproductor();
      default:
        return const BuscadorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: cambiarIndexSelect(selectIndex),
            ),
            (audioProvider.reproduciendo)
                ? const MusicPlayerCard()
                : Container(),
            MenuInferior(
              cambiarMenuIndex: cambiarSelectedIndex,
            ),
          ],
        ),
      ),
    );
  }
}
