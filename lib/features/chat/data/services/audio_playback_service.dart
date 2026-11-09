import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_playback_service.g.dart';

class PlaybackState {
  final String? activeAudioPath;
  final bool isPlaying;
  final Duration position;
  final Duration totalDuration;

  const PlaybackState({
    this.activeAudioPath,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  PlaybackState copyWith({
    String? activeAudioPath,
    bool? isPlaying,
    Duration? position,
    Duration? totalDuration,
  }) {
    return PlaybackState(
      activeAudioPath: activeAudioPath ?? this.activeAudioPath,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();
  final StreamController<PlaybackState> _stateController =
      StreamController<PlaybackState>.broadcast();

  PlaybackState _currentState = const PlaybackState();
  Stream<PlaybackState> get stateStream => _stateController.stream;
  PlaybackState get currentState => _currentState;

  AudioPlaybackService() {
    _initStreams();
  }

  void _initStreams() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing &&
          playerState.processingState != ProcessingState.completed;
      _currentState = _currentState.copyWith(isPlaying: isPlaying);
      _stateController.add(_currentState);

      if (playerState.processingState == ProcessingState.completed) {
        _currentState = _currentState.copyWith(
          isPlaying: false,
          position: Duration.zero,
        );
        _stateController.add(_currentState);
      }
    });

    _player.positionStream.listen((position) {
      _currentState = _currentState.copyWith(position: position);
      _stateController.add(_currentState);
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _currentState = _currentState.copyWith(totalDuration: duration);
        _stateController.add(_currentState);
      }
    });
  }

  Future<void> playAudio(String path) async {
    try {
      if (_currentState.activeAudioPath == path) {
        if (_currentState.isPlaying) {
          await _player.pause();
        } else {
          await _player.play();
        }
        return;
      }

      await _player.stop();
      _currentState = PlaybackState(
        activeAudioPath: path,
        isPlaying: true,
      );
      _stateController.add(_currentState);

      if (path.startsWith('http')) {
        await _player.setUrl(path);
      } else {
        await _player.setFilePath(path);
      }
      await _player.play();
    } catch (_) {
      _currentState = const PlaybackState();
      _stateController.add(_currentState);
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  Future<void> stopAudio() async {
    await _player.stop();
    _currentState = const PlaybackState();
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    _player.dispose();
  }
}

@Riverpod(keepAlive: true)
AudioPlaybackService audioPlaybackService(Ref ref) {
  final service = AudioPlaybackService();
  ref.onDispose(() => service.dispose());
  return service;
}
