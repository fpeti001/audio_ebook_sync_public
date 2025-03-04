import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audio_ebook_sync/audio_player/audio_player_handler.dart';

class PlayerWidget extends StatefulWidget {

  final String url;
  final PlayerMode mode;

  const PlayerWidget({
    Key? key,
    required this.url,
    this.mode = PlayerMode.MEDIA_PLAYER,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {

  AudioPlayerHandler _audioHandler=AudioPlayerHandler();
  bool beforePlayd=false;
  String url;
  PlayerMode mode;

  late AudioPlayer _audioPlayer;
  PlayerState? _audioPlayerState;
  Duration? _duration;
  Duration? _position;

  PlayerState _playerState = PlayerState.STOPPED;
  PlayingRoute _playingRouteState = PlayingRoute.SPEAKERS;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerErrorSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription<PlayerControlCommand>? _playerControlCommandSubscription;

  bool get _isPlaying => _playerState == PlayerState.PLAYING;
  bool get _isPaused => _playerState == PlayerState.PAUSED;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  bool get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRoute.EARPIECE;

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    initStateAsyc();
    super.initState();

  }
  initStateAsyc()async{
    _initAudioPlayer();
    print('iniit');
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );

    _audioHandler.playbackState.listen((PlaybackState state) async{
      print('playing ${state.playing} beforplayd ${beforePlayd}');
      if(state.playing!=beforePlayd){
        if(state.playing){
          beforePlayd=true;
            setState(() => _playerState = PlayerState.PLAYING);

        }else{
          beforePlayd=false;
            setState(() => _playerState = PlayerState.PAUSED);

        }
      }
     print('stateeee: ${state.playing}');
    });

  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _playerControlCommandSubscription?.cancel();
    super.dispose();
  }
  changePosition(int sec)async{
    print('positon in sec: ${_position!.inSeconds}');
    await _audioPlayer.seek(Duration(seconds:_position!.inSeconds+ sec));

  }

  @override
  Widget build(BuildContext context) {

    return  Center(
      child: StreamBuilder<PlaybackState>(
        stream: _audioHandler.playbackState,
        builder: (context, snapshot) {
     //     var duration = snapshot.data;
       //   print('duratioooooons $duration');
          final playing = snapshot.data?.playing ?? false;
          final processingState = snapshot.data?.processingState
              ?? AudioProcessingState.idle;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /*    Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _audioHandler.play,
              iconSize: 64.0,
              icon: const Icon(Icons.play_arrow),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ?  _audioHandler.pause : null,
              iconSize: 64.0,
              icon: const Icon(Icons.pause),
              color: Colors.cyan,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 64.0,
              icon: const Icon(Icons.stop),
              color: Colors.cyan,
            ),
            IconButton(
              onPressed: _earpieceOrSpeakersToggle,
              iconSize: 64.0,
              icon: _isPlayingThroughEarpiece
                  ? const Icon(Icons.volume_up)
                  : const Icon(Icons.hearing),
              color: Colors.cyan,
            ),
          ],
        ),*/
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Stack(
                      children: [
                        Slider(
                          onChanged: (v) {
                            final duration = _duration;
                            if (duration == null) {
                              return;
                            }
                           // var positasdion =_audioHandler.playbackState?.position.inSeconds.toDouble();
                            final Position = v * duration.inMilliseconds;
                            _audioPlayer
                                .seek(Duration(milliseconds: Position.round()));
                          },
                          value: (_position != null &&
                              _duration != null &&
                              _position!.inMilliseconds > 0 &&
                              _position!.inMilliseconds <
                                  _duration!.inMilliseconds)
                              ? _position!.inMilliseconds / _duration!.inMilliseconds
                              : 0.0,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _position != null
                        ? '$_positionText / $_durationText'
                        : _duration != null
                        ? _durationText
                        : '',
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
              Text('State: $_audioPlayerState'),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: IconButton(onPressed: (){changePosition(-60);}, icon:Icon(Icons.arrow_back_rounded) )),
                  Expanded(child: IconButton(onPressed: (){changePosition(-15);}, icon:Icon(Icons.arrow_back_ios_rounded) )),

                  Expanded(child: IconButton(
                    icon: (_isPlaying)
                        ? Icon(Icons.pause_circle_filled)
                        : Icon(Icons.play_circle_outline),
                    iconSize: 40,
                  //  onPressed: () => _isPlaying ? _pause() : _isPaused ? _play() : _play(),
                    onPressed: () => _isPlaying ? _audioHandler.pause() : _isPaused ? _audioHandler.play() : _audioHandler.play(),
                  )),
                  //   Expanded(child: IconButton(onPressed: (){}, icon:Icon(Icons.play_circle_outline ) )),
                  Expanded(child: IconButton(onPressed: (){changePosition(15);}, icon:Icon(Icons.arrow_forward_ios_rounded ) )),
                  Expanded(child: IconButton(onPressed: (){changePosition(60);}, icon:Icon(Icons.arrow_forward_rounded ) )),



                ],),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: TextButton(onPressed: (){}, child: Text('-1m'))),
                  Expanded(child: TextButton(onPressed: (){}, child: Text('-15s'))),
                  Expanded(child: TextButton(onPressed: (){}, child: Text(''))),
                  Expanded(child: TextButton(onPressed: (){}, child: Text('+15s'))),
                  Expanded(child: TextButton(onPressed: (){}, child: Text('+1m'))),


                ],),

              if (playing)
                ElevatedButton(child: Text("Pause"), onPressed: _audioHandler.pause)
              else
                ElevatedButton(child: Text("Play"), onPressed: _audioHandler.play),







            ],
          );
        },
      ),
    );

  }

  void _initAudioPlayer() {
    _audioPlayer = _audioHandler.getAudioPlayer();

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // optional: listen for notification updates in the background
        _audioPlayer.notificationService.startHeadlessService();

        // set at least title to see the notification bar on ios.
        _audioPlayer.notificationService.setNotification(
          title: 'App Name',
          artist: 'Artist or blank',
          albumTitle: 'Name or blank',
          imageUrl: 'Image URL or blank',
          forwardSkipInterval: const Duration(seconds: 30), // default is 30s
          backwardSkipInterval: const Duration(seconds: 30), // default is 30s
          duration: duration,
          enableNextTrackButton: true,
          enablePreviousTrackButton: true,
        );
      }
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        _playerState = PlayerState.STOPPED;
        _duration = const Duration();
        _position = const Duration();
      });
    });

    _playerControlCommandSubscription =
        _audioPlayer.notificationService.onPlayerCommand.listen((command) {
      print('command: $command');
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _audioPlayerState = state);
      }
    });

    _playingRouteState = PlayingRoute.SPEAKERS;
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position!.inMilliseconds > 0 &&
            _position!.inMilliseconds < _duration!.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1) {
      setState(() => _playerState = PlayerState.PLAYING);
    }

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() => _playerState = PlayerState.PAUSED);
    }
    return result;
  }

  Future<int> _earpieceOrSpeakersToggle() async {
    final result = await _audioPlayer.earpieceOrSpeakersToggle();
    if (result == 1) {
      setState(() => _playingRouteState = _playingRouteState.toggle());
    }
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.STOPPED;
        _position = const Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    setState(() => _playerState = PlayerState.STOPPED);
  }
}
