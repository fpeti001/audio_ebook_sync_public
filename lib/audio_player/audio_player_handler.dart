import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  static final _item = MediaItem(
    id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );
  static AudioPlayer _player = AudioPlayer();


  String path='';
  AudioPlayerHandler() {
    mediaItem.add(_item);
  path='/data/user/0/com.example.audio_ebook_sync/cache/file_picker/A Court of Thorns and Roses.mp3';
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.ready,
    ));
//     _player.setFilePath('/data/user/0/com.example.proba/cache/file_picker/A Court of Mist and Fury.mp3');
  }
  getAudioPlayer(){
    return _player;
  }

  @override
  Future<void> play() async {
   // Duration? _position = const Duration();
    print('playyyy');
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    await _player.play(path);
  }

  @override
  Future<void> pause() async {
    print('pausseeeeeee');
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));

    await _player.pause();
  }
  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
      processingState: AudioProcessingState.idle,
    ));
  }
}

