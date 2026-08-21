import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';

import '/services/music_service.dart'; 
import '/ui/player/player_controller.dart'; // Importamos el cerebro de la app

class PantallaRadios extends StatelessWidget {
  // Dejamos esto opcional por si el sistema de rutas de la app lo pide, pero no lo usaremos
  final Function(String url, String title)? alReproducirRadio;

  const PantallaRadios({Key? key, this.alReproducirRadio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicServices = Get.find<MusicServices>();
    final playerController = Get.find<PlayerController>(); // Conectamos el controlador

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radios de Paraguay 📻'),
      ),
      body: FutureBuilder<List<MediaItem>>(
        future: musicServices.getLiveRadios(), 
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay radios disponibles en este momento.', style: TextStyle(fontSize: 16)),
            );
          }

          final radiosServidor = snapshot.data!;

          return ListView.builder(
            itemCount: radiosServidor.length,
            itemBuilder: (context, index) {
              final radio = radiosServidor[index];
              
              return ListTile(
                leading: const Icon(Icons.radio, color: Colors.redAccent),
                title: Text(radio.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(radio.artist ?? 'En Vivo'),
                trailing: const Icon(Icons.play_arrow_rounded, size: 32),
                onTap: () {
                  // AQUÍ ESTÁ LA MAGIA: Le pasamos la radio COMPLETA directo al cerebro
                  playerController.playRadioDirect(radio);
                },
              );
            },
          );
        },
      ),
    );
  }
}
