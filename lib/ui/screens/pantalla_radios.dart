import 'package:flutter/material.dart';
import '../../modelos/radio_station.dart';

class PantallaRadios extends StatelessWidget {
  final Function(String url, String title) alReproducirRadio;

  const PantallaRadios({Key? key, required this.alReproducirRadio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radios de Paraguay 📻'),
      ),
      body: ListView.builder(
        itemCount: paraguayRadios.length,
        itemBuilder: (context, index) {
          final radio = paraguayRadios[index];
          return ListTile(
            leading: const Icon(Icons.radio, color: Colors.redAccent),
            title: Text(radio.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(radio.dial),
            trailing: const Icon(Icons.play_arrow_rounded, size: 32),
            onTap: () => alReproducirRadio(radio.streamUrl, radio.name),
          );
        },
      ),
    );
  }
}
