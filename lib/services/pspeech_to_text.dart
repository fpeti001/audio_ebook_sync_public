import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';


//kell hozzá
//  google_speech: ^2.0.1
//import 'package:google_speech/google_speech.dart';
//test_service_account.json file azz assets ből hogy múködjön a speach

class  PCSpeechWriter {
  bool recognizing = false;
  bool recognizeFinished = false;
  String text = 'alap text';
  String outputaudioLocationAndName=" alapoutputaudiolocationandname"; //'data/user/0/com.example.audio_ebook_sync/app_flutter/output10.flac';
  String inputName='alapinputName';
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  String inputPath;
  String deletefile="alapdeletefile";
  double tol;
  double ig;
  String ?rawDocumentPath;
  String outputName='torlendo.wav';


  PCSpeechWriter(String this.inputPath,double this.tol, double this.ig);


  pMAudioSnipetToText()async{
    inputName = inputPath.split('/').last;




   await findOutputPath();
   await deleteFile(outputName);
    await convert(inputPath);
    await audioToText();
    deleteFile(outputName);

  }


//convert---------------------------------------------VVVVVVVVVVVVVVVVVVVVVVVVV


  convert(String path) async{
//('-t $ig -i $path -ss $tol -ar 48000 $outputaudioLocationAndName');
    await _flutterFFmpeg.execute('-t $ig -i $path -ss $tol -ac 1 -ar 48000 $outputaudioLocationAndName');
    print('convering kesz');
  }
  findOutputPath() async{
    Directory appDocumentDir = await getApplicationDocumentsDirectory();
    rawDocumentPath = appDocumentDir.path;
    outputaudioLocationAndName ='$rawDocumentPath/$outputName';
    print('----------------------------------outputaudioLocationAndName:$outputaudioLocationAndName');

  }



//----------------------------------------------------------speech˘ˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇˇ
  Future<void> audioToText() async {
    // setState(() {
    recognizing = true;
    //  });
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/test_service_account.json'))}');
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();
//test3.wav
    final audio = await _getAudioContent(outputName);

    await speechToText.recognize(config, audio).then((value) {
      //  setState(() {
      text = value.results
          .map((e) => e.alternatives.first.transcript)
          .join('\n');
      //    });
    })
        .whenComplete(() {
//valsz hibáááás
      recognizeFinished = true;
      recognizing = false;
      print('kééééééééééééééééész $inputName');
    });
  }


  RecognitionConfig _getConfig() =>
      RecognitionConfig(
          encoding: AudioEncoding.LINEAR16,
          model: RecognitionModel.basic,
          enableAutomaticPunctuation: true,
          sampleRateHertz: 48000,
          languageCode: 'en-US');

  Future<void> _copyFileFromAssets(String name) async {
    //'data/user/0/com.example.audio_ebook_sync/app_flutter/output3.wav'
    var data = await rootBundle.load(outputaudioLocationAndName);
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/$name';
    await File(path).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<List<int>> _getAudioContent(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/$name';
    if (!File(path).existsSync()) {
      await _copyFileFromAssets(name);
    }
    return File(path).readAsBytesSync().toList();
  }


  //file törléshez ------------------------------------------ˇˇˇˇˇˇˇˇˇˇ

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('path ${path}');
    return File('$path/$deletefile');
  }

   deleteFile(String kitorlendofile) async {
    deletefile=kitorlendofile;
    try {
      final file = await _localFile;

      await file.delete();
      print('${file.path}--------------------kitorolve');
    } catch (e) {

    }
  }

}
