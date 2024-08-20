import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:vinyl_sound_oficial/presentation/screens/favorites_page.dart';

import 'presentation/screens/buscador_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      default:
        return const BuscadorPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Expanded(
              child: cambiarIndexSelect(selectIndex),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MenuInferior(
                cambiarMenuIndex: cambiarSelectedIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuInferior extends StatefulWidget {
  const MenuInferior({
    super.key,
    required this.cambiarMenuIndex,
  });

  final dynamic cambiarMenuIndex;

  @override
  State<MenuInferior> createState() => _MenuInferiorState();
}

class _MenuInferiorState extends State<MenuInferior> {
  int selectIndex = 0;

  void cambiarIndexMenu(int index) {
    setState(() {
      if (index >= 0 && index <= 3) {
        selectIndex = index;
        widget.cambiarMenuIndex(selectIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: const Color(0xFFEAEFCE),
      ),
      child: Row(
        children: [
          MenuItem(
            icon: Icons.search,
            index: 0,
            selectIndex: selectIndex,
            cambiarMenuIndex: cambiarIndexMenu,
          ),
          MenuItem(
            icon: Icons.favorite,
            selectIndex: selectIndex,
            index: 1,
            cambiarMenuIndex: cambiarIndexMenu,
          ),
          MenuItem(
            selectIndex: selectIndex,
            icon: Icons.library_music,
            cambiarMenuIndex: cambiarIndexMenu,
            index: 2,
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(
      {super.key,
      required this.icon,
      required this.index,
      required this.selectIndex,
      required this.cambiarMenuIndex});

  final IconData icon;
  final int index;
  final int selectIndex;
  final dynamic cambiarMenuIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => cambiarMenuIndex(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
            ),
            (index == selectIndex)
                ? Container(
                    color: Colors.black,
                    height: 2,
                    width: 30,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
