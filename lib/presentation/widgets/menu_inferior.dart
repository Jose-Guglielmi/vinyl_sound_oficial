import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';

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
      color: const Color(0xff022527),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
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
        ),
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
    final audioProvider = Provider.of<AudioProvider>(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          cambiarMenuIndex(index);
          if (audioProvider.player.playing) {
            audioProvider.miniReproduciendo = true;
          }
        },
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
