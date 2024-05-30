import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:audio_ebook_sync/services/text_handeling.dart';
import 'package:flutter/material.dart';
//import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_ebook_sync/services/pspeech_to_text.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';




class PPP  {
 // final player3 = AudioPlayer();


popup(String popuptext){
  Fluttertoast.showToast(
      msg: popuptext,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
  mpToIndexAndMp(int mp, List<int> durationList){
    List<int> returnList=[];
    int index=0;
    int mpAfterIndex=0;
    int mpSum=0;
    for(int i=0;mpSum<mp;i++ ){
      mpSum=mpSum+durationList[i];
      if (mpSum>mp){
        index=i;
        mpAfterIndex=mp-(mpSum-durationList[i]);
        returnList.add(index);
        returnList.add(mpAfterIndex);
      }
    }
    return returnList;
  }
  Future<void> showMyDialog(String title, String content,BuildContext context) async {

    return showDialog<void>(
      context: context,
     // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children:  <Widget>[
                SelectableText(content),

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
Future<void> showTranslationDialog(String text,BuildContext context) async {

  return showDialog<void>(
    barrierColor: Color(0x01000000),
    context: context,
    // barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
          alignment: Alignment.topCenter,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        content: Text(text),

      );
    },
  );
}
Future<void> showDialoWithButtons(String title, String content,BuildContext context,String buttonText1, String buttonText2,var buttonMethon2) async {

  return showDialog<void>(
    context: context,
    // barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children:  <Widget>[
              SelectableText(content),

            ],
          ),
        ),
        actions: <Widget>[
          buttonText1==""?SizedBox.shrink():  TextButton(
            child:  Text(buttonText1),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        buttonText2==""?SizedBox.shrink():  TextButton(
            child:  Text(buttonText2),
            onPressed: () async {
              Navigator.of(context).pop();
              await buttonMethon2();

            },
          ),
        ],
      );
    },
  );
}













  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

getPercent()async{
 int returnInt= await sharedIntGet('percent');
 return returnInt;
}
setPercent(int value)async{
 await sharedIntSet('percent', value);
}

  mpToOraPercMp(double bejovoMp){
    String returnTime='mp: ${bejovoMp/60~/60}:${bejovoMp/60%60~/1}:${bejovoMp%60%60}';
    return returnTime;
  }
audioDurationSec(String path)async{
  print("--------------------------------audioDurationSec");
  print ("path $path");
  String kalap="";
  File file = File('$path');

  final FlutterFFprobe _flutterFFprobe = new FlutterFFprobe();
  await  _flutterFFprobe.getMediaInformation(file.path).then((info) =>kalap= info.getAllProperties()["streams"][0]["duration"]);
  int returnInt=double.parse(kalap).round();

  return returnInt;
}

  sharedIntSet(String key,int value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
    print('pMSharedInrSet');
  }
  sharedIntGet(String key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? rreturn =prefs.get(key);
    return rreturn;
  }
pMSharedBoolSet(String key,bool value)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
  print('pMSharedBoolSet');
}
pMSharedBoolGet(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}

pMSharedStringSet(String key,String value)async{
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString(key, value);
print('pMSharedStringSet');
}
pMSharedStringGet(String key)async{
SharedPreferences prefs = await SharedPreferences.getInstance();
Object? rreturn =prefs.get(key);
return rreturn;
}
sharedDoubleSet(String key,double value)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(key, value);
  print('pMSharedInrSet');
}
sharedDoubleGet(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}
pMSharedListSyncPontokSet(String key,List<SyncPontok> value)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value2= json.encode(value);
  await prefs.setString('listsyncpontok$key', value2);
  print('pMSharedStringSet');
}
pMSharedListSyncPontokGet(String key)async{
  String ize=await pMSharedListSyncPontokGet2('listsyncpontok$key');
  List<SyncPontok> returnSyList1=[];
  List<dynamic> sylist3 =json.decode(ize);
  List<Map> list3=sylist3.cast<Map>();
  print(list3.length);
  for (int i=0;i<list3.length;i++){
    returnSyList1.add(SyncPontok(list3[i]['textKarakterSzam'], list3[i]['audioMp'],  list3[i]['joKereoMondat']));
  }
 // List<SyncPontok> pp3 = mapper.readValue(json, new TypeReference<List<Person>>() {});
 // List<SyncPontok>valami=List<SyncPontok>.from(list.where((i) => i.flag == true));
 //ist<SyncPontok>valami= List<SyncPontok>.from(list);

  // List<SyncPontok> listS=list.cast<SyncPontok>();

  return returnSyList1;
}

pMSharedListSyncPontokGet2(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}
  pMSharedListSyncPontokRemove(String key)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('listsyncpontok$key');
    print('pMSharedListSyncPontokRemove');
  }
  pMSharedListRemove(String key)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print('pMSharedListRemove');
  }

pMSharedListBooksSet(String key,List<Book> value)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value2= json.encode(value);
  await prefs.setString('booklist$key', value2);
  print('pMSharedListBooksSet ');
}
pMSharedListBooksGet(String key)async{
  String ize=await pMSharedListSyncPontokGet2('booklist$key');
  List<Book> returnSyList1=[];

  List<dynamic> sylist3 =json.decode(ize);
  print('pMSharedListBooksGet');
  List<Map> list3=sylist3.cast<Map>();
  print(list3.length);
//  print(' ------------------------list3: $list3');
  for (int i=0;i<list3.length;i++){
    returnSyList1.add(Book.setEABok(list3[i]['ebookName'], list3[i]['ebookPath'],  list3[i]['ebookString'],list3[i]['aBookName'],list3[i]['aBookPath'],list3[i]['bookCode'],list3[i]['bookMarkText'],list3[i]['bookMarkCaracter'],list3[i]['bookMarkMp'],list3[i]['lastWasEbook'],list3[i]['bookCoverPath']));
  }

  return returnSyList1;
}

pMSharedListBooksGet2(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}





pMSharedBookClassSet(String key,Book value)async{
  String s =json.encode(value);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('bookclass$key', s);
  print('pMSharedListSet');
}
pMSharedBookClassGet(String key)async{
  String blabla=await pMSharedBookClasGet2('bookclass$key');
  Map<String,dynamic> jsondatais = jsonDecode(blabla);
  var book = Book.fromJson(jsondatais);
  print('pMSharedBookClassGet ');
  return book;
}
pMSharedBookClasGet2(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}
/*pMSharedBookClassRemove(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('bookclass$key');

}*/



  pMSharedIntListSet(String key,List<int> value)async{
    String s =json.encode(value);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, s);
    print('pMSharedListSet');
  }
  pMSharedIntListGet(String key)async{
    String blabla=await pMSharedListGet2(key);
    List<dynamic> list=json.decode(blabla);
    List<int> listS=list.cast<int>();
    print('shareeeed $listS');
    return listS;
  }
  pMSharedIntListGet2(String key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? rreturn =prefs.get(key);
    return rreturn;
  }



/////////////////////////////////////////////////////
pMSharedListSet(String key,List<String> value)async{
  String s =json.encode(value);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, s);
  print('pMSharedListSet');
}
pMSharedListGet(String key)async{
  String blabla=await pMSharedListGet2(key);
  List<dynamic> list=json.decode(blabla);
  List<String> listS=list.cast<String>();
  print('shareeeed $listS');
  return listS;
}
pMSharedListGet2(String key)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Object? rreturn =prefs.get(key);
  return rreturn;
}
////////////////////////////////////////////////////////
 /* pMSharedListSetSyncPontok(String key,List<String> value)async{
    String s =json.encode(value);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, s);
    print('pMSharedListSet');
  }
  pMSharedListGetSyncPontok(String key)async{
    String blabla=await pMSharedListGet2(key);
    List<dynamic> list=json.decode(blabla);
    List<String> listS=list.cast<String>();
    print('shareeeed $listS');
    return listS;
  }
  pMSharedListGet2SyncPontok(String key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? rreturn =prefs.get(key);
    return rreturn;
  }
*/







/*

pMSharedListSetSyncPontok(String key,List<SyncPontok> value)async{
  print('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
  String s =await json.encode(value);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, s);
  print('pMSharedListSetSyncPontok');
}
pMSharedListGetSyncPontok(String key)async{
  String blabla=await pMSharedListGet2SyncPontok(key);

  List<dynamic> list=await json.decode(blabla);
  List<SyncPontok> listS=list.cast<SyncPontok>();

 // List<String> listS=list.cast<String>();
  return listS;
}
pMSharedListGet2SyncPontok(String key)async{

  SharedPreferences prefs2 = await SharedPreferences.getInstance();

  Object? rreturn =prefs2.get(key);

  return rreturn;
}
*/






pMfilepickernyito()async{
  FilePickerResult? result = await FilePicker.platform.pickFiles();
String filepath;
  if(result != null) {
    File file = File(result.files.single.path!);
    filepath=file.path;
    //await conver(filepath);
  } else {
    filepath='null';
    // User canceled the picker
  }
  print('------------------------------filevalasztas kesz$filepath');
return filepath;

}
pMcut(String path,String outputName, int tolMp, int igMp,) async{
  Directory appDocumentDir = await getApplicationDocumentsDirectory();
  String rawDocumentPath = appDocumentDir.path;
  String outputaudioLocationAndName ='$rawDocumentPath/$outputName';

  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

//('-t $ig -i $path -ss $tol -ar 48000 $outputaudioLocationAndName');
  //'-t $igMp -i $path -ss $tolMp -ac 1 -ar 48000 $outputaudioLocationAndName
  //-t $igMp -i /data/user/0/com.example.audio_ebook_sync/cache/file_picker/Throne of Glass Part 1.mp3 -ss $tolMp -acodec copy $outputaudioLocationAndName
//  var asdf=["-t", "$igMp", "-i", path, "-ss", "$tolMp", "-acodec", "copy", "$outputaudioLocationAndName"];
//var  asdf=["-t", "100", "-i", path, "-ss", "110", "-acodec","libmp3lame", "-ab", "256k",  "$outputaudioLocationAndName"];
//var asdf=["-i",path, "-c:v" ,"copy" ,"-c:a", "libmp3lame" ,"-q:a" ,"4" ,outputaudioLocationAndName];
// var asdf=["-t", "110", "-i", path, "-ss", "100", "-acodec", "copy", "$outputaudioLocationAndName"];
  var asdf=["-i", path, "-acodec", "copy", outputaudioLocationAndName];
  await _flutterFFmpeg.executeWithArguments(asdf);


//  FFmpegKit.execute[asdf];



  print('-------------------------convering kesz');
  return outputaudioLocationAndName;
}
  pMcutTobbFile(List <String> pathList, List<int> fileDurationList, String outputName, int tolMp, int igMp,) async{

  String run='-------------------------pMcutTobbFile eleje ';
  run += '\n tolMo=$tolMp  igMp=$igMp';
  int fileDurationSum=0;
  String path='';
  int filePieceDuration=0;

 List<int> indexAndMp= mpToIndexAndMp(tolMp,fileDurationList);
path=pathList[indexAndMp[0]];
int mpInsidePeace=indexAndMp[1];

  /*for (int i=0;i<fileDurationList.length;i++){
    fileDurationSum=fileDurationSum+fileDurationList[i];
    if(fileDurationSum>tolMp){
path=pathList[i];
filePieceDuration=fileDurationList[i];
run+='\n cutingFilePath=$path \nfilePieceDuration/ $filePieceDuration';
break;
    }
  }*/

    Directory appDocumentDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDocumentDir.path;
    String outputaudioLocationAndName ='$rawDocumentPath/$outputName';
  print('-------------------------convering start1');

  try{
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    print('11');
    String format=path.substring(path.lastIndexOf("."));
    print("fromat: $format output: $outputaudioLocationAndName");
   
    var asdf=["-y", "-ss", "$mpInsidePeace","-to", "${mpInsidePeace+10}", "-i", path,"$outputaudioLocationAndName"];
   //eredeti var asdf=["-t", "${mpInsidePeace+10}", "-i", path, "-ss", "$mpInsidePeace", "-acodec", "copy", "$outputaudioLocationAndName"];
   /* if(format.contains("mp3")){  asdf=["-t", "${mpInsidePeace+10}", "-i", path, "-ss", "$mpInsidePeace", "-acodec", "copy", "$outputaudioLocationAndName"];}
    if(format.contains("m4b")){
      asdf=["-t", "${mpInsidePeace+10}", "-i", path, "-ss", "$mpInsidePeace", "copy","-acodec","libmp3lame", "-ab", "256k",  "$outputaudioLocationAndName"];
    print("if m4aaaaaaaaaaaa")
    ;}*/


    print('22');
    await _flutterFFmpeg.executeWithArguments(asdf);
    print('33');
  }catch(e){
    print('44');
    print('ffmpegerrror: $e');
  }




    print('$run\n-------------------------pMcutTobbFile vege');
    return outputaudioLocationAndName;

  }

pMgetPath(String name)async{
  Directory appDocumentDir = await getApplicationDocumentsDirectory();
  String rawDocumentPath = appDocumentDir.path;
  String outputaudioLocationAndName ='$rawDocumentPath/$name';
  return outputaudioLocationAndName;
}
}
//class ok-----------------------------------
class PPPDeleteFile{
  String fileName='';


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('path ${path}');
    return File('$path/$fileName');
  }

  Future<void> deleteFile(String kitorlendofile) async {
    fileName=kitorlendofile;
    try {
      final file = await _localFile;

      await file.delete();
      print('${file.path}--------------------kitorolve');
    } catch (e) {
      print('--------------------nemsikerult');
    }
  }
}