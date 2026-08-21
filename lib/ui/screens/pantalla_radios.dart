import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';

// Asegúrate de que esta ruta apunte correctamente a tu archivo music_service.dart
import '/services/music_service.dart'; 

class PantallaRadios extends StatelessWidget {
  final Function(String url, String title) alReproducirRadio;

  const PantallaRadios({Key? key, required this.alReproducirRadio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instanciamos el servicio que se comunica con tu servidor
    final musicServices = Get.find<MusicServices>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radios de Paraguay 📻'),
      ),
      // Usamos FutureBuilder para preguntarle a la VPS antes de dibujar
      body: FutureBuilder<List<MediaItem>>(
        future: musicServices.getLiveRadios(), // Esta es la función que agregamos antes
        builder: (context, snapshot) {
          
          // 1. MIENTRAS CARGA: Mostramos el circulito de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          // 2. SI HAY ERROR O ESTÁ VACÍO
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay radios disponibles en este momento.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 3. EL SERVIDOR RESPONDIÓ: Dibujamos tu misma lista exacta
          final radiosServidor = snapshot.data!;

          return ListView.builder(
            itemCount: radiosServidor.length,
            itemBuilder: (context, index) {
              final radio = radiosServidor[index];
              
              return ListTile(
                leading: const Icon(Icons.radio, color: Colors.redAccent),
                title: Text(radio.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(radio.artist ?? 'En Vivo'), // Muestra "En Vivo" o la frecuencia
                trailing: const Icon(Icons.play_arrow_rounded, size: 32),
                onTap: () {
                  // Sacamos el enlace directo que el servidor guardó en 'extras'
                  final streamUrl = radio.extras?['url'] ?? radio.id;
                  alReproducirRadio(streamUrl, radio.title);
                },
              );
            },
          );
        },
      ),
    );
  }
}
