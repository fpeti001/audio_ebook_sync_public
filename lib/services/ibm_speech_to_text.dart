import 'dart:convert';
import 'dart:typed_data';
import 'package:audio_ebook_sync/utils/IamOptions.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class Voice {
  String ?gender;
  dynamic ?supported_feature;
  String ?name;
  bool ?customizable;
  String ?description;
  String ?language;
  String ?url;

  Voice(Map data) {
    this.gender = data['gender'];
    this.supported_feature = data['supported_features'];
    this.name = data['name'];
    this.customizable = data['customizable'];
    this.description = data['description'];
    this.language = data['language'];
    this.url = data['url'];
  }
}

class SpeechToText {
  String urlBase = "https://api.eu-gb.speech-to-text.watson.cloud.ibm.com";
  String ?modelId;
  final String ?version;
  IamOptions ?iamOptions;
  String accept;
  String ?language;

  SpeechToText(

      {required this.iamOptions,
        this.version = "2018-05-01",
        this.accept = "audio/wav",
       // this.accept = "audio/mp3",
        this.language = "en-GB_Telephony"
      // this.voice = "de-DE_Telephony"
     });

  void setLanguage(String v) {
    this.language = v;
  }

  String _getUrl(method, {param = ""}) {
    String? url = iamOptions!.url;
    if (iamOptions!.url == "" || iamOptions!.url == null) {
      url = urlBase;
    }
    return "$url/v1/$method$param";
  }

  Future<String> toText(Uint8List assetUint8) async {

    print('start toText${HttpHeaders.contentLanguageHeader}');

    String? token = this.iamOptions!.accessToken;
    var response =await http.post(
      Uri.parse(_getUrl("recognize", param: "?model=$language")),

 //   var response = await http.post(
  //    _getUrl("synthesize", param: "?voice=$voice"),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.contentTypeHeader: "audio/wav",
     //   HttpHeaders.contentLanguageHeader:"de-DE_Telephony"

        //HttpHeaders.contentTypeHeader: "application/json",
     //   'Accept': 'en-GB_NarrowbandModel'
     // 'Accept': 'en-GB_Telephony'

      },
      body: assetUint8,
    );

    String s = new String.fromCharCodes(response.bodyBytes);
    if(s.contains(new RegExp(r'error', caseSensitive: false))) print('----------------------ERROR IBM resoults $s');

    String transcript='';
    Map<String, dynamic> focucc = jsonDecode(s);
    var results=focucc['results'];

    for( var i = 0; i < results.length; i++){
      Map nulla=results[i];
      var alternatives  = nulla['alternatives'];
      Map belso =alternatives[0];
      transcript+='${belso['transcript']}';
    }

    return transcript;
  }

  Future<List<Voice>> getListVoices() async {
    String? token = this.iamOptions!.accessToken;

   // var response = await http.get(_getUrl("voices"),
    var response =await http.get(Uri.parse(_getUrl("voices")),
    headers: {
      HttpHeaders.authorizationHeader: "Bearer $token",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json",
    });
    List<Voice> resp = [];
    if (response.statusCode == 200) {
      Map result = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> data = result['voices'];
      for (Map d in data) {
        resp.add(new Voice(d));
      }
    }
    return resp;
  }
}