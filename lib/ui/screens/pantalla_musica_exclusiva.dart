import 'package:flutter/material.dart';
import 'servicio_musical_exclusivo.dart';

class PantallaMusicaExclusiva extends StatefulWidget {
  final Function(List<DriveSong> lista, int index) alReproducirLista;

  const PantallaMusicaExclusiva({
    super.key,
    required this.alReproducirLista,
  });

  @override
  State<PantallaMusicaExclusiva> createState() => _PantallaMusicaExclusivaState();
}

class _PantallaMusicaExclusivaState extends State<PantallaMusicaExclusiva> {
  List<DriveSong> todasLasCanciones = [];
  Map<String, List<DriveSong>> cancionesPorCarpeta = {};
  bool cargando = true;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCanciones();
  }

  Future<void> _cargarCanciones() async {
    final canciones = await ExclusiveMusicService.fetchExclusiveSongs();
    _agruparYFiltrar(canciones, '');
  }

  void _agruparYFiltrar(List<DriveSong> canciones, String query) {
    final filtradas = query.isEmpty
        ? canciones
        : canciones.where((s) => s.title.toLowerCase().contains(query.toLowerCase())).toList();

    Map<String, List<DriveSong>> agrupadas = {};
    for (var song in filtradas) {
      agrupadas.putIfAbsent(song.folderName, () => []).add(song);
    }

    setState(() {
      todasLasCanciones = canciones;
      cancionesPorCarpeta = agrupadas;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Músicas Exclusivas 🎵'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _busquedaController,
              onChanged: (q) => _agruparYFiltrar(todasLasCanciones, q),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar canción...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: cancionesPorCarpeta.entries.map((entry) {
                      final nombreCarpeta = entry.key;
                      final listaCanciones = entry.value;

                      return ExpansionTile(
                        leading: const Icon(Icons.folder, color: Colors.amber),
                        title: Text(
                          nombreCarpeta,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${listaCanciones.length} canciones',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        children: listaCanciones.asMap().entries.map((item) {
                          final index = item.key;
                          final song = item.value;

                          return ListTile(
                            leading: const Icon(Icons.music_note, color: Colors.purpleAccent),
                            title: Text(
                              song.title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(Icons.play_arrow, color: Colors.white),
                            onTap: () {
                              widget.alReproducirLista(listaCanciones, index);
                            },
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
