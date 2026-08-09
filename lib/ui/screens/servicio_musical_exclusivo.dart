import 'package:flutter/material.dart';
import 'servicio_musical_exclusivo.dart';

class PantallaMusicaExclusiva extends StatefulWidget {
  final Function(String streamUrl, String title) alReproducirCancion;

  const PantallaMusicaExclusiva({Key? key, required this.alReproducirCancion}) : super(key: key);

  @override
  State<PantallaMusicaExclusiva> createState() => _PantallaMusicaExclusivaState();
}

class _PantallaMusicaExclusivaState extends State<PantallaMusicaExclusiva> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Músicas Exclusivas 🎵'),
      ),
      body: FutureBuilder<List<DriveSong>>(
        future: ExclusiveMusicService.fetchExclusiveSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron canciones exclusivas.'));
          }

          final canciones = snapshot.data!;
          return ListView.builder(
            itemCount: canciones.length,
            itemBuilder: (context, index) {
              final cancion = canciones[index];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.amber),
                title: Text(cancion.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.play_circle_fill, color: Colors.amber, size: 32),
                onTap: () => widget.alReproducirCancion(cancion.streamUrl, cancion.title),
              );
            },
          );
        },
      ),
    );
  }
}
