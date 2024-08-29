import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/album.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/artist.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/reproductor.dart';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

//Clase que se encarga del manejo de los datos de las apis, para mostrarlo a al usuario.
class AudioProvider extends ChangeNotifier {
  AudioProvider() {
    obtenerListaMeGusta();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (cancionBucle) {
          player.seek(Duration.zero);
          play();
        } else {
          playNext();
        }
      }
    });
  }

  obtenerListaMeGusta() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //obtengo los datos guardados
    final String? action = prefs.getString('cancionesMeGusta');

    if (action != null) {
      final Map<String, dynamic> jsonData = jsonDecode(action);

      listaCancionesMeGustas = CancionesList.fromJson(jsonData);

      for (Cancion cancion in listaCancionesMeGustas) {
        conjuntoCanciones.add(cancion);
      }
    }
  }

  borrarCancionDeMeGusta(Cancion cancion) async {
    listaCancionesMeGustas.remove(cancion);
    conjuntoCanciones.remove(cancion);
    listaCancionesPorReproducir.remove(cancion);
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    CancionesList listCanciones =
        CancionesList(canciones: listaCancionesMeGustas);
    await prefs.setString('cancionesMeGusta', listCanciones.toJson());
  }

  void bucleCancion() {
    cancionBucle = !cancionBucle;
    notifyListeners();
  }

  //reproducir en bucle
  bool cancionBucle = false;

  //Lista de artistas
  List<Artist> listaArtistas = [];

  //Lista de albunes
  List<Album> listaAlbunes = [];

  //album seleccionada para visualizar
  Album albumSeleccionado = Album();

  //cancion seleccionada para reproducir
  Cancion cancionSeleccionado = Cancion();

  //Lista de canciones
  List<Cancion> listaCanciones = [];

  //Lista de cola de canciones
  List<Cancion> listaCancionesPorReproducir = [];

  //Lista de canciones
  List<Cancion> listaCancionesMeGustas = [];
  Set<Cancion> conjuntoCanciones = <Cancion>{};

  //El que se encarga de reproducir el audio
  final player = AudioPlayer();

  //Nos indica si se esta cargando el audio
  bool isLoading = false;

  //bool que nos indica si se esta reproduciendo o no
  bool reproduciendo = false;

  LyricSynchronizer? lyricSynchronizer;
  ValueNotifier<List<String>> currentLyrics = ValueNotifier(['', '', '']);

  @override
  void dispose() {
    player.dispose();
    lyricSynchronizer?.dispose();
    currentLyrics.dispose();
    super.dispose();
  }

  void agregarCancion(Cancion cancion) {
    if (conjuntoCanciones.add(cancion)) {
      listaCancionesMeGustas.add(cancion);
    } else {}
  }

  //Recibe el id del video y devuelve un link del audio del video.
  Future<String> obtenerUrlDelAudio(String idVideo) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(idVideo);
    var audio = manifest.audioOnly.withHighestBitrate();
    yt.close();
    return audio.url.toString();
  }

  //Obtener info de la api de youtube,
  //Filtros:
  //0: artists
  //1: song
  //2: albums
  Future<void> apiYoutube(String artista, int filtro,
      {String albumId = ""}) async {
    String filtrer = "";

    switch (filtro) {
      case 0:
        filtrer = "artists";
        break;
      case 1:
        filtrer = "song";
        break;
      case 2:
        filtrer = "albums";
        break;
    }
    final url = Uri.parse(
        'https://youtube-music-api3.p.rapidapi.com/search?q=$artista&type=$filtrer');
    final headers = {
      'x-rapidapi-key': '1b7ebc615amsh0e92916a60ff015p1f1bd5jsnf45ce63c33df',
      'x-rapidapi-host': 'youtube-music-api3.p.rapidapi.com',
    };

    final response = await http.get(url, headers: headers);

    String jsonString = response.body;

    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    switch (filtro) {
      case 0:
        listaArtistas = [];
        notifyListeners();
        listaArtistas = ArtistList.fromJson(jsonData);
        break;
      case 1:
        listaCanciones = [];
        notifyListeners();
        listaCanciones = CancionesList.fromJson(jsonData);
        break;
      case 2:
        listaAlbunes = [];
        notifyListeners();
        listaAlbunes = AlbumList.fromJson(jsonData);
        break;
      case 3:
        final url = Uri.parse(
            'https://youtube-music-api3.p.rapidapi.com/getAlbum?id=$albumId');
        final headers = {
          'x-rapidapi-key':
              '1b7ebc615amsh0e92916a60ff015p1f1bd5jsnf45ce63c33df',
          'x-rapidapi-host': 'youtube-music-api3.p.rapidapi.com',
        };

        final response = await http.get(url, headers: headers);

        String jsonString = response.body;

        Map<String, dynamic> jsonData = jsonDecode(jsonString);

        albumSeleccionado = Album();
        notifyListeners();
        albumSeleccionado = Album.fromJson(jsonData);

        break;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSyncedLyrics(String lyricsId) async {
    final url = Uri.parse(
        'https://youtube-music-api3.p.rapidapi.com/music/lyrics/synced?id=$lyricsId&format=json');
    final headers = {
      'x-rapidapi-key': '1b7ebc615amsh0e92916a60ff015p1f1bd5jsnf45ce63c33df',
      'x-rapidapi-host': 'youtube-music-api3.p.rapidapi.com'
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonResult = json.decode(response.body);
        return jsonResult.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<void> obtenerIdLetra(String idVideo) async {
    final url = Uri.parse(
        'https://youtube-music-api3.p.rapidapi.com/v2/next?id=$idVideo');
    final headers = {
      'x-rapidapi-key': '1b7ebc615amsh0e92916a60ff015p1f1bd5jsnf45ce63c33df',
      'x-rapidapi-host': 'youtube-music-api3.p.rapidapi.com',
    };

    final response = await http.get(url, headers: headers);

    String jsonString = response.body;

    // Decodifica el JSON string a un Map
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Extrae el valor de 'lyricsId'
    String lyricsId = jsonMap['lyricsId'];

    cancionSeleccionado.lyricsId = lyricsId;
  }

  StreamSubscription<List<String>>? lyricSubscription;

  Future<void> actualizarUrl(String videoId) async {
    try {
      isLoading = true;
      notifyListeners();

      if (player.playing) {
        stop();
      }

      String url = "https://www.youtube.com/watch?v=$videoId";
      final String urlAudio = await obtenerUrlDelAudio(url);
      await player.setUrl(urlAudio);

      // Obtener el ID de la letra
      await obtenerIdLetra(videoId);

      // Obtener letras sincronizadas
      if (cancionSeleccionado.lyricsId.isNotEmpty) {
        final syncedLyrics =
            await fetchSyncedLyrics(cancionSeleccionado.lyricsId);

        if (lyricSynchronizer != null) {
          lyricSubscription?.cancel();
          lyricSynchronizer!
              .dispose(); // Limpia recursos del antiguo LyricSynchronizer
          lyricSynchronizer = null;
        }
        currentLyrics = ValueNotifier(['', '', '']);
        lyricSynchronizer = LyricSynchronizer(player, syncedLyrics);
        lyricSubscription =
            lyricSynchronizer!.currentLyricStream.listen((lyrics) {
          currentLyrics.value = lyrics;
        });
      }

      play();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  //funcion que se encarga de reproducir el audio
  void play() {
    player.play();
    notifyListeners();
  }

  //funcion que se encarga de detener el audio
  void stop() {
    player.stop();
    reproduciendo = false;
    notifyListeners();
  }

  //funcion que se encarga de poner en pausa el audio
  void pause() {
    player.pause();
    notifyListeners();
  }

  int _currentIndex = 0;

  void addToQueue(Cancion cancion) {
    listaCancionesPorReproducir.add(cancion);
    notifyListeners();
  }

  void _playCurrent() async {
    if (_currentIndex < listaCancionesPorReproducir.length) {
      actualizarUrl(listaCancionesPorReproducir[_currentIndex].videoId);
    }
  }

  void playNext() {
    if (_currentIndex < listaCancionesPorReproducir.length - 1) {
      _currentIndex++;
      cancionSeleccionado = listaCancionesPorReproducir[_currentIndex];
      _playCurrent();
      notifyListeners();
    }
  }

  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      cancionSeleccionado = listaCancionesPorReproducir[_currentIndex];
      _playCurrent();
      notifyListeners();
    }
  }

  void actualizar() {
    notifyListeners();
  }
}
