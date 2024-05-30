//methods for project
import 'dart:io';
import 'package:audio_ebook_sync/auth/secrets.dart';
import 'package:audio_ebook_sync/pages/loading_screen.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_ebook_sync/services/pspeech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//import 'package:pdf_text/pdf_text.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'dart:async';
import 'package:audio_ebook_sync/utils/IamOptions.dart';
import 'package:audio_ebook_sync/services/ibm_speech_to_text.dart';
import 'package:path/path.dart';
import 'dart:typed_data';



class Mfp  {
  PPP ppp = PPP();
saveIbmLanguageBasedOnThis(String bookCode,String languageCode,BuildContext buildContext)async{
  Map<String,String> languadeMap={
    "ar":"ar-MS_Telephony",
    "zh":"zh-CN_Telephony",
    "cs":"cs-CZ_Telephony",
    "nl":"nl-BE_Telephony",
    "en":"en-GB_Telephony",
    "fr":"fr-FR_Telephony",
    "de":"de-DE_Telephony",
    "hi":"hi-IN_Telephony",
    "it":"it-IT_Telephony",
    "ja":"ja-JP_Telephony",
    "ko":"ko-KR_Telephony",
    "pt":"pt-BR_Telephony",
    "es":"es-ES_Telephony",
    "sv":"sv-SE_Telephony",
  };
  String? ibmLanguageCode=languadeMap[languageCode];
  if(ibmLanguageCode==null)ppp.showMyDialog("Error", "Not suported language for sync. \n You cant use bookmark sync with this book, but you can read and listen without problem.", buildContext);
   await setBookString(bookCode, "language", ibmLanguageCode!);
  print("language code: $languageCode ibmlanguage: $ibmLanguageCode");



}

setBookString(String bookCode,String key,String value)async{

 await ppp.pMSharedStringSet(bookCode+key, value);
}
getBookString(String bookCode, String key)async{

  String rString= await ppp.pMSharedStringGet(bookCode+key);
  return rString;

}
  getThelanguageOfThis(String text)async {
    int midle=(text.length/2).round();
    String middleText="";
    if(text.length>4000){
    middleText =text.substring(midle-2000,midle);
    }else{
      middleText=text;
    }


    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    final String response = await languageIdentifier.identifyLanguage(middleText);
    print("checkThelanguageOfThis: $response");
    return response;

  }
epubproba()async{
  String pathh="/data/user/0/com.igen.aebook/cache/file_picker/Assassin's Blade - Sarah J. Maas.epub";
  //pathh=await ppp.pMfilepickernyito();

  var targetFile = new File(pathh);
  List<int> bytes = await targetFile.readAsBytes();
  EpubBook epubBook = await EpubReader.readBook(bytes);
  String? title = epubBook.Title;
  print("titleeeeeeeeeeeee: $title");
}
photoToText()async{
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
  String path=photo!.path;
  final inputImage = InputImage.fromFilePath(path);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
  String text = recognizedText.text;
  print(text);
  return text;

}
pickFolder()async{
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    // User canceled the picker
  }
  return selectedDirectory;
}




  pickFolderToMp3List()async{
    String lista="";
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
    }
    //  await ppp.pMSharedStringSet('soundDirectory', selectedDirectory!);
    List<String> fileList= await folderPathToContainingMp3Paths(selectedDirectory!);
    for(int i=0;i<fileList.length;i++){
      print('file in directory: ${fileList[i]}');
    }

    return fileList;
  }

  pathListToDurationList(List<String> pathList)async{
    List<int> durationList=[];
    for(int i=0;i<pathList.length;i++){
      durationList.add(await ppp.audioDurationSec(pathList[i]) ) ;
    }
    print('durationList $durationList');
    return durationList;
  }
  folderPathToContainingMp3Paths(String path)async{
    final myDir = new Directory(path);

    List<FileSystemEntity> _folders =  myDir.listSync(recursive: true, followLinks: false);

    List<String> mpHaromList=[];
    for(int i=0;i<_folders.length;i++){
      String file="";
      file= _folders[i].toString();
      file=file.substring(file.indexOf('/'),file.length-1);

      String format=file.substring(file.lastIndexOf('.'),file.length);
//Todo if(format.contains('mp3') || format.contains('m4b')){
  //    if(format.contains('mp3')){
      if(format.contains('mp3') || format.contains('m4b')|| format.contains('m4a')|| format.contains('mp4')|| format.contains('wav')|| format.contains('flv') ||format.contains('flac')||format.contains('fmp4')|| format.contains('ogg')|| format.contains('webm')){
        //   lista="$lista \n $file";
        mpHaromList.add(file);
      }

      //    file= _folders[i].toString().split('/').last;
      //   lista="$lista \n $file";
    }
    mpHaromList.sort();
    return mpHaromList;
  }
  folderPathtoCoverPath(String path)async{
    final myDir = new Directory(path);
    String coverPath='';
    List<FileSystemEntity> _folders =  myDir.listSync(recursive: true, followLinks: false);

    List<String> mpHaromList=[];
    for(int i=0;i<_folders.length;i++){
      String file="";
      file= _folders[i].toString();
      print('_folders ${_folders[i].toString()}');
      file=file.substring(file.indexOf('/'),file.length-1);

      String format=file.substring(file.lastIndexOf('.'),file.length);

      if(format.contains('jpg')){
        //   lista="$lista \n $file";
        coverPath=file.substring(1);
        break;
      }

      //    file= _folders[i].toString().split('/').last;
      //   lista="$lista \n $file";
    }

    return coverPath;
  }
  doSomethingAndLoad(BuildContext context,int toDoNumber,bookCode)async{
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => Loading( toDo: toDoNumber,bookCode: bookCode,)));

  }

  getBookByIndex(int index)async{
    List<Book> bookList=await ppp.pMSharedListBooksGet('books');
    Book returnBook=bookList[index];
    return returnBook;
  }
  setTextBookmark(String bookCode, String text)async{
    Book book =await pMGetBook(bookCode);
    book.bookMarkText=text;
    await pMSetBook(book);

  }
  setTextCaracterBookmark(String bookCode, int caracterNumber)async{
    Book book =await pMGetBook(bookCode);
    book.bookMarkCaracter=caracterNumber;
    await pMSetBook(book);

  }
  getBeforeAfterPointsCaracter(String bookCode, int caracter) async {
    List<SyncPontok> sharedSyncList = <SyncPontok>[];
    //ettol felfele megse
    sharedSyncList = await ppp.pMSharedListSyncPontokGet(bookCode);
    int beforCaracterNearestIndex=0;
    int afterCaracterNearestIndex=0;

    for(int i=0;sharedSyncList.length>i;i++){
      print(sharedSyncList[i].textKarakterSzam);
    }

    while(caracter>sharedSyncList[beforCaracterNearestIndex].textKarakterSzam){
      beforCaracterNearestIndex++;
    }//legkozelebbi elottelevot hozza ki
    afterCaracterNearestIndex=beforCaracterNearestIndex-1;
    return BeforeAfterSyncPoint(sharedSyncList[beforCaracterNearestIndex].textKarakterSzam,sharedSyncList[afterCaracterNearestIndex].textKarakterSzam);
  }
  getBeforeAfterPointsDiference(String bookCode, int caracter) async {
    BeforeAfterSyncPoint beforeAfterPoint=getBeforeAfterPointsCaracter(bookCode,caracter);

    int beforePointDifference=(caracter-beforeAfterPoint.before!.abs());
    int afterPointDifference=(caracter-beforeAfterPoint.after!.abs());

    print("beforePointDifference: $beforePointDifference");
    print("afterPointDifference: $afterPointDifference");
    return BeforeAfterPointsDiference(beforePointDifference,afterPointDifference);
  }
   isBeforAfterPointDiferenceUnderSpecificNumber(String bookCode, int caracter,int specificNumber,BuildContext buildContext)async{
          bool ret;
        BeforeAfterPointsDiference beforeAfterPointsDiference=getBeforeAfterPointsDiference(bookCode, caracter);
      if(beforeAfterPointsDiference.beforeDif<specificNumber || beforeAfterPointsDiference.afterDif<specificNumber){
        print("beforePointDifference<30000 && afterPointDifference<30000 ");
        double audioPont= await pointBetwenTwoPoint(bookCode,caracter,buildContext);
        ret=true;
      }else{
        print("beforePointDifference<30000 && afterPointDifference<30000 ");
        ret=false;
      }




      return ret;
    }


/*searchInAudioBook(String bookCode,int caracter)async{
    double audioPont=0;
      for(int i=0;i<3;i++){
        print("fooooooooor");
        if(await isBeforAfterPointDiferenceUnderSpecificNumber(bookCode,caracter,3000)){
          print("indexe $i isBeforAfterPointDiferenceUnderThirtyThousand");
          audioPont= await pointBetwenTwoPoint(bookCode,caracter);
          break;
        }
        print("indexe $i pointInTheOthersideOfAim");
        await pointInTheOthersideOfAim(bookCode,caracter.toDouble());


        if(await isBeforAfterPointDiferenceUnderSpecificNumber(bookCode,caracter,3000)){
          print("indexe $i isBeforAfterPointDiferenceUnderThirtyThousand");
          audioPont= await pointBetwenTwoPoint(bookCode,caracter);
          break;
        }
        print("indexe $i pointBetwenTwoPoint");
        await pointBetwenTwoPoint(bookCode,caracter);
      }
      if(audioPont==0){audioPont= await pointBetwenTwoPoint(bookCode,caracter);}



 /*   if(beforePointDifference<afterPointDifference){

    }else{

    }*/

 /* for(int i=0;i<sharedSyncList.length;i++){
    if(  caracter<sharedSyncList[i].textKarakterSzam  ){

    }
    }*/


  //eddig eljut
   /* await  ppp.setPercent(10);
    print('---------------------kettokozott');
  await pointBetwenTwoPoint(bookCode,caracter);
    print('---------------------kettokozott');
   await ppp.setPercent(40);
  await pointInTheOthersideOfAim(bookCode,caracter.toDouble());
    print('---------------------kettokozott');
    await  ppp.setPercent(60);
    double audioPont= await pointBetwenTwoPoint(bookCode,caracter);
    print('---------------------kettokozott');
    await  ppp.setPercent(80);*/


 // await pointInTheOthersideOfAim(bookCode,caracter.toDouble());
  //  await  ppp.setPercent(90);
 // double audioPont=await pointBetwenTwoPoint(bookCode,caracter);
  //  await  ppp.setPercent(100);
  print('itt kell folytatni a hangoskönyvet${ppp.mpToOraPercMp(audioPont-20)}');

 // int intaudioPont=audioPont.toInt();


  return audioPont.toInt();
}*/

  searchInAudioBook(String bookCode,int caracter, BuildContext buildContext)async{
    double audioPont=1;

     await  ppp.setPercent(10);
    print('---------------------between');
    audioPont= await pointBetwenTwoPoint(bookCode,caracter,buildContext);
    print('---------------------between');
   await ppp.setPercent(40);
      await pointInTheOthersideOfAim(bookCode,caracter.toDouble(),buildContext);
    print('---------------------between');
    await  ppp.setPercent(60);
    audioPont= await pointBetwenTwoPoint(bookCode,caracter,buildContext);
    print('---------------------between');
    await  ppp.setPercent(80);


    // await pointInTheOthersideOfAim(bookCode,caracter.toDouble());
    //  await  ppp.setPercent(90);
    // double audioPont=await pointBetwenTwoPoint(bookCode,caracter);
    //  await  ppp.setPercent(100);
    print('audiobook continuing place ${ppp.mpToOraPercMp(audioPont-20)}');

    // int intaudioPont=audioPont.toInt();


    return audioPont.toInt();
  }
pointAccuritCheck(double caracer,String bookCode)async{
  List<SyncPontok> sharedSyncList = <SyncPontok>[];
  sharedSyncList = await ppp.pMSharedListSyncPontokGet(bookCode);
  for(int i=0;i<sharedSyncList.length;i++){
    
  }


}
pMElsoUtolsoSyncPontHozzaadas(String bookCode)async{
  Book bookWhitoutPoints=Book();
 List<SyncPontok>syncpontokList=  await ppp.pMSharedListSyncPontokGet(bookCode);
List<Book> books=await ppp.pMSharedListBooksGet('books');
bookWhitoutPoints=await pMGetBook(bookCode);

if(syncpontokList.isEmpty) {
  print('bookWhitoutPoints.aBookPath ${bookWhitoutPoints.aBookPath}');
  List<int> durationList=await ppp.pMSharedIntListGet('durationList$bookCode');
  int durationInSec= durationList.fold(0, (p, c) => p + c);
  print('aaaaaaduration:$durationInSec');
//  int durationInSec = await ppp.audioDurationSec(bookWhitoutPoints.aBookPath);
  SyncPontok syncPontokFirst = SyncPontok(0, 0, 'firstnogoodsearchingword');

  SyncPontok syncPontokLast = SyncPontok(
      bookWhitoutPoints.ebookString.length, durationInSec,
      'lastnogoodsearchingword');

  await sorbanPontListabanElhelyezes(bookCode,0,0);
  await sorbanPontListabanElhelyezes(bookCode,bookWhitoutPoints.ebookString.length,durationInSec);
  syncpontokList.insert(0, syncPontokFirst);
  syncpontokList.add(syncPontokLast);
  await ppp.pMSharedListSyncPontokSet(bookCode, syncpontokList);
}

}
pointInTheOthersideOfAim(String bookCode, double caracterNumber,BuildContext buildContext)async{
  print('-----------starting: pMAtEllenkezoTalalat');
  int searchedPointMp;
  double elottePont=0;
  double utanaPont=0;
  double elottePontMp=0;
  double utanaPontMp=0;
  double utolsoPont=0;
  double utolsoAPont=0;
  double koviAudioPontProba=0;

  List<SyncPontok> sharedSyncList = <SyncPontok>[];
  sharedSyncList = await ppp.pMSharedListSyncPontokGet(bookCode);
  utolsoPont=sharedSyncList.last.textKarakterSzam.toDouble();
  utolsoAPont=sharedSyncList.last.audioMp.toDouble();
  print('sharedSyncList:${sharedSyncList[0].textKarakterSzam} and  second${sharedSyncList[1].textKarakterSzam} ');
  for(int i=0;i<sharedSyncList.length;i++){
    SyncPontok syncPontok = sharedSyncList[i];
    if(syncPontok.textKarakterSzam>caracterNumber){
      utanaPont=sharedSyncList[i].textKarakterSzam.toDouble();
      elottePont=sharedSyncList[i-1].textKarakterSzam.toDouble();

      utanaPontMp=sharedSyncList[i].audioMp.toDouble();
      elottePontMp=sharedSyncList[i-1].audioMp.toDouble();

      break;
    }
  }
  //ha elotte es kozepkso pont kozott nagyobb
  if((kulombseg(elottePont, caracterNumber))>(kulombseg(utanaPont, caracterNumber))){
   // if(pMSzazalekKetPontKozott(elottePont, caracterNumber,utolsoPont )>0.10){
    // koviAudioPontProba=caracterNumber-( kulombseg(caracterNumber, utanaPont));
     double szazalekCaractenEsUtanakozott=pMSzazalekKetPontKozott(caracterNumber, utanaPont, utolsoPont);
     koviAudioPontProba= utanaPontMp-((szazalekCaractenEsUtanakozott*2)*utolsoAPont);
   // }
  }
  //ha utána es kozepso pont kozott nagyobb
  if((kulombseg(elottePont, caracterNumber))<(kulombseg(utanaPont, caracterNumber))){
  //  if(pMSzazalekKetPontKozott(utanaPont, caracterNumber,utolsoPont )>0.10){
     // koviAudioPontProba=caracterNumber+( kulombseg(caracterNumber, elottePont));
      double szazalekCaractenEsElottekozott=pMSzazalekKetPontKozott(caracterNumber, elottePont, utolsoPont);
      koviAudioPontProba=elottePontMp+((szazalekCaractenEsElottekozott*2)*utolsoAPont);
  //  }
  }
int textPont =await audioPontToTextPont(bookCode, koviAudioPontProba.toInt(),buildContext);
  print('pMAtEllenkezoTalalat:');
  print('elottepont: $elottePont utanapont: $utanaPont');
  print('koztesPontMp $koviAudioPontProba koztesPontText $textPont');
}

   pointBetwenTwoPoint(String bookCode, int caracterNumber,BuildContext buildContext)async {
     int textPont=0;
     double koztesPontMp=0;
  try{

     print('-----------kezododik: pMSearchInAudioBook $caracterNumber');

     double elottePont=0;
     double utanaPont=0;
     double elottePontMp=0;
     double utanaPontMp=0;

     List<SyncPontok> sharedSyncList = <SyncPontok>[];
     //ettol felfele megse

     sharedSyncList = await ppp.pMSharedListSyncPontokGet(bookCode);


     if(caracterNumber>sharedSyncList.last.textKarakterSzam){

     }else {
       //errrejon

       print('sharedSyncList:${sharedSyncList[0]
           .textKarakterSzam} es amasodik${sharedSyncList[1]
           .textKarakterSzam} ');
       for (int i = 0; i < sharedSyncList.length; i++) {
         SyncPontok syncPontok = sharedSyncList[i];
         print('i=$i listaban $caracterNumber eredeti  ${syncPontok
             .textKarakterSzam}');
         if (syncPontok.textKarakterSzam > caracterNumber) {
           print('i=$i ');
           utanaPont = sharedSyncList[i].textKarakterSzam.toDouble();
           elottePont = sharedSyncList[i - 1].textKarakterSzam.toDouble();

           utanaPontMp = sharedSyncList[i].audioMp.toDouble();
           elottePontMp = sharedSyncList[i - 1].audioMp.toDouble();

           break;
         }
       }
       print('utanaPont $utanaPont elottePont $elottePont  ');
       print('utanaPontMp $utanaPontMp elottePontMp $elottePontMp  ');
       //kiszamolas hany szazalekkel van elorebb az elozo ponthoz kepest
       double koztesSzakaszHossza = utanaPont - elottePont;
       double elsoEsKoztesPontKulombesege = caracterNumber - elottePont;
       double ennyiSzazalekkalElorebbElozoPontnal = elsoEsKoztesPontKulombesege /
           koztesSzakaszHossza;

       double koztesSzakaszHosszaMp = utanaPontMp - elottePontMp;
        koztesPontMp = elottePontMp +
           (ennyiSzazalekkalElorebbElozoPontnal * koztesSzakaszHosszaMp);

        textPont = await audioPontToTextPont(bookCode, koztesPontMp.toInt(),buildContext);

       print('pMSearchInAudioBook:');
       print('elottepont: $elottePont utanapont: $utanaPont');
       print('koztesPontMp $koztesPontMp koztesPontText $textPont');
     }
    // await pMAtEllenkezoTalalat(bookCode,caracterNumber.toDouble());
   } catch (e) {

  print("Error loading audio source: $e");
  }
if(textPont==0)koztesPontMp=0;//needed for error dialog if audioPontToTextPont and serach fails
      return koztesPontMp;
   }
pMSzazalekKetPontKozott(double elso, double masodik, double egeszHossza){
  double returnnumber= ((elso-masodik).abs())/egeszHossza;
  return returnnumber;
}
kulombseg(double elso, double masodik){
  return((elso-masodik).abs());
}
/*    pMIsNowReadingStillInList()async{
      Book book;
      book=await ppp.pMSharedBookClassGet('nowread');
      List<Book> bookList =await ppp.pMSharedListBooksGet('books');
      bool bennevan=false;
      for(int i=0;i<bookList.length;i++){
        if(book.bookCode==bookList[i].bookCode){

            bennevan=true;

        }
      }
      if(!bennevan){
        await ppp.pMSharedBookClassRemove('nowread');
      }
      return bennevan;
    }*/
  audioPontToTextPont(String bookCode,int audioMpPoint,BuildContext buildContext  ) async {
    String run='---------------------- audioPontToTextPont';
    run+='\n audiopoint legelején=$audioMpPoint';
    print('audioPontToTextPont startol');

    List<String> mp3PathList=await ppp.pMSharedListGet('mp3PathList$bookCode');
    List<int> durationList= await ppp.pMSharedIntListGet('durationList$bookCode');
    int fileDurationSum=0;
    int filePieceDuration=0;
    print('audioPontToTextPont 1');
    //teszt hogy nem esik e két file közé a választott audiopont (kijavítja ha igen)
    for (int i=0;i<durationList.length;i++){
      fileDurationSum=fileDurationSum+durationList[i];
      if(fileDurationSum>audioMpPoint) {
        run+='\nfiledurationsum=$fileDurationSum';
        if (audioMpPoint + 10 > fileDurationSum) {
          run+='\n kivágandó fájl belecsúszik a végébe';
          audioMpPoint = fileDurationSum - 11;
          if (durationList[i] < 20) {
            print(
                'aaaaaaaaaaaaa ERROR: mfp.audioPontToTextPont részlet túl kicsi nem lehet kivágni a hangból 10mp t, hogy szövegben keressen');
          }
        } else{
          if (audioMpPoint - 10 < fileDurationSum - durationList[i]) {
            run+='\n kivágandó fájl belecsúszik az elejébe';
          audioMpPoint = fileDurationSum - durationList[i];
          if (durationList[i] < 20) {
            print(
                'aaaaaaaaaaaaa ERROR: mfp.audioPontToTextPont részlet túl kicsi nem lehet kivágni a hangból 10mp t, hogy szövegben keressen');
          }
        }
      }
        run+='\n audiopoint végén=$audioMpPoint';
        break;
      }

    }
    print('audioPontToTextPont 2');
    PPPDeleteFile pppDeleteFile = new PPPDeleteFile();
    print('audioPontToTextPont 3');
    await pppDeleteFile.deleteFile('outputName2.mp3');
    print('audioPontToTextPont 4');
    Book book=await pMGetBook(bookCode);
    print('audioPontToTextPont 5');
    String cutInputPath =book.aBookPath;
    print('$run \n-------------------------------audioPontToTextPont cutig');
    String cutOutputFullPath = await ppp.pMcutTobbFile(
      //  cutInputPath, 'outputName2.mp3', audioMpPoint - 10, audioMpPoint);
        mp3PathList, durationList,'outputName2.wav', audioMpPoint, audioMpPoint+10);
print('xxxxxxxxxxxxxxxxxxxxxxx$audioMpPoint');

    String text = await pMSpeechToTextIBM(cutOutputFullPath,bookCode);


    String konyvString = book.ebookString;
    print('ccc audioPontToTextPont pontKarbook.ebookString: ${konyvString.length}');
    int pontKarakterSzam = await pMSearch(bookCode,konyvString, text, audioMpPoint,buildContext);

    print('pontKarakterSzam: $pontKarakterSzam');
    print('audioPontToTextPont vége');
    print('$run \n-------------------------------audioPontToTextPont vége');
    return pontKarakterSzam;
  }
  pMGetBook(String bookCode2)async{
    Book returnBook=Book();
    try {
      List<Book> books = await ppp.pMSharedListBooksGet('books');

      for (int i = 0; i < books.length; i++) {
        Book book = books[i];
        if (bookCode2 == book.bookCode) {
          returnBook = book;
        }
      }
    }catch (e){print(e);}
    return returnBook;
  }
  pMSetBook(Book inputBook)async{

    try {
      List<Book> books = await ppp.pMSharedListBooksGet('books');

      for (int i = 0; i < books.length; i++) {
        Book book = books[i];
        if (inputBook.bookCode == book.bookCode) {
          books[i]=inputBook;
          print('iiiiiiiiiiiiii$i');
          ppp.pMSharedListBooksSet('books', books);
        }
      }
    }catch (e){print(e);}

  }
  pMSpeechToTextIBM(String path,String bookCode) async {
String language=await getBookString(bookCode, "language");
print("pMSpeechToTextIBM language: $language");
    String text="";
    try {
      IamOptions options = await IamOptions(
          iamApiKey: SecretClass.ibmIamApiKey,
          url:SecretClass.ibmUrl
          )
          .build();
      SpeechToText service = new SpeechToText(iamOptions: options);
      service.setLanguage(language); //default en-US_AllisonV3Voice

      File assettestmp3 = File(path);
      Uint8List assetUint8 = assettestmp3.readAsBytesSync();

       text = await service.toText(assetUint8);

      print('IBM response:$text');
    } catch (e) {
      
  text="pMSpeechToTextIBM error: $e";
    }
    return text;
  }

    pMDeleteBook(int index)async{
      String bookCode;
      List<Book> bookList =await ppp.pMSharedListBooksGet('books');
      bookCode=bookList[index].bookCode;
      bookList.removeAt(index);
     await ppp.pMSharedListBooksSet('books', bookList);

     await ppp.pMSharedListSyncPontokRemove(bookCode);
      await ppp.pMSharedListRemove('mp3PathList$bookCode');
      await ppp.pMSharedListRemove('durationList$bookCode');



    }
    pMNowReadingSet(String bookCode)async{
     await ppp.pMSharedStringSet('nowread', bookCode);
    }
    pmNowReadingGet()async{
      Book book;
      book=await pMGetBook(await ppp.pMSharedStringGet('nowread'));

      return book;
    }
  pMEBookChooser() async {
    ppp.pMfilepickernyito();


  }

  pMAudioBookChooser(String ebookName) async {
    ppp.pMfilepickernyito();
  }


sorbanPontListabanElhelyezes(String bookCode,int bePontKarakterSzam, int audioMp)async{



    List<String> stringList=[];
    SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
    stringList=sharedPreferences.getStringList("$bookCode sor")??[];
    stringList.add(bePontKarakterSzam.toString());
    stringList.add(audioMp.toString());

    await sharedPreferences.setStringList("$bookCode sor", stringList);
print("sorbanlistaaaaa $stringList");




}

  pMPontListabanElhelyetes(String bookCode,int bePontKarakterSzam, int audioMp, String joKeresesMondat) async {
    print('pMPontListabanElhelyetes elindult karakterszam:$bePontKarakterSzam');
    SyncPontok syncPontok = SyncPontok(
        bePontKarakterSzam, audioMp, joKeresesMondat);

    List<SyncPontok> sharedSyncList = <SyncPontok>[];


    try {
      sharedSyncList = await ppp.pMSharedListSyncPontokGet(bookCode);
      print('${sharedSyncList.length} SharedSyncList lista hossza ');
    } catch (e) {
      print('Shared nem mukodik jol');

      print('Printing out the message: $e');
    }
    if (sharedSyncList.length != 0) {
      for (int i = 0; i < sharedSyncList.length; i++) {
        //  print('i szam $i');
        SyncPontok syncPontokIdeglenes = sharedSyncList[i];

        int karakterSzam = syncPontokIdeglenes.textKarakterSzam;
        print(
            'karakterszma--asd---------------------------------------------------asd $karakterSzam');
        if (karakterSzam > bePontKarakterSzam) {
          sharedSyncList.insert(i, syncPontok);
          print('listaban sikeresen elhelyezve');
          break;
        } else {
          if (karakterSzam == bePontKarakterSzam) {
            print('listaban mar megvan ez a text pont $i');
            break;
          }

          if (i == sharedSyncList.length - 1) {
            sharedSyncList.add(syncPontok);
            print('listaban sikeresen elhelyezve utolsonak');
            break;
          }
        }
      }
    } else {
      sharedSyncList.add(syncPontok);
      print('lista ures volt de hozzaadva');
    }
    await ppp.pMSharedListSyncPontokSet(bookCode, sharedSyncList);
    print('pMPontListabanElhelyetes befejezodott${sharedSyncList.length}');
  }




  searchBookMarkPosition(String bookCode, List<String>stringList) async {
    print('searchBookMarkPosition elindult string list length ${stringList.length}');
  //  print('searchBookMarkPosition $bookCode');
    int oldalszam=0;
    int talalathelye = 0;
   Book book=await pMGetBook(bookCode);
    String konyvString=book.ebookString;
    String eredetiKeresendo=book.bookMarkText;
    String reszlet = '';

    String baseBookString=konyvString;
    konyvString = konyvString.toLowerCase();
    print('xx konyvstring length1 ${konyvString.length}');
    List l = konyvString.split(' ');
    List li=konyvString.split('\n');
    l.addAll(li);
    print(l.length);
    konyvString =
        konyvString.replaceAll('!', '').replaceAll('?', '').replaceAll(',', '')
            .replaceAll('.', '')
            .replaceAll('\n', ' ');
    // konyv.replaceAll(",","");
    print('xx konyvstring length2 ${konyvString.length}');
    List l2 = konyvString.split(' ');
    print('aaaaaaaaaaaaaaaaaaaaaaaaaa ${l2.length}');

    print('eredeti keresendo: $eredetiKeresendo');
    eredetiKeresendo =
        eredetiKeresendo.substring(0, eredetiKeresendo.lastIndexOf(" "));
    eredetiKeresendo =
        eredetiKeresendo.substring(eredetiKeresendo.indexOf(" ") + 1);
    eredetiKeresendo = eredetiKeresendo.toLowerCase();
    eredetiKeresendo =
        eredetiKeresendo.replaceAll('!', '').replaceAll('?', '').replaceAll(
            ',', '').replaceAll('.', '').replaceAll('\n', ' ');
    //  eredetiKeresendo.replaceAll(new RegExp(r'[a-zA-Z]'), '');
//  kereses.replaceAll(',',"");



    print('lowercase kereseeeeeeeeeeeeeeeeeeeeees: $eredetiKeresendo');
    var szoLista = eredetiKeresendo.split(' ');
    List<String> listString = [];
    String negySzo = '';
    for (int i = 0; i <= szoLista.length - 4; i++) {
      listString.add(negySzo);
      negySzo = '';
      for (int a = i; a <= i + 3; a++) {
        negySzo += ' ${szoLista[a]}';
      }
    }
    for (int i = 0; i < listString.length; i++) {
      if (keresTalalatSzam(konyvString, listString[i]) == 1) {
        print('keresescase sikeeeer!');
        print('$i ${listString[i]}');

        talalathelye = konyvString.indexOf(listString[i]);
        String joMondat = listString[i];
        print('pms search talalathelye: $talalathelye');

        int baseStringTalalatHely= await butaStringCaractertoNormalString(konyvString, talalathelye,baseBookString);

      //  reszlet = konyvString.substring(baseStringTalalatHely, baseStringTalalatHely + 300);
       // await pMPontListabanElhelyetes(bookCode,baseStringTalalatHely, audioMp, joMondat);
          int caracterValue=0;
          for(int i=0;i<stringList.length;i++){
            caracterValue+= stringList[i].length;
            if(baseStringTalalatHely<caracterValue){
              print(' if(baseStringTalalatHely<caracterValue)');
              oldalszam=i;
              break;
            }
          }

        break;
      }
    }


    print('String length: ${konyvString.length} text helye: $talalathelye RESZLET: $reszlet');
    //   return talalathelye;

    return oldalszam;
  }
  pMSearch(String bookCode, String konyvString, String eredetiKeresendo, int audioMp,BuildContext buildContext) async {
    bool succes=false;
    int baseStringTalalatHely=0;
    print('pMSearch elindult');
    int talalathelye = 0;
    String joKereoMondat;
    print(
        '----------------------------------------------------------------------------');
    String egyszerusitettreszlet = '';
    String basicreszlet = '';
    //'  eredetiKeresendo='the works have been ordered destroyed by the king of Ireland when he outlawed magic from the weight Kael said used to with a tinge of sadness she assumed';
    // eredetiKeresendo='r concocted. She dropped her cape to the floor. With a roar that shook the castle, the ridderak ran for her. Celaena remained before the door';
    String baseBookString=konyvString;
    konyvString = konyvString.toLowerCase();
    //print('xx konyvstring length1 ${konyvString.length}');
     List l = konyvString.split(' ');
     List li=konyvString.split('\n');
     l.addAll(li);
    print(l.length);
    konyvString =
        konyvString.replaceAll('!', '').replaceAll('?', '').replaceAll(',', '')
            .replaceAll('.', '')
            .replaceAll('\n', ' ');
    // konyv.replaceAll(",","");


    print('xx konyvstring length2 ${konyvString.length}');
    List l2 = konyvString.split(' ');
    print('aaaaaaaaaaaaaaaaaaaaaaaaaa ${l2.length}');

      print('eredeti keresendo: $eredetiKeresendo');
    eredetiKeresendo =
        eredetiKeresendo.substring(0, eredetiKeresendo.lastIndexOf(" "));
    eredetiKeresendo =
        eredetiKeresendo.substring(eredetiKeresendo.indexOf(" ") + 1);
    eredetiKeresendo = eredetiKeresendo.toLowerCase();
    eredetiKeresendo =
        eredetiKeresendo.replaceAll('!', '').replaceAll('?', '').replaceAll(
            ',', '').replaceAll('.', '').replaceAll('\n', ' ');
    //  eredetiKeresendo.replaceAll(new RegExp(r'[a-zA-Z]'), '');
//  kereses.replaceAll(',',"");


   print('konyvstring: $konyvString');
    print('lowercase kereseeeeeeeeeeeeeeeeeeeeees: $eredetiKeresendo');
    var szoLista = eredetiKeresendo.split(' ');
    List<String> listString = [];
    String negySzo = '';
    for (int i = 0; i <= szoLista.length - 4; i++) {
      listString.add(negySzo);
      negySzo = '';
      for (int a = i; a <= i + 3; a++) {
        negySzo += ' ${szoLista[a]}';
      }
    }

    for (int i = 0; i < listString.length; i++) {
      if (keresTalalatSzam(konyvString, listString[i]) == 1) {
        succes=true;
        print('keresescase sikeeeer!');
        print('$i ${listString[i]}');

        talalathelye = konyvString.indexOf(listString[i]);
        print('search konyvstring ${baseBookString.length}');
        String joMondat = listString[i];
        print('pms search talalathelye: $talalathelye');

        baseStringTalalatHely= await butaStringCaractertoNormalString(konyvString, talalathelye,baseBookString);

        egyszerusitettreszlet = konyvString.substring(talalathelye, talalathelye + 300);
        basicreszlet = baseBookString.substring(baseStringTalalatHely, baseStringTalalatHely + 300);

        await pMPontListabanElhelyetes(bookCode,baseStringTalalatHely, audioMp, joMondat);
        await sorbanPontListabanElhelyezes(bookCode,baseStringTalalatHely, audioMp);

        break;
      }
    }

    if(!succes) {
      Navigator.pop(buildContext);
      ppp.showMyDialog("error","Sync failed, the two book is maybe different, or audiobook quality is bad, or it is in wrong language. ",buildContext);
    }

      print('String length: ${konyvString.length} text helye: $talalathelye egyszeruRESZLET: $egyszerusitettreszlet \n BasicRESZLET: $basicreszlet');
      //   return talalathelye;

      return baseStringTalalatHely;

  }
  pMSearchForPhoto(String bookCode, String konyvString, String eredetiKeresendo) async {
    int baseStringTalalatHely=0;
    print('pMSearch elindult');
    int talalathelye = 0;
    String joKereoMondat;
    print(
        '----------------------------------------------------------------------------');
    String egyszerusitettreszlet = '';
    String basicreszlet = '';
    //'  eredetiKeresendo='the works have been ordered destroyed by the king of Ireland when he outlawed magic from the weight Kael said used to with a tinge of sadness she assumed';
    // eredetiKeresendo='r concocted. She dropped her cape to the floor. With a roar that shook the castle, the ridderak ran for her. Celaena remained before the door';
    String baseBookString=konyvString;
    konyvString = konyvString.toLowerCase();
    //print('xx konyvstring length1 ${konyvString.length}');
    List l = konyvString.split(' ');
    List li=konyvString.split('\n');
    l.addAll(li);
    print(l.length);
    konyvString =
        konyvString.replaceAll('!', '').replaceAll('?', '').replaceAll(',', '')
            .replaceAll('.', '')
            .replaceAll('\n', ' ');
    // konyv.replaceAll(",","");


    print('xx konyvstring length2 ${konyvString.length}');
    List l2 = konyvString.split(' ');
    print('aaaaaaaaaaaaaaaaaaaaaaaaaa ${l2.length}');

    print('eredeti keresendo: $eredetiKeresendo');
    eredetiKeresendo =
        eredetiKeresendo.substring(0, eredetiKeresendo.lastIndexOf(" "));
    eredetiKeresendo =
        eredetiKeresendo.substring(eredetiKeresendo.indexOf(" ") + 1);
    eredetiKeresendo = eredetiKeresendo.toLowerCase();
    eredetiKeresendo =
        eredetiKeresendo.replaceAll('!', '').replaceAll('?', '').replaceAll(
            ',', '').replaceAll('.', '').replaceAll('\n', ' ');
    //  eredetiKeresendo.replaceAll(new RegExp(r'[a-zA-Z]'), '');
//  kereses.replaceAll(',',"");


    print('konyvstring: $konyvString');
    print('lowercase kereseeeeeeeeeeeeeeeeeeeeees: $eredetiKeresendo');
    var szoLista = eredetiKeresendo.split(' ');
    List<String> listString = [];
    String negySzo = '';
    for (int i = 0; i <= szoLista.length - 4; i++) {
      listString.add(negySzo);
      negySzo = '';
      for (int a = i; a <= i + 3; a++) {
        negySzo += ' ${szoLista[a]}';
      }
    }
    for (int i = 0; i < listString.length; i++) {
      if (keresTalalatSzam(konyvString, listString[i]) == 1) {
        print('keresescase sikeeeer!');
        print('$i ${listString[i]}');

        talalathelye = konyvString.indexOf(listString[i]);
        print('search konyvstring ${baseBookString.length}');
        String joMondat = listString[i];
        print('pms search talalathelye: $talalathelye');

        baseStringTalalatHely= await butaStringCaractertoNormalString(konyvString, talalathelye,baseBookString);

        egyszerusitettreszlet = konyvString.substring(talalathelye, talalathelye + 300);
        basicreszlet = baseBookString.substring(baseStringTalalatHely, baseStringTalalatHely + 300);




        break;
      }
    }


    print('String length: ${konyvString.length} text helye: $talalathelye egyszeruRESZLET: $egyszerusitettreszlet \n BasicRESZLET: $basicreszlet');
    //   return talalathelye;

    return baseStringTalalatHely;
  }
  printSzovegDarab(String szoveg, int hol, String printszoveg){
    String reszlet='';
    reszlet = szoveg.substring(hol, hol + 300);
    print('$printszoveg $reszlet');
  }
  butaStringCaractertoNormalString(String butaString,int butaCaracterSzama,String normStringg)async{
    List asdbutaSList = butaString.split(' ');
    print('asdbutaSList ${asdbutaSList.length}');
       butaString=butaString.substring(0,butaCaracterSzama);
       String asdhatsoparresz=butaString.substring(butaString.length-50,butaString.length);
       print('yyyyyyyyyyyyyyyyyyy hatsoresz  $asdhatsoparresz}');
    List butaSList = butaString.split(' ');
    List normStrList=normStringg.split(new RegExp(r"[\n ]"));
    print('buta: ${butaSList.length} és norm: ${normStrList.length}');
       print('normstringlistlength1 ${normStrList.length}');
    normStrList.removeRange(butaSList.length, normStrList.length);
    print('normstringlistlength2 ${normStrList.length}');
    String listToString= normStrList.join(" ");
     //   int talalathelye = listToString.indexOf('say much as they walked');

    return listToString.length;
  }

  keresTalalatSzam(String konyvS, String keresendo) {
    int talalatSzam = keresendo
        .allMatches(konyvS)
        .length;
    return talalatSzam;
  }

 /* pMPDFtoStringeredeti(String bookCode) async {
    print('pdf to string start---------------------------------');
    Book book= await pMGetBook(bookCode);
    String path=book.ebookPath;
    String konyvString = 'ures';



    print('pdf path: $path ------------------------------------------');
    PDFDoc doc = await PDFDoc.fromPath(path);

    konyvString = await doc.text;
    await ppp.pMSharedStringSet('proba', konyvString);

    konyvString=konyvString.replaceAll('\n','');
    konyvString=konyvString.replaceAll('.\r','.\n');
    konyvString=konyvString.replaceAll('?\r','?\n');
    konyvString=konyvString.replaceAll('!\r','!\n');

        book.ebookString=konyvString;
        print('book.string${book.ebookString}');

        await pMSetBook(book);

  //  pMElsoUtolsoSyncPontHozzaadas(bookCode);
    print('return String ------------------------------------');
    return konyvString;
  }*/
  pMPDFtoString(String bookCode, BuildContext buildContext) async {
    print('pdf to string start---------------------------------');
    Book book= await pMGetBook(bookCode);
    String path=book.ebookPath;
    String konyvString = 'ures';



    print('pdf path: $path ------------------------------------------');
    final PdfDocument document =
    PdfDocument(inputBytes: File(path).readAsBytesSync());
//Extract the text from all the pages.
    konyvString = PdfTextExtractor(document).extractText();
//Dispose the document.
    document.dispose();
    await ppp.pMSharedStringSet('proba', konyvString);
   //konyvString=konyvString.substring(1300,4000);
    konyvString=konyvString.replaceAll('\n','');
    konyvString=konyvString.replaceAll('\r',' ');
   // konyvString=konyvString.replaceAll('.\r','.\n');
  //  konyvString=konyvString.replaceAll('?\r','?\n');
 //   konyvString=konyvString.replaceAll('!\r','!\n');



   // konyvString=konyvString.replaceAll(new RegExp(r"(?<=\.\n)"), "XXX");
  //  konyvString=konyvString.replaceAll('\n', " ");

   // konyvString=konyvString.replaceAll('XXX', ".\n");
   // konyvString=konyvString.replaceAll(" ", "D").replaceAll("\t", "TT").replaceAll("\b", "BB").replaceAll(".", "Pont");
    //konyvString=konyvString.replaceAll(new RegExp(r"\s+"), "");
  //  konyvString=konyvString.replaceAll("\n", "");
    book.ebookString=konyvString;
    print('book.string${book.ebookString}');

    await pMSetBook(book);
   String language= await getThelanguageOfThis(konyvString);
    await saveIbmLanguageBasedOnThis(bookCode, language, buildContext);
    //  pMElsoUtolsoSyncPontHozzaadas(bookCode);
    print('return String ------------------------------------');
    return konyvString;
  }
  pMEpubtoString(String bookCode,BuildContext buildContext) async {
    print('epub to string start---------------------------------');
    Book book= await pMGetBook(bookCode);
    String path=book.ebookPath;
    String konyvString = 'ures';



    print('epub path: $path ------------------------------------------');
    /*var targetFile = new File(path);
    List<int> bytes = await targetFile.readAsBytes();
    EpubBook epubBook = await EpubReader.readBook(bytes);
    String? title = epubBook.Title;
    print("titleeeeeeeeeeeee: $title");*/

    File _epubFile = File(path);
    final contents = await _epubFile.readAsBytes();
    EpubBookRef epub = await EpubReader.openBook(contents.toList());
    var cont = await EpubReader.readTextContentFiles(epub.Content!.Html!);
    List<String> htmlList = [];
    for (var value in cont.values) {
      htmlList.add(value.Content!);
    }
    var doc = parse(htmlList.join());
     konyvString = parse(doc.body!.text).documentElement!.text;




    await ppp.pMSharedStringSet('proba', konyvString);

    //konyvString=konyvString.substring(1300,4000);
    konyvString=konyvString.replaceAll('\n','');
    konyvString=konyvString.replaceAll('\r',' ');
    // konyvString=konyvString.replaceAll('.\r','.\n');
    //  konyvString=konyvString.replaceAll('?\r','?\n');
    //   konyvString=konyvString.replaceAll('!\r','!\n');



    // konyvString=konyvString.replaceAll(new RegExp(r"(?<=\.\n)"), "XXX");
    //  konyvString=konyvString.replaceAll('\n', " ");

    // konyvString=konyvString.replaceAll('XXX', ".\n");
    // konyvString=konyvString.replaceAll(" ", "D").replaceAll("\t", "TT").replaceAll("\b", "BB").replaceAll(".", "Pont");
    //konyvString=konyvString.replaceAll(new RegExp(r"\s+"), "");
    //  konyvString=konyvString.replaceAll("\n", "");
    book.ebookString=konyvString;
    print('book.string${book.ebookString}');

    await pMSetBook(book);
    String language= await getThelanguageOfThis(konyvString);
    await saveIbmLanguageBasedOnThis(bookCode, language, buildContext);
    //  pMElsoUtolsoSyncPontHozzaadas(bookCode);
    print('return String ------------------------------------');
    return konyvString;
  }
}



class SyncPontok {
  int textKarakterSzam=0;
  int audioMp=0;
  String joKereoMondat='';

  SyncPontok(int this.textKarakterSzam, int this.audioMp, String this.joKereoMondat);


   SyncPontok.fromJson(Map<String, dynamic> json)
      : textKarakterSzam = json['textKarakterSzam'],
        audioMp = json['audioMp'],
        joKereoMondat = json['joKereoMondat'];

  Map<String, dynamic> toJson() {
     return {
        'textKarakterSzam': textKarakterSzam,
        'audioMp': audioMp,
        'joKereoMondat': joKereoMondat,
      };
      }

}
class BeforeAfterSyncPoint{
int? before;
int? after;
BeforeAfterSyncPoint( int beforeIn,int afterIn){
  before=beforeIn;
  after=afterIn;
}

}
class BeforeAfterPointsDiference{
int beforeDif=0;
int afterDif=0;
BeforeAfterPointsDiference(int beforeDifIn,int afterDifIn){
  beforeDif=beforeDifIn;
  afterDif=afterDifIn;
}
}

class Book{
  Mfp mfp=new Mfp();
  String ebookName='';
  String ebookPath='';
  String ebookString='';

  String aBookName='';
  String aBookPath='';

  String bookCode='';
  String bookMarkText='';
  int bookMarkCaracter=0;
  int bookMarkMp=0;
  bool lastWasEbook=true;
  String bookCoverPath='';

 // Book(  String this.ebookName,String this.ebookPath,String this.ebookString,String this.aBookName,String this.aBookPath);
  Book();
  Book.fromJson(Map<String, dynamic> json) : ebookName = json['ebookName'],  ebookPath = json['ebookPath'], ebookString = json['ebookString'], aBookName = json['aBookName'],aBookPath = json['aBookPath'],bookCode = json['bookCode'],bookMarkText = json['bookMarkText'],bookMarkCaracter = json['bookMarkCaracter'],bookMarkMp = json['bookMarkMp'],lastWasEbook = json['lastWasEbook'],bookCoverPath = json['bookCoverPath'];
  Book.setEABok(String this.ebookName,  String this.ebookPath, String this.ebookString, String this.aBookName,String this.aBookPath, String this.bookCode, String this.bookMarkText, int this.bookMarkCaracter, int this.bookMarkMp, bool this.lastWasEbook, String this.bookCoverPath);
  Map<String, dynamic> toJson() => {
    'ebookName': ebookName,
    'ebookPath': ebookPath,
    'ebookString':ebookString,
    'aBookName':aBookName,
    'aBookPath':aBookPath,
    'bookCode':bookCode,
    'bookMarkText':bookMarkText,
    'bookMarkCaracter':bookMarkCaracter,
    'bookMarkMp':bookMarkMp,
    'lastWasEbook':lastWasEbook,
    'bookCoverPath':bookCoverPath,

  };

  setEbook(String eBookPathBe){
    ebookPath=eBookPathBe;
     ebookName = eBookPathBe.split('/').last;



  }
  setAbook(String aBookPathBe){
    aBookPath=aBookPathBe;
     aBookName = aBookPathBe.split('/').last;

  }
  setBookCode(String bookCodebe){
    bookCode=bookCodebe;
  }


}
