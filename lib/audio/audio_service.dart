import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final _player = AudioPlayer();
  static Uint8List? _moveWav;
  static Uint8List? _winWav;
  static Uint8List? _drawWav;

  static Uint8List _generateTone(int freq, int durationMs) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(numSamples);
    for (var i = 0; i < numSamples; i++) {
      final envelope = (1.0 - (i / numSamples)) * 0.5;
      samples[i] = (32767 * envelope * sin(2 * pi * freq * i / sampleRate)).round();
    }
    return _encodeWav(samples, sampleRate);
  }

  static Uint8List _generateMultiTone(List<int> freqs, int toneDurationMs) {
    const sampleRate = 44100;
    final totalSamples = (sampleRate * freqs.length * toneDurationMs / 1000).round();
    final samples = Int16List(totalSamples);
    final samplesPerTone = totalSamples ~/ freqs.length;
    for (var t = 0; t < freqs.length; t++) {
      final freq = freqs[t];
      for (var i = 0; i < samplesPerTone; i++) {
        final idx = t * samplesPerTone + i;
        final envelope = (1.0 - (i / samplesPerTone)) * 0.5;
        samples[idx] = (32767 * envelope * sin(2 * pi * freq * i / sampleRate)).round();
      }
    }
    return _encodeWav(samples, sampleRate);
  }

  static Uint8List _encodeWav(Int16List samples, int sampleRate) {
    final dataSize = samples.length * 2;
    final fileSize = 36 + dataSize;
    final bytes = ByteData(44 + dataSize);

    bytes.setUint8(0, 0x52); bytes.setUint8(1, 0x49);
    bytes.setUint8(2, 0x46); bytes.setUint8(3, 0x46);
    bytes.setUint32(4, fileSize, Endian.little);
    bytes.setUint8(8, 0x57); bytes.setUint8(9, 0x41);
    bytes.setUint8(10, 0x56); bytes.setUint8(11, 0x45);

    bytes.setUint8(12, 0x66); bytes.setUint8(13, 0x6D);
    bytes.setUint8(14, 0x74); bytes.setUint8(15, 0x20);
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);

    bytes.setUint8(36, 0x64); bytes.setUint8(37, 0x61);
    bytes.setUint8(38, 0x74); bytes.setUint8(39, 0x61);
    bytes.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < samples.length; i++) {
      bytes.setInt16(44 + i * 2, samples[i], Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  static Future<void> init() async {
    _moveWav ??= _generateTone(600, 60);
    _winWav ??= _generateMultiTone([523, 659, 784], 120);
    _drawWav ??= _generateMultiTone([400, 300, 200], 100);
  }

  static Future<void> playMove() async {
    await init();
    await _player.play(BytesSource(_moveWav!));
  }

  static Future<void> playWin() async {
    await init();
    await _player.play(BytesSource(_winWav!));
  }

  static Future<void> playDraw() async {
    await init();
    await _player.play(BytesSource(_drawWav!));
  }
}
