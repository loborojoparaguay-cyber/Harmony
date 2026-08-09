class RadioStation {
  final String name;
  final String dial;
  final String streamUrl;

  RadioStation({
    required this.name,
    required this.dial,
    required this.streamUrl,
  });
}

final List<RadioStation> paraguayRadios = [
  RadioStation(
    name: 'Station 40',
    dial: '91.1 FM',
    streamUrl: 'https://stream.s40.com.py/stream',
  ),
  RadioStation(
    name: 'Los 40 Paraguay',
    dial: '92.3 FM',
    streamUrl: 'https://stream.los40.com.py/los40',
  ),
  RadioStation(
    name: 'Radio Palma',
    dial: '106.5 FM',
    streamUrl: 'https://stream.palma.com.py/palma',
  ),
  RadioStation(
    name: 'Radio Urbana',
    dial: '106.9 FM',
    streamUrl: 'https://stream.urbana.com.py/urbana',
  ),
  RadioStation(
    name: 'Radio Disney Paraguay',
    dial: '96.5 FM',
    streamUrl: 'https://stream.disney.com.py/disney',
  ),
];
