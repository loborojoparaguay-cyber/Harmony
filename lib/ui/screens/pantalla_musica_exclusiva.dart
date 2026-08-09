import 'package0:flutter/material.dart';
import 'servicio_musical_exclusivo.dart';

class PantallaMusicaExclusiva extends StatefulWidget {
  final Function(String streamUrl, String title) alReproducirCancion;

  const PantallaMusicaExclusiva({Key? key, required this.alReproducirCancion})
      : super(key: key);

  @override
  State<PantallaMusicaExclusiva> createState() =>
      _PantallaMusicaExclusivaState();
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
            return const Center(child: Text('No hay canciones disponibles'));
          }

          final canciones = snapshot.data!;
          return ListView.builder(
            itemCount: canciones.length,
            itemBuilder: (context, index) {
              final cancion = canciones[index];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.purple),
                title: Text(cancion.title),
                trailing: const Icon(Icons.play_arrow_rounded),
                onTap: () => widget.alReproducirCancion(
                  cancion.streamUrl,
                  cancion.title,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
