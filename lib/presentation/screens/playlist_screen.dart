import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/playlist.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/canciones_view_playlists.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({
    super.key,
    required this.index,
    this.favorite = false,
  });

  final int index;
  final bool favorite;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final HomeState? state = context.findAncestorStateOfType<HomeState>();

    final PlaylistMyApp playlists =
        audioProvider.listasDePlaylists[widget.index];

    Future<void> _mostrarPopUpConCuadroTexto(BuildContext context) async {
      TextEditingController controladorTexto = TextEditingController();

      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ingresa un texto'),
            content: TextField(
              controller: controladorTexto,
              decoration: const InputDecoration(hintText: "Escribe algo aquí"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo sin acción
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  String textoIngresado = controladorTexto.text;
                  audioProvider.modificarNombrePlaylist(
                      playlists.nombre, textoIngresado);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _mostrarPopUpDeCancelarOaceptar(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('¿Desea Borrarlo?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo sin acción
                },
              ),
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  audioProvider.borrarPlaylist(playlists.nombre);
                  if (state != null) {
                    state.cambiarSelectedIndex(2);
                    setState(() {});
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (state != null) {
          state.cambiarSelectedIndex(2);
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF022527),
        body: Column(
          children: [
            (!widget.favorite)
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (state != null) {
                            state.cambiarSelectedIndex(2);
                            setState(() {});
                          }
                        },
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Text(
                                playlists.nombre,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              (playlists.nombre != "Favoritos")
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        _mostrarPopUpConCuadroTexto(context);
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      (playlists.nombre != "Favoritos")
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE8E1C6),
                                foregroundColor: const Color(0xFF0A2E1F),
                              ),
                              onPressed: () {
                                _mostrarPopUpDeCancelarOaceptar(context);
                              },
                              child: const Row(
                                children: [
                                  Text("Eliminar PlayList "),
                                  Icon(
                                    Icons.restore_from_trash,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  )
                : Center(
                    child: Text(
                      playlists.nombre,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total de canciones: ${playlists.canciones.length}",
                      style: const TextStyle(color: Color(0xFFE8E1C6)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Reproducir'),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8E1C6),
                              foregroundColor: const Color(0xFF0A2E1F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Aleatorio'),
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE8E1C6),
                              side: const BorderSide(color: Color(0xFFE8E1C6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    (audioProvider.listasDePlaylists.isNotEmpty)
                        ? Expanded(
                            child: CancionesViewPlaylists(
                              indexPlay: widget.index,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                "No hay Canciones en la PlayList",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
