import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinyl_sound_oficial/main.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/state_managener/audio_provider.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/canciones_view_cola.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/scrolling_text.dart';

class Reproductor extends StatefulWidget {
  const Reproductor({
    super.key,
  });

  @override
  State<Reproductor> createState() => _ReproductorState();
}

class _ReproductorState extends State<Reproductor> {
  final String imageUrl =
      'https://lh3.googleusercontent.com/-5tnsyG-BDCZj2gipRW710kLtHWPDVmlvt2BMwJ4StWqrfMxRUYvLsirYPClRDg1qnDU3avAgVn66eS20A=w120-h120-l90-rj';

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    return Rep(
      imageUrl: imageUrl,
      audioProvider: audioProvider,
    );
  }
}

class Rep extends StatefulWidget {
  const Rep({
    super.key,
    required this.imageUrl,
    required this.audioProvider,
  });

  final String imageUrl;
  final AudioProvider audioProvider;

  @override
  State<Rep> createState() => _RepState();
}

class _RepState extends State<Rep> {
  final ValueNotifier<String> _currentLyric = ValueNotifier('');
  late StreamSubscription<Duration> _positionSubscription;
  final ValueNotifier<Duration> _currentPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _totalDuration = ValueNotifier(Duration.zero);

  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _positionSubscription =
        widget.audioProvider.player.positionStream.listen((position) {
      if (!_disposed) {
        _currentPosition.value = position;
      }
    });
    widget.audioProvider.player.durationStream.listen((duration) {
      if (!_disposed) {
        _totalDuration.value = duration ?? Duration.zero;
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _disposed = true;
    _positionSubscription.cancel();
    _currentPosition.dispose();
    _totalDuration.dispose();
    _currentLyric.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    bool centro = false;
    final HomeState? state = context.findAncestorStateOfType<HomeState>();
    final audioProvider = Provider.of<AudioProvider>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (state != null) {
          state.cambiarSelectedIndex(0);
          audioProvider.reproduciendo = true;
          setState(() {});
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff022527),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (state != null) {
                        state.cambiarSelectedIndex(0);
                        audioProvider.reproduciendo = true;
                      }
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ScrollingText(
                centerWhenNoScroll: true,
                text: widget.audioProvider.cancionSeleccionado.title,
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
              Text(
                widget.audioProvider.cancionSeleccionado.author,
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 136, 136, 136)
                          .withOpacity(0.5), // Color de la sombra con opacidad
                      spreadRadius: 6, // Expande el radio de la sombra
                      blurRadius: 10, // Difumina el radio de la sombra
                      offset: const Offset(0,
                          7), // Desplazamiento de la sombra (horizontal, vertical)
                    ),
                  ],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        widget.audioProvider.cancionSeleccionado.thumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ValueListenableBuilder<List<String>>(
                valueListenable: widget.audioProvider.currentLyrics,
                builder: (context, lyrics, child) {
                  return Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          lyrics[0], // Letra anterior
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lyrics[1], // Letra actual
                          style: const TextStyle(
                              fontSize: 25, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lyrics[2], // Letra siguiente
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              ValueListenableBuilder<Duration>(
                valueListenable: _totalDuration,
                builder: (context, totalDuration, child) {
                  return ValueListenableBuilder<Duration>(
                    valueListenable: _currentPosition,
                    builder: (context, currentPosition, child) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _formatDuration(currentPosition),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  _formatDuration(totalDuration),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            value: currentPosition.inSeconds
                                .toDouble()
                                .clamp(0, totalDuration.inSeconds.toDouble()),
                            max: totalDuration.inSeconds.toDouble(),
                            min: 0,
                            onChanged: (value) {
                              final newPosition =
                                  Duration(seconds: value.toInt());
                              widget.audioProvider.player.seek(newPosition);
                            },
                            activeColor: Colors.pinkAccent,
                            inactiveColor: Colors.white54,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_add),
                      color: Colors.white,
                      iconSize: 45,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Se Agrego Una playList'),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          color: Colors.white,
                          iconSize: 45,
                          onPressed: () {
                            setState(() {
                              audioProvider.playPrevious();
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(widget.audioProvider.player.playing
                              ? Icons.pause
                              : Icons.play_arrow),
                          color: Colors.white,
                          iconSize: 60,
                          onPressed: () {
                            setState(() {
                              try {
                                if (widget.audioProvider.player.playing) {
                                  widget.audioProvider.pause();
                                } else {
                                  widget.audioProvider.play();
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Error al reproducir la canción')),
                                );
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          color: Colors.white,
                          iconSize: 45,
                          onPressed: () {
                            setState(() {
                              widget.audioProvider.playNext();
                            });
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh_outlined,
                        color: (widget.audioProvider.cancionBucle)
                            ? Colors.pink
                            : Colors.white,
                      ),
                      color: Colors.white,
                      iconSize: 45,
                      onPressed: () {
                        widget.audioProvider.bucleCancion();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      color: Colors.white,
                      iconSize: 45,
                      onPressed: () async {
                        //widget.audioProvider.agregarCancion(widget.audioProvider.cancionSeleccionado);
                        //final SharedPreferences prefs =
                        //await SharedPreferences.getInstance();

                        //CancionesList listCanciones = CancionesList(canciones:widget.audioProvider.listaCancionesMeGustas);
                        //await prefs.setString('cancionesMeGusta', listCanciones.toJson());
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Se Agrego a mis Me gustas'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {});
                    showBottomSheet(context,
                        widget.audioProvider.listaCancionesPorReproducir);
                  },
                  child: Column(
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      Container(
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context, List<Cancion> lista) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xff022527)),
          width: double.infinity,
          height: MediaQuery.of(context).size.height /
              2, // La mitad de la altura de la pantalla
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 6,
                  width: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                ),
              ),
              (lista.isNotEmpty)
                  ? const Expanded(child: CancionesViewCola())
                  : const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "No hay Canciones en la cola",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
//ListarCancionesFavorites(listaCanciones: lista)

class LyricSynchronizer {
  final AudioPlayer player;
  final List<Map<String, dynamic>> lyrics;
  final _lyricController = StreamController<List<String>>.broadcast();
  StreamSubscription<Duration>? lyricSubscription;

  LyricSynchronizer(this.player, this.lyrics) {
    _synchronizeLyrics();
  }

  Stream<List<String>> get currentLyricStream => _lyricController.stream;

  void _synchronizeLyrics() {
    lyricSubscription = player.positionStream.listen((position) {
      final currentTime = position.inMilliseconds;
      int currentIndex = lyrics.indexWhere(
        (lyric) {
          final start = int.parse(lyric['cueRange']['startTimeMilliseconds']);
          final end = int.parse(lyric['cueRange']['endTimeMilliseconds']);
          return currentTime >= start && currentTime < end;
        },
      );

      if (currentIndex != -1) {
        String previousLyric =
            currentIndex > 0 ? lyrics[currentIndex - 1]['lyricLine'] : '';
        String currentLyric = lyrics[currentIndex]['lyricLine'];
        String nextLyric = currentIndex < lyrics.length - 1
            ? lyrics[currentIndex + 1]['lyricLine']
            : '';

        _lyricController.add([previousLyric, currentLyric, nextLyric]);
      } else {
        _lyricController.add(['', '', '']);
      }
    });
  }

  void dispose() {
    lyricSubscription?.cancel();
    _lyricController.close();
  }
}
