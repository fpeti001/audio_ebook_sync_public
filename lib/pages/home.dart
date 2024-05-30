import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:audio_ebook_sync/aebook_styles.dart';
import 'package:audio_ebook_sync/aebook_styles.dart';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:audio_ebook_sync/services/text_handeling.dart';
import 'package:audio_ebook_sync/utils/Language.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:new_version/new_version.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_ebook_sync/services/pspeech_to_text.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_ebook_sync/services/ibm_speech_to_text.dart';
import 'package:audio_ebook_sync/utils/IamOptions.dart';
import 'dart:async';
import 'dart:math';
import 'package:audio_ebook_sync/pages/loading_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../auth/secrets.dart';


//asfd
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String chosenBookCode='';
  late BuildContext popupContext;

  late StateSetter _setState;
  String _demoText = "test";
  List <String> mp3PathList=[];
 // String chosedEbookPath='';
//  String chosedAbookPath='';
 // String chosedEBook='';
 // String chosedABook='';
   Book chosedBook=Book();

  String jsonResoult = 'jsonToResoult alap';
  PPP ppp = PPP();
  Mfp mfp = Mfp();

  String convertedFileName = 'output15.wav';
  PCSpeechWriter? pCSpeechWriter;
  String filepath = 'load filepath';
  late String outputPath;

  final player = AudioPlayer();
  String audioSzoveg = ' load audio speach';
  String? rawDocumentPath;
  //final assetsAudioPlayer = AssetsAudioPlayer();
  List<Book> bookList = [];
  // String ffmpegExecuteString=' -f pcm_u16le -ar 44100 -ac 1 -i $path $outputPath';
  String readerSearch = 'As she expected, Grave launched himself at her';
  PCTextHandeling? pcTextHandeling;
  //String konyvString = 'konyvstring betoltes';
  bool syncPurchased=false;
  late SharedPreferences sharedPreferences;
 bool developerUpgrade=false;
 // static final facebookAppEvents = FacebookAppEvents();



  Future<void> bookDeleteDialog(String title, String content, int bookindex) async {

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
              child:  Text("Cancel"),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
             TextButton(
              child:  Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                deleteBook(bookindex);

              },
            ),
          ],
        );
      },
    );
  }

  firstStart()async{
  bool firstStart=await sharedPreferences.getBool("firststart")??true;
if(firstStart){
  upgrade();
 await sharedPreferences.setBool("firststart", false);

}
}
  rateUs()async{
   String string= sharedPreferences.getString("rateusdate")??"";
    if(!(string.contains("volt") )){
      if(string==""){
        await sharedPreferences.setString ("rateusdate", DateTime.now().add(Duration(days: 6)).toString());
      }else{
        DateTime datetime=DateTime.parse(string);
        DateTime datetimeNow=DateTime.now();
        Duration dayDiference= datetimeNow.difference(datetime);
        int dayDifference=dayDiference.inDays;
        if(dayDifference>7){
          await sharedPreferences.setString ("rateusdate", DateTime.now().toString());
          rateUsDialog();
        }

      }
    }
  }
    rateUsDialog()async{
      print("rateuss");
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Do you like the Application?"),

            actions: <Widget>[
              TextButton(
                child: const Text('later'),
                onPressed: () async {
                  await  sharedPreferences.setString("rateusdate",DateTime.now().toString())!;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('no'),
                onPressed: () async {
                  await  sharedPreferences.setString("rateusdate","volt")!;
                  Navigator.of(context).pop();
                },

              ),
              TextButton(
                child: const Text('yes'),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;

                  inAppReview.requestReview();

                  await  sharedPreferences.setString("rateusdate","volt")!;
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        },
      );






  }

  sendFeedback()async {
    final Email email = Email(
      body: 'My feedback is:\n',
      subject: 'AEBook Feedback',
      recipients: ['fpeti002@gmail.com'],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
  }



  Future<void> initPurchase() async {
    await Purchases.setDebugLogsEnabled(true);

    if (Platform.isAndroid) {
      print("--------------------------androiiidddd");
      await Purchases.setup(SecretClass.purchaseSetupApiKey);
    } else if (Platform.isIOS) {


      await Purchases.setup(SecretClass.purchaseSetupApiKey);
    }
  }

  openEbookReader(int index,BuildContext context)async{

    Book book=await mfp.getBookByIndex(index);

 //   if(kDebugMode)syncPurchased=false;
   // if(!syncPurchased) book.lastWasEbook=true;
    await mfp.pMSetBook(book);
    await mfp.pMNowReadingSet(book.bookCode);
    Navigator.pushNamed(context, '/reader').then((_) {
      // This block runs when you have returned back to the 1st Page from 2nd.
      initAsync();
    });

  }
  openAbookPlayer(int index,BuildContext context)async{

    Book book=await mfp.getBookByIndex(index);

//    if(kDebugMode)syncPurchased=false;
    //if(!syncPurchased) book.lastWasEbook=false;
    await mfp.pMSetBook(book);

    await mfp.pMNowReadingSet(book.bookCode);
    Navigator.pushNamed(context, '/player').then((_) {
      // This block runs when you have returned back to the 1st Page from 2nd.
      initAsync();
    });
  }






deleteBook(int index )async{
  await mfp.pMDeleteBook(index);
  bookList.removeAt(index);
setState(() {

});
}

  initAsync()async{


    if(kDebugMode)syncPurchased=developerUpgrade;
      sharedPreferences=await SharedPreferences.getInstance();
     // await  sharedPreferences.setString("rateusdate","")!;
     await rateUs();
   await initPurchase();

    try {
      print('aaaaaaaaaaaaaa');
      bookList = await ppp.pMSharedListBooksGet('books');
      syncPurchased=await ppp.pMSharedBoolGet('syncPurchased')??false;
      if(kDebugMode)syncPurchased=developerUpgrade;
      String  konyvString2=chosedBook.ebookString;
      print('$konyvString2 --------------------------------');
      setState(() {});
    }catch (e){print('start try error$e');}

   await isPurchased();
   await firstStart();
   // final newVersion = NewVersion();
  //  newVersion.showAlertIfNecessary(context: context);

    //print('${(await rootBundle.loadString('assets/test_service_account.json'))}');



 //  await sharedPreferences.setString ("ondaysyncdate","");
  }
  choseEbook()async{
   String lEbookPath="";
   lEbookPath= await ppp.pMfilepickernyito();
    String ebookFormat=lEbookPath.substring(lEbookPath.lastIndexOf('.'));

    if(ebookFormat.contains('epub')||ebookFormat.contains('pdf')||ebookFormat.contains('PDF')) {
      chosedBook.ebookPath=lEbookPath;
      chosedBook.ebookName = chosedBook.ebookPath.split('/').last;
      if(chosedBook.bookCode.isEmpty) {
        chosenBookCode=ppp.getRandomString(10);
        chosedBook.setBookCode(chosenBookCode);
        print('create book code');
      }
      _setState(() {});

    }else{
      ppp.showMyDialog("Error", "$ebookFormat is wrong file format :/ \n For Ebook acceptable file format is: PDF and EPUB", context);
    }



  }
  choseAbook()async{
    String lAbookPath="";
    lAbookPath=await mfp.pickFolder();

    mp3PathList=[];
    mp3PathList=await mfp.folderPathToContainingMp3Paths(lAbookPath);
    if(mp3PathList.length>0){
      chosedBook.aBookPath=lAbookPath;
      chosedBook.aBookName = chosedBook.aBookPath.split('/').last;
      if(chosedBook.bookCode.isEmpty) {
        chosenBookCode=ppp.getRandomString(10);
        chosedBook.setBookCode(chosenBookCode);
        print('create book code');
      }
      _setState(() {});

    }else{
      ppp.showMyDialog("Error", " There is no file with acceptable format in this folder.  \n For Audiobook acceptable file format is: \nmp3, wav, m4a, m4b, mp4, flv, flac fmp4, ogg, webm", context);
    }




  }
  choosingFinished(BuildContext context)async{
    print('choosingFinishd start----------------------------------');


    try {
      bookList = await ppp.pMSharedListBooksGet('books');
    } catch (e) {
      print(e);
    }

    bool bennevan = false;
    print('${bookList.length} ----------------------------------lengthhhhhhhhhhhhhh');
    for (int i = 0; i < bookList.length; i++) {

      if (chosedBook.ebookPath == bookList[i].ebookPath) {
        if (chosedBook.aBookPath == bookList[i].aBookPath) {
          bennevan = true;
          ppp.showMyDialog('Duplication', 'This book or book combination already exist ', context);
        }
      }
    }


    if(!bennevan){ //ha nincs benne
      print('!bennevan start----------------------------------');
      //Eboook nem üres
      if(!chosedBook.ebookName.isEmpty){
        chosedBook.bookMarkCaracter=0;


      }
      //Aboook nem üres
      if(!chosedBook.aBookName.isEmpty){

        print('/Aboook nem üres----------------------------------');
        chosedBook.bookMarkMp=0;
        mp3PathList=[];
        mp3PathList=await mfp.folderPathToContainingMp3Paths(chosedBook.aBookPath);


        await ppp.pMSharedListSet('mp3PathList$chosenBookCode', mp3PathList);
        List<int> durationList=  await mfp.pathListToDurationList(mp3PathList);
        await ppp.pMSharedIntListSet('durationList$chosenBookCode', durationList);
      }


      //mindketto van

      //vagy vagy
      if(!chosedBook.ebookName.isEmpty || !chosedBook.aBookName.isEmpty){
       // print('vagy vagy----------------------------------');
        if(!chosedBook.aBookName.isEmpty){
          chosedBook.bookCoverPath=await mfp.folderPathtoCoverPath(chosedBook.aBookPath);
        }else{
          String eBookJustPath=chosedBook.ebookPath.substring(0,chosedBook.ebookPath.lastIndexOf('/'));
          chosedBook.bookCoverPath=await mfp.folderPathtoCoverPath(eBookJustPath);
        }

        bookList.insert(0,chosedBook);
        await ppp.pMSharedListBooksSet('books', bookList);
        print('book was not in the list. now its added');

        print('first and last Sync point added');

        List<SyncPontok> syncPontokList=[];
        await ppp.pMSharedListSyncPontokSet(chosedBook.bookCode, syncPontokList);

      }
      if(!chosedBook.ebookName.isEmpty){
        await mfp.doSomethingAndLoad(context, 0, chosedBook.bookCode);

      }
      if(!chosedBook.ebookName.isEmpty && !chosedBook.aBookName.isEmpty) {


        await mfp.pMElsoUtolsoSyncPontHozzaadas(chosedBook.bookCode);


      }
      setState(() {});



    }else{
      print('book already in the list');
    }

    Navigator.of(popupContext).pop();
    print('finish---------------------------------');





  }






  getTexFromSpeech() async {
    pCSpeechWriter = PCSpeechWriter(filepath, 3, 9);
    await pCSpeechWriter!.pMAudioSnipetToText();
    setState(() {
      audioSzoveg = pCSpeechWriter!.text;
      print('text  $audioSzoveg ');
    });
  }

  filepickernyito() async {
    String filepath2='';
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      setState(() {
        filepath = file.path;
        filepath2=file.path;
      });
      print('------------------------------file selection finished$filepath');

      //await conver(filepath);
    } else {
      // User canceled the picker
    }
    return filepath2;
  }

  //------------------------------vackok-----VVVVVVVVVVVVVVVV

 /* playAsset(String path) {
//String path ='/data/user/0/com.example.audio_ebook_sync/app_flutter/recordedFile2.wav';
    final Audio audio = Audio.file(path);
    var duration = 0;
    assetsAudioPlayer.open(
      audio,
      //   Audio("assets/test3.wav"),
    );
    print('paying asset');
    assetsAudioPlayer.play();
  }*/

  //--------------------------------------frontend-----VVVVVVVVVVVVVVVVVVVVVVVVV

upgrade()async{



  Navigator.pushNamed(context, '/purchase',
  arguments: "sajtargument").then((_) async {
   await isPurchased();
    // This block runs when you have returned back to the 1st Page from 2nd.

  });
//await mfp.epubproba();











  /*final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

//String path=await ppp.pMfilepickernyito();
  String path=photo!.path;
print("path::: $path");
final inputImage = InputImage.fromFilePath(path);
print("asd2");
final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
print("asd3");
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
print("asd4");
String text = recognizedText.text;
print(text);*/


/*String pdfPath=await filepickernyito();
//Load an existing PDF document.
  final PdfDocument document =
  await PdfDocument(inputBytes: File(pdfPath).readAsBytesSync());
//Extract the text from all the pages.
  String text3 = PdfTextExtractor(document).extractText();
//Dispose the document.
  document.dispose();
  text3=text3.substring(0,1000);
 String text4= json.encode(text3);

print ('asd ${text4}');

*/


/*Book asdbook=bookList[2];
String probaString=await ppp.pMSharedStringGet('proba');
print(probaString.substring(1000).replaceAll('\n', '\nX'));*/
//print(asdbook.ebookString.substring(1000).replaceAll('\n', '\nX'));


/*  Navigator.pushNamed(context, '/audio').then((_) {
    // This block runs when you have returned back to the 1st Page from 2nd.
    start();
  });*/

/*
List<Book> boogklistsdf=await ppp.pMSharedListBooksGet('books');
print('boooklistlength ${boogklistsdf.length}');
  ppp.showMyDialog('lastWasEbook ${book2.lastWasEbook.toString()}', book2.bookCode, context);
*/


    /*String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    // User canceled the picker
  }
*/

/*
Book book=await mfp.getBookByIndex(0);
//book.bookMarkCaracter=3600;
book.lastWasEbook=true;
await mfp.pMSetBook(book);
Book book2=await mfp.pmNowReadingGet();
print('aaaaaaaaaaaaaaaaaaaaaaxxxxxxxxxxxx ${book2.bookMarkMp}');
*/


/*  Book book2= await mfp.pmNowReadingGet();

  String blabal='';
  List<SyncPontok> sadf=await ppp.pMSharedListSyncPontokGet(book2.bookCode);
  for(int i=0;i<sadf.length;i++){
    blabal+='mp: ${(sadf[i].audioMp)/60~/60}:${(sadf[i].audioMp)/60%60~/1}:${(sadf[i].audioMp)%60%60} caracter: ${(sadf[i].textKarakterSzam)} kereso text: ${(sadf[i].joKereoMondat)} mpben ${(sadf[i].audioMp)}\n';

  }


  print(blabal);*/
//  print('hoszaaaa: ${chosedBookFinishd.ebookString.length}');
//  print('konyvstring hosza= ${chosedBookFinishd.ebookString.length}');
/* String  konyvString3=chosedBookFinishd.ebookString;
   int talalathelye = konyvString3.indexOf('say much as they walked');
  String reszlet = konyvString3.substring(223318, 223318 + 300);
  print('$talalathelye izehoze$reszlet --------------------------------');*/
}
  isPurchased()async{

try{
  PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
  print("purchaserinffoo =$purchaserInfo");
  print("syncPurchased =${purchaserInfo.entitlements.all["1entitlement"]!.isActive}");
  syncPurchased=purchaserInfo.entitlements.all["1entitlement"]!.isActive;
  if(kDebugMode)syncPurchased=developerUpgrade;

  await ppp.pMSharedBoolSet("syncPurchased", syncPurchased);

  print("subscription ${purchaserInfo.entitlements.all["1entitlement"]?.isActive}");

  setState(() {});
}catch(e){
  syncPurchased=false;
  if(kDebugMode)syncPurchased=developerUpgrade;
  await ppp.pMSharedBoolSet("syncPurchased", syncPurchased);
  setState(() {});
}







  }



  initstate2() async {

  await  initAsync();



    //  List<SyncPontok> syList=[];
    //  ppp.pMSharedListSyncPontokSet('syncList1', syList);
    /*  SyncPontok syncpontok1=new SyncPontok(123123, 54321, 'joKereoMondat');
    SyncPontok syncpontok2=new SyncPontok(2222222, 22542321, 'kettojoKereoMondat');
   List<SyncPontok> syList=[];
   syList.add(syncpontok1);
    syList.add(syncpontok2);
   await  ppp.pMSharedListSyncPontokSet('dubi',syList);
    List<SyncPontok> dubi=await ppp.pMSharedListSyncPontokGet('dubi');

print('aaaaaaaaaaaaaaaa$dubi');*/

    /* for(int i =0;i<syList.length;i++){
     // SyncPontok syncpontok=new  SyncPontok(syList[i].textKarakterSzam,syList[i].audioMp, syList[i].joKereoMondat);
      syList[i].toJson();
      Map m={'textKarakterSzam':syList[i].textKarakterSzam,
      'audioMp':syList[i].audioMp,
      'joKereoMondat':syList[i].joKereoMondat
      };
      syList[i];
    }*/

    /* Map asd=syList[0].toJson();
   String stringike=json.encode(asd);
   Map asd2=json.decode(stringike);
   // String s =json.encode(syList);
*/

/*
    List<SyncPontok> returnSyList1=[];
    List<dynamic> sylist3 =json.decode(ashfg);
    List<Map> list3=sylist3.cast<Map>();
    print(list3.length);
    for (int i=0;i<list3.length;i++){
      returnSyList1.add(SyncPontok(list3[i]['textKarakterSzam'], list3[i]['audioMp'],  list3[i]['joKereoMondat']));
    }
    print(returnSyList1);*/
    //  syList1=json.decode(s);

    //await ppp.pMSharedStringSet2('lll',syList);

    // List<SyncPontok> sharedSyncPontok=await ppp.pMSharedStringGet2('lll');

    // print(syList[0].textKarakterSzam);

    // List<String> blabla=await ppp.pMSharedListGet('asdfg');
    // print('1111111111111111111111111111111111$blabla');


    /*
    konyvString =  chosedBookFinishd.ebookString;
    konyvReszlet = await mfp.pMSearch(
        chosedBookFinishd.ebookPath,
        konyvString,
        'mercilessly at her chest. She lifted her hands to touch her curled and',
        konyvjelzoHang);
    List<SyncPontok> dubi = await ppp.pMSharedListSyncPontokGet('syncList1');
    for (int i = 0; i < dubi.length; i++) {
      print('${dubi[i].textKarakterSzam}sorszam:$i');
    }
   */
  }

  loadImage(String path){

  print('imaggeeeeeepath= $path');
    if(path.isNotEmpty){
      return Image.file(new File(path));
    }else{
      //return Padding(padding: EdgeInsets.all(3),child:Image.asset("assets/no-image.png") ,);
      return Center(child: Padding(padding: EdgeInsets.all(3),child:Text("No \n Image",textAlign: TextAlign.center,) ,));
    }

  //  Image.file(new File(bookList[index].bookCoverPath)),

  }

  buttonOpenFilePicker() async {
    String path = await ppp.pMfilepickernyito();
    filepath = path;

  }

  @override
  void initState() {

     initstate2();

    //  findOutputPath();
    // initstate2();


    super.initState();
  }


  @override
  Widget build(BuildContext context) {
 //   FlutterStatusbarcolor.setStatusBarColor(Colors.white);
print('rebuild');
    return Scaffold(

      body:
      SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey,
                        shape: StadiumBorder(),
                        // <--- this line helped me
                      ),
                      onPressed: () async {


                        await sendFeedback();
                      },
                      child: Text("Feedback")),
                ),
                syncPurchased ? Icon(Icons.check_circle,color: Colors.deepPurple,) : SizedBox.shrink(),

             Padding(
               padding: EdgeInsets.all(8),
               child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,
                      shape: StadiumBorder(),
                      // <--- this line helped me
                    ),
                    onPressed: () async {
                //      facebookAppEvents.logPurchase(amount: 1, currency: "USD");

                     upgrade();
                    },
                    child: Text("Upgrade")),
             )
            ],),



            //       controller:_scrollController ,



            Expanded(

              child: ListView.builder(
                reverse: true,
                  itemCount: bookList.length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Container(
                        decoration: mBoxDecorationGrey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(


                                  children: [
                                    Text('Ebook: ${bookList[index].ebookName}',overflow: TextOverflow.ellipsis,),
                                    Text('Abook: ${bookList[index].aBookName}',overflow: TextOverflow.ellipsis,)
                                  ],

                                ),
                              ),
                              IntrinsicHeight(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: loadImage(bookList[index].bookCoverPath),

                                      flex:1,),
                                    Expanded(


                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.all(1),
                                              decoration: mBoxDecorationWhite,

                                              child: IconButton(

                                                onPressed: (){
                                                  if(bookList[index].aBookName!='') {
                                                    openAbookPlayer(index, context);
                                                  }
                                                },
                                                  icon:Icon(Icons.music_note_outlined),
                                                color: (bookList[index].aBookName=='' ? Colors.black : Colors.deepPurple),
                                              ),
                                            ),
                                          ),Expanded(
                                            child: Container(
                                              margin: EdgeInsets.all(1),
                                              decoration: mBoxDecorationWhite,
                                              child: IconButton(
                                                onPressed: (){
                                                  if(bookList[index].ebookName!='') {
                                                    openEbookReader(index, context);
                                                  }
                                                },
                                                icon:Icon(Icons.menu_book),
                                                color: (bookList[index].ebookName=='' ? Colors.black : Colors.deepPurple),

                                              ),
                                            ),
                                          )
                                        ],
                                      ),

                                      flex:1,),
                                    Expanded(child:  Container(
                                      margin: EdgeInsets.all(1),
                                      decoration: mBoxDecorationWhite,
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color:Colors.black,
                                        onPressed: (){
                                         //bookDeleteDialog("Are you sure you want to delete?", "", index);
                                          ppp.showDialoWithButtons("Are you sure you want to delete?", "", context, "No", "Delete", ()async{
                                            deleteBook(index);
                                          });
                                       //   deleteBook(index);
                                        },
                                      ),
                                    ),
                                      flex: 1,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),


                      /*  child: ListTile(
                          onTap: (){

                          },
                          title: Text('Ebook: ${bookList[index].ebookName} \n Abook: ${bookList[index].aBookName}'),

                        ),*/
                      ),
                    );
                  }
              ),
            ),
            Container(
              decoration: mBoxDecorationWhiteButtomMenu,
           //   color: Colors.white,
              padding:EdgeInsets.only(top:20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Row(

                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    Expanded(child: Text('Add Book',textAlign: TextAlign.center,style: TextStyle(color:Colors.deepPurple),),flex: 1,),
                     // Expanded(child: Text('proba',textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),flex: 1,),
                  ],),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.add),
                        color:Colors.deepPurple,

                        onPressed: () {
                          chosedBook=Book();
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(

                                  content: StatefulBuilder(  // You need this, notice the parameters below:
                                    builder: (BuildContext context, StateSetter setState) {
                                      _setState = setState;
                                      popupContext=context;
                                      return
                                        Container(
                                          height: 400,
                                          width: 200,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(onPressed: (){
                                                choseEbook();

                                              }, child: Text('Choose EBook'),
                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple))

                                              ),





                                              Text(chosedBook.ebookPath),

                                              ElevatedButton(onPressed: (){
                                                choseAbook();


                                              }, child: Text('Choose Audio book',),
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple))),

                                              Text(chosedBook.aBookPath),



                                            ],
                                          ),
                                        );
                                    },
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Back', style: TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Apply', style: TextStyle(color: Colors.black)),
                                      onPressed: () {
                                        choosingFinished(context);
                                      },
                                    ),


                                  ],



                                );
                              });
                        },

                      ),
                      flex: 1,
                    ),


             /*       Expanded(
                      child: IconButton(
                        icon: Icon(Icons.settings),
                          color: mGrey,
                          onPressed: () {
                            Navigator.pushNamed(context, '/asd').then((_) {
                              // This block runs when you have returned back to the 1st Page from 2nd.
                              initAsync();
                            });
                           // proba(context);
                          },

                      ),
                      flex: 1,
                    ),*/


                  ],)
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}

///data/user/0/com.example.audio_ebook_sync/cache/file_picker/Al Ries, Jack Trout - A marketing 22 vastörvénye.pdf
