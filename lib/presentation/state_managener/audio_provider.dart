import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/album.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/artist.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/cancion.dart';
import 'package:vinyl_sound_oficial/presentation/domain/entitis/playlist.dart';
import 'package:vinyl_sound_oficial/presentation/screens/biblioteca.dart';
import 'package:vinyl_sound_oficial/presentation/widgets/reproductor.dart';
import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

//Clase que se encarga del manejo de los datos de las apis, para mostrarlo a al usuario.
class AudioProvider extends ChangeNotifier {
  bool _isHandlingCompletion = false;
  AudioProvider() {
    obtenerListaMeGusta();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_isHandlingCompletion) return;
        _isHandlingCompletion = true;
        if (cancionBucle) {
          player.seek(Duration.zero);
          play();
        } else {
          playNext();
        }
        // Restablecer el flag después de un breve delay para permitir futuras ejecuciones
        Future.delayed(const Duration(milliseconds: 500), () {
          _isHandlingCompletion = false;
        });
      }
    });
  }

  obtenerListaMeGusta() async {
    listasDePlaylists = await obtenerPlaylists();
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
  bool miniReproduciendo = false;

  LyricSynchronizer? lyricSynchronizer;
  ValueNotifier<List<String>> currentLyrics = ValueNotifier(['', '', '']);

  @override
  void dispose() {
    player.dispose();
    lyricSynchronizer?.dispose();
    currentLyrics.dispose();
    super.dispose();
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
    miniReproduciendo = false;
    notifyListeners();
  }

  //funcion que se encarga de poner en pausa el audio
  void pause() {
    player.pause();
    notifyListeners();
  }

  int _currentIndex = 0;

  void _playCurrent() async {
    if (_currentIndex < listaCancionesPorReproducir.length) {
      empezarEscucharCancion(cancionSeleccionado);
    }
  }

  bool _isPlayingNext = false;

  void playNext() {
    if (_isPlayingNext) {
      return;
    } // Salir si ya se está reproduciendo la siguiente canción
    _isPlayingNext = true;

    if (_currentIndex < listaCancionesPorReproducir.length - 1) {
      _currentIndex++;
      cancionSeleccionado = listaCancionesPorReproducir[_currentIndex];
      _playCurrent();
      notifyListeners();
    }

    // Restablecer el flag
    _isPlayingNext = false;
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

  void eliminarCancionDeListaPorReproducir(Cancion cancion) {
    // Busca la canción en la lista y la elimina si existe
    if (listaCancionesPorReproducir.contains(cancion)) {
      listaCancionesPorReproducir.remove(cancion);
      // Si la canción eliminada era la que se estaba reproduciendo, actualiza la reproducción
      if (cancionSeleccionado == cancion) {
        if (_currentIndex >= listaCancionesPorReproducir.length) {
          _currentIndex = 0; // Resetea el índice si estaba en la última canción
        }
        if (listaCancionesPorReproducir.isNotEmpty) {
          cancionSeleccionado = listaCancionesPorReproducir[_currentIndex];
          _playCurrent();
        } else {
          stop(); // Detiene la reproducción si no quedan más canciones
        }
      }
      notifyListeners();
    }
  }

  void agregarCancionDespuesDeActual(Cancion nuevaCancion, bool reproduccion) {
    // Si la lista está vacía, simplemente añade la canción y comienza a reproducirla
    if (listaCancionesPorReproducir.isEmpty) {
      listaCancionesPorReproducir.add(nuevaCancion);
      cancionSeleccionado = nuevaCancion;
      _currentIndex = 0;
      if (reproduccion) {
        _playCurrent();
      }
    } else {
      // Inserta la nueva canción después de la canción actualmente en reproducción
      int indexActual = _currentIndex;
      listaCancionesPorReproducir.insert(indexActual + 1, nuevaCancion);
    }

    // Notifica a los listeners para actualizar la UI
    notifyListeners();
  }

  bool estaCancionEnReproduccion(Cancion cancion) {
    // Verifica si la canción está en la lista de canciones por reproducir
    if (listaCancionesPorReproducir.contains(cancion)) {
      // Verifica si la canción en reproducción actualmente es la misma que la proporcionada
      return player.playing && cancionSeleccionado == cancion;
    }
    // Si la canción no está en la lista, retorna false
    return false;
  }

  Future<void> empezarEscucharCancion(Cancion cancion) async {
    // Encuentra el índice de la canción en la lista de canciones por reproducir
    int index = listaCancionesPorReproducir.indexOf(cancion);

    // Si la canción no está en la lista
    if (index == -1) {
      if (listaCancionesPorReproducir.isEmpty) {
        cancionSeleccionado = Cancion();
        cancionSeleccionado = cancion;
        // La lista está vacía, agrega la canción y empieza a reproducirla
        listaCancionesPorReproducir.add(cancion);
        _currentIndex = 0;
        await actualizarUrl(
            cancion.videoId); // Asegúrate de que cancion tenga el videoId
        play();
      } else {
        if (!listaCancionesPorReproducir.contains(cancion)) {
          cancionSeleccionado = Cancion();
          cancionSeleccionado = cancion;
          // La lista no está vacía, agrega la canción antes del elemento actualmente seleccionado
          int currentIndex = _currentIndex;
          // Asegúrate de que el índice sea válido
          if (currentIndex > listaCancionesPorReproducir.length - 1) {
            currentIndex = listaCancionesPorReproducir.length - 1;
          }
          listaCancionesPorReproducir.insert(currentIndex, cancion);
          _currentIndex = currentIndex;
          await actualizarUrl(
              cancion.videoId); // Asegúrate de que cancion tenga el videoId
          play();
        } else {
          cancionSeleccionado = Cancion();
          cancionSeleccionado = cancion;
          await actualizarUrl(
              cancion.videoId); // Asegúrate de que cancion tenga el videoId
          play();
        }
      }
    } else {
      cancionSeleccionado = Cancion();
      cancionSeleccionado = cancion;
      // La canción ya está en la lista, actualiza el índice y empieza a reproducir
      _currentIndex = index;
      await actualizarUrl(
          cancion.videoId); // Asegúrate de que cancion tenga el videoId
      play();
    }

    // Notifica a los listeners para actualizar la UI
    notifyListeners();
  }

  //Parte para de la lista de reproduccion
  List<PlaylistMyApp> listasDePlaylists = [];

  Future<void> crearPlaylist(String nombrePlaylist) async {
    List<Cancion> canciones = [];
    listasDePlaylists
        .add(PlaylistMyApp(nombre: nombrePlaylist, canciones: canciones));

    guardarPlaylistsEnPreferencias(listasDePlaylists);
  }

  Future<List<PlaylistMyApp>> obtenerPlaylists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Recupera la lista actual de playlists guardadas
    String? playlistsJson = prefs.getString('playlists');
    List<PlaylistMyApp> playlists = [];

    if (playlistsJson != null) {
      // Convierte el JSON de playlists a una lista de objetos Playlist
      playlists = PlaylistsList.fromJson(jsonDecode(playlistsJson)).playlists;
    }

    //Verifica si la playlist de "Favoritos" ya existe
    bool favoritosExiste =
        playlists.any((playlist) => playlist.nombre == 'Favoritos');

    if (!favoritosExiste) {
      // Si no existe, la crea y la agrega a la lista
      PlaylistMyApp favoritos =
          PlaylistMyApp(nombre: 'Favoritos', canciones: []);
      playlists.add(favoritos);

      // Guarda la lista actualizada en SharedPreferences
      await guardarPlaylistsEnPreferencias(playlists);
    }

    return playlists;
  }

  Future<void> guardarPlaylistsEnPreferencias(
      List<PlaylistMyApp> playlists) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convierte la lista de playlists a JSON y la guarda en SharedPreferences
    String playlistsJson = PlaylistsList(playlists: playlists).toJson();
    await prefs.setString('playlists', playlistsJson);
    notifyListeners();
  }

  Future<void> borrarPlaylist(String nombrePlaylist) async {
    // Filtra para eliminar la playlist específica
    listasDePlaylists
        .removeWhere((playlist) => playlist.nombre == nombrePlaylist);

    guardarPlaylistsEnPreferencias(listasDePlaylists);

    notifyListeners();
  }

  Future<void> borrarCancionDePlaylist(
      String nombrePlaylist, String videoIdCancion) async {
    // Busca la playlist específica y elimina la canción
    for (PlaylistMyApp playlist in listasDePlaylists) {
      if (playlist.nombre == nombrePlaylist) {
        playlist.canciones
            .removeWhere((cancion) => cancion.videoId == videoIdCancion);
        break;
      }
    }

    guardarPlaylistsEnPreferencias(listasDePlaylists);
  }

  Future<void> modificarNombrePlaylist(
      String nombrePlaylist, String nuevoNombre) async {
    // Busca la playlist específica y elimina la canción
    for (PlaylistMyApp playlist in listasDePlaylists) {
      if (playlist.nombre == nombrePlaylist) {
        playlist.nombre = nuevoNombre;
        break;
      }
    }
    guardarPlaylistsEnPreferencias(listasDePlaylists);
  }

  Future<bool> agregarCancionAPlaylist(
      String nombrePlaylist, Cancion nuevaCancion) async {
    // Buscar la playlist por nombre
    final playlist = listasDePlaylists.firstWhere(
      (playlist) => playlist.nombre == nombrePlaylist,
      orElse: () => PlaylistMyApp(nombre: nombrePlaylist, canciones: []),
    );

    // Verificar si la canción ya existe en la playlist
    bool cancionYaExiste = playlist.canciones
        .any((cancion) => cancion.videoId == nuevaCancion.videoId);

    if (!cancionYaExiste) {
      // Agregar la canción si no existe
      playlist.canciones.add(nuevaCancion);
    } else {
      return false; // Salir de la función si ya existe
    }

    guardarPlaylistsEnPreferencias(listasDePlaylists);
    return true;
  }
}
