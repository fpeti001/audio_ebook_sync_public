import 'dart:io';

import 'package:audio_ebook_sync/audio_player/audio_player_handler.dart';
import 'package:audio_ebook_sync/audio_player/player_widget.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
 // String localPath='/data/user/0/com.example.audio_ebook_sync/cache/file_picker/A Court of Thorns and Roses.mp3';
  String localPath='';
  PPP ppp=PPP();
  AudioPlayerHandler _audioHandler=AudioPlayerHandler();
 late AudioPlayer audioPlayer;

  playLocal() async {
    int result = await audioPlayer.play(localPath, isLocal: true);
    // int result = await audioPlayer.play('/data/user/0/com.example.proba/cache/file_picker/A Court of Mist and Fury.mp3', isLocal: true);

  }

  pickingFile()async{
    String filepath='';
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      filepath=file.path;
    } else {
      // User canceled the picker
    }
    localPath=filepath;
    await ppp.pMSharedStringSet('path', filepath);
    print('filepick finish path: $filepath-----------------------------------');
  }
  stopPlayer()async{
    int result = await audioPlayer.stop();
  }
  jump()async{
    int result = await audioPlayer.seek(Duration(hours: 16,minutes:8,seconds: 8,));
  }


  @override
  void initState() {

    initialAsyc();
    super.initState();
  }


initialAsyc()async{
 audioPlayer= _audioHandler.getAudioPlayer();
  print('Start');

  try{
    localPath=await ppp.pMSharedStringGet('path');
  }catch (e){print('shared localpath error$e --------------------');}
}






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test'),centerTitle: true,),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: (){pickingFile();}, child: Text('filepicker')),
              ElevatedButton(onPressed: (){playLocal();}, child: Text('start')),
              ElevatedButton(onPressed: (){stopPlayer();}, child: Text('stop')),
              ElevatedButton(onPressed: (){jump();}, child: Text('jump')),
              PlayerWidget(url:'/data/user/0/com.example.proba/cache/file_picker/A Court of Mist and Fury.mp3'),



            ],
          )
      ),
    );
  }
}
