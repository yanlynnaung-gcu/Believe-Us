import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'audio_recorder_service.g.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final Uuid _uuid = const Uuid();

  Timer? _amplitudeTimer;
  final List<double> _waveformSamples = [];
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;

  bool _isRecording = false;
  bool get isRecording => _isRecording;
  List<double> get waveformSamples => List.unmodifiable(_waveformSamples);

  Future<bool> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return false;

      final tempDir = await getTemporaryDirectory();
      final fileName = 'voice_${_uuid.v4().substring(0, 8)}.m4a';
      _currentRecordingPath = '${tempDir.path}/$fileName';

      _waveformSamples.clear();
      _recordingStartTime = DateTime.now();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;

      // Sample amplitudes for visual waveform
      _amplitudeTimer?.cancel();
      _amplitudeTimer =
          Timer.periodic(const Duration(milliseconds: 100), (_) async {
        try {
          final amp = await _recorder.getAmplitude();
          // Normalize dBFS (-60 to 0) to 0.1 to 1.0
          final current = amp.current;
          final normalized = ((current + 60.0) / 60.0).clamp(0.1, 1.0);
          _waveformSamples.add(normalized);
        } catch (_) {}
      });

      return true;
    } catch (_) {
      _isRecording = false;
      return false;
    }
  }

  Future<({String path, int durationSeconds, List<double> waveforms})?>
      stopRecording() async {
    if (!_isRecording) return null;

    try {
      _amplitudeTimer?.cancel();
      _isRecording = false;

      final path = await _recorder.stop();
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 1;

      final targetPath = path ?? _currentRecordingPath;
      if (targetPath == null || !File(targetPath).existsSync()) {
        return null;
      }

      // Downsample or smooth waveform samples to ~25 bars for UI bubble
      final samples = _normalizeWaveformSamples(_waveformSamples);

      return (
        path: targetPath,
        durationSeconds: duration < 1 ? 1 : duration,
        waveforms: samples,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _amplitudeTimer?.cancel();
    _isRecording = false;
    try {
      final path = await _recorder.stop();
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
    } catch (_) {}
  }

  List<double> _normalizeWaveformSamples(List<double> input) {
    if (input.isEmpty) {
      return [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 0.5, 0.7, 0.3];
    }
    const targetCount = 24;
    if (input.length <= targetCount) {
      return input;
    }
    final step = input.length / targetCount;
    final result = <double>[];
    for (int i = 0; i < targetCount; i++) {
      final index = (i * step).floor().clamp(0, input.length - 1);
      result.add(input[index]);
    }
    return result;
  }

  void dispose() {
    _amplitudeTimer?.cancel();
    _recorder.dispose();
  }
}

@Riverpod(keepAlive: true)
AudioRecorderService audioRecorderService(Ref ref) {
  final service = AudioRecorderService();
  ref.onDispose(() => service.dispose());
  return service;
}
