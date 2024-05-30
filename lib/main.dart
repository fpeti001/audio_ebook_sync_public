import 'dart:io';

//import 'package:audio_ebook_sync/pages/asd.dart';
import 'package:audio_ebook_sync/pages/audio_player.dart';
import 'package:audio_ebook_sync/pages/bg_player.dart';
import 'package:audio_ebook_sync/pages/eboookSettings.dart';
import 'package:audio_ebook_sync/pages/lists/known_word_list.dart';
import 'package:audio_ebook_sync/pages/purchase/purchase.dart';
import 'package:audio_ebook_sync/pages/translater.dart';
import 'package:audio_ebook_sync/pages/lists/unknown_word_list.dart';
import 'package:audio_ebook_sync/pages/lists/word_learning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_ebook_sync/services/pspeech_to_text.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:audio_ebook_sync/pages/home.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_ebook_sync/splitted_text/blocs/pageControlBloc.dart';
import 'package:audio_ebook_sync/splitted_text/textPageView.dart';
import 'package:audio_ebook_sync/pages/loading_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';


Future<void> main()async {
 await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );



  runApp(MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),

      initialRoute: '/home',
      routes:{

        '/ebooksettings': (contaxt) => EbookSettings(),
        '/chooselanguage': (contaxt) => ChoseLanguage(),
        '/purchase': (contaxt) => Purchase(),
        '/home': (contaxt) => Home(),
        '/player': (contaxt) => BgPlayer (),
        '/loading': (contaxt) => Loading(toDo: 0,bookCode:''),
        '/audio': (contaxt) => AudioPlayerPage(),
        '/wordlearning': (contaxt) => WordLearning(),
        '/knownwordlist': (contaxt) => KnownWords(),
        '/unknownwordlist': (contaxt) => UnknownWords(),
        '/reader': (context) => BlocProvider(
          create: (context) => PageControlBloc(),

            //     debugShowCheckedModeBanner: false,
           child:TextPageView(),

        )

      }
  ));
}


/*class ReaderHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: TextPageView(key: null,)),
    );
  }
}*/


