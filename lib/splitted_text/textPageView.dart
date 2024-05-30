import 'dart:async';
import 'dart:ui';
import 'package:audio_ebook_sync/variables.dart';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_selection_controls/text_selection_controls.dart';
import 'package:translator/translator.dart';
import '../aebook_styles.dart';
import 'blocs/pageControlBloc.dart';
import 'constant.dart';
import 'package:wakelock/wakelock.dart';

class TextPageView extends StatefulWidget {
  const TextPageView({Key? key}) : super(key: key);

  @override
  _TextPageViewState createState() => _TextPageViewState();
}

class _TextPageViewState extends State<TextPageView> {
  bool searchApears = false;

  bool buildFinished = false;
  bool nowReadingBetoltve = false;
  String kiemelendoText = 'asdsagadfdafh';
  bool elsobetoltes = true;
  List<String> stringList = [];
  String mentendoBookMarkString = '';
  int nowPage = 1;
  int nowPageInCaracter = 0;
  String bookCode = '';
  Mfp mfp = Mfp();
  PPP ppp = new PPP();
  Book book = Book();
  final GlobalKey pageKey = GlobalKey();
  final PageController _pageController = PageController();
  double fontSizea = 18;
  Color color = Colors.black;
  Color textBackgroundColor = Colors.white;
  double sidePadding = 0;
  var isPortrait = true;
  int caracterLocationBeforRotation = 0;
  int firstLoadedPage = 0;
  String asdasd1 = "nemjo";
  final translator = GoogleTranslator();
  String translateTo = "en";
  late TextEditingController fontSizeController;
  late TextEditingController marginSizeController;
  List<String> knownWords = [];
  List<String> unknownWords = [];
  late SharedPreferences sharedPreferences;
  int knownColor = Colors.black.value;
  int unKnownColor = Colors.red.shade900.value;
  bool nowpagefirstload = true;
  bool reCalculatePage = false;
  bool bottomMenuApears = false;
  List<SyncPontok> syncPontokList = [];
  bool syncIsAvailbiable = false;
  bool syncPurchased = false;
  bool pictureSearchIsAvailbiable = false;

  TextStyle _textStyle = TextStyle(color: Colors.green, fontSize: 18);


  pop(BuildContext context){
    Navigator.of(context).pop();
  }
  upgrade() async {
    Navigator.pushNamed(context, '/purchase', arguments: "sajtargument")
        .then((_) async {
      syncIsAvailbiable = await checkSyncAvailability("ondaysyncdate");
      pictureSearchIsAvailbiable =
          await checkSyncAvailability("onedaypitcsearch");
      setState(() {});
      // This block runs when you have returned back to the 1st Page from 2nd.
    });

  }

  checkSyncAvailability(String sharedKey) async {
    bool available = false;
    if (syncPurchased) {
      available = true;
    } else {
      String string = sharedPreferences.getString(sharedKey) ?? "";
      if (string == "") {
        available = true;
        //   await sharedPreferences.setString ("rateusdate", DateTime.now().add(Duration(days: 6)).toString());
      } else {
        DateTime datetime = DateTime.parse(string);
        DateTime datetimeNow = DateTime.now();
        print("datetime $datetimeNow");
        //   Duration dayDiference = datetimeNow.difference(datetime);
        int dayDifference = (datetime.day.compareTo(datetimeNow.day)).abs();
        if (dayDifference > 0) {
          //   await sharedPreferences.setString ("rateusdate", DateTime.now().toString());
          available = true;
        }
      }
    }
    return available;
  }

  checkAvilbiableSyncPont() {
    int rVariable = 0;
    for (int i = 0; i < syncPontokList.length; i++) {
      if (syncPontokList[i].audioMp == book.bookMarkMp) {
        rVariable = syncPontokList[i].textKarakterSzam;
      }
    }
    return rVariable;
  }

  proba() async {
    int caracter = pageToCaracterNumber(nowPage);
    print("pageToCaracterNumber: $caracter");

    //int asdcaracter=await caracterToPagenumber(1560);
    //  print("caracterToPagenumber$asdcaracter");
  }

  textSizeMarginChange() async {
    if (searchApears) {
      searchApears = false;
      setState(() {});
    }
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      print('orientationChange start');
      int caracterLocationBeforChange = await pageToCaracterNumber(nowPage);

      final controlBloc = BlocProvider.of<PageControlBloc>(context);
      // WidgetsBinding.instance!.addPostFrameCallback((_) async{
      print('orientationChange start2');
      await controlBloc.getSizeFromBloc(pageKey, sidePadding);
      await controlBloc.getSplittedTextFromBloc(_textStyle, book.ebookString);
      stringList = BlocProvider.of<PageControlBloc>(context).splittedTextList;
      print("string list hossza: ${stringList.length}");
      print('setstate3');
      elsobetoltes = true;
      setState(() {});
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        int pageNumber =
            await caracterToPagenumber(caracterLocationBeforChange);
        _pageController.jumpToPage(pageNumber - 1);
        print("juuuuuuump");

        setState(() {});
      });
    });
  }

  colorItemListToTextWidget(List<ColorItem> colorItemListBe) {
    List<TextSpan> textSpanList = [];
    for (int i = 0; i < colorItemListBe.length; i++) {}
    String simpleWords = "";
    for (int i = 0; i < colorItemListBe.length; i++) {
      switch (colorItemListBe[i].knowladge) {
        case "known":
          {
            if (simpleWords != "") {
              textSpanList.add(
                TextSpan(text: simpleWords, style: _textStyle),
              );
              simpleWords = "";
            }
            textSpanList.add(
              TextSpan(
                  text: "${colorItemListBe[i].text} ",
                  style:
                      TextStyle(color: Color(knownColor), fontSize: fontSizea)),
            );
          }
          break;

        case "unknown":
          {
            if (simpleWords != "") {
              textSpanList.add(
                TextSpan(text: simpleWords, style: _textStyle),
              );
              simpleWords = "";
            }
            textSpanList.add(
              TextSpan(
                  text: "${colorItemListBe[i].text} ",
                  style: TextStyle(
                      color: Color(unKnownColor), fontSize: fontSizea)),
            );
          }
          break;

        case "highlighted":
          {
            if (simpleWords != "") {
              textSpanList.add(
                TextSpan(text: simpleWords, style: _textStyle),
              );
              simpleWords = "";
            }
            textSpanList.add(
              TextSpan(
                  text: "${colorItemListBe[i].text} ",
                  style: TextStyle(color: Colors.blue, fontSize: fontSizea)),
            );
          }
          break;

        case "":
          {
            simpleWords += colorItemListBe[i].text + " ";
          }
          break;
      }
      if (i == colorItemListBe.length - 1)
        textSpanList.add(
          TextSpan(text: simpleWords, style: _textStyle),
        );
    }

    var returnText = SelectableText.rich(
        TextSpan(
          text: '',
          style: _textStyle,
          children: textSpanList,
        ),
        cursorWidth: 0,
        selectionControls: selectionControl());

    print("textspanlis: ${textSpanList.length}");
    return returnText;
  }

  knowladgeListsToOneList(String pageText, List<String> knownWordsBe,
      List<String> unknownWordsBe, String kiemelendobe) {
    String kiemelendobeModositatlan = kiemelendobe;
    List<ColorItem> colorItemList = [];
//    print("unknownWordsBelength ${unknownWordsBe.length} tartalom ${unknownWordsBe[0]}");

    String pageTextLowerCase = pageText.toLowerCase();

    pageTextLowerCase =
        pageTextLowerCase.replaceAll(new RegExp(r'[^\w\s]+'), '');
    kiemelendobe =
        kiemelendobe.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'), '');

    List<String> pageWords = pageText.split(" ");

    List<String> pageWordsLowerCase = pageTextLowerCase.split(" ");

    for (int i = 0; i < pageWordsLowerCase.length; i++) {
      colorItemList.add(ColorItem(pageWords[i], ""));
    }

    for (int a = 0; a < pageWordsLowerCase.length; a++) {
      for (int i = 0; i < knownWordsBe.length; i++) {
        if (pageWordsLowerCase[a] == knownWordsBe[i]) {
          colorItemList[a].knowladge = "known";
        }
      }
      for (int i = 0; i < unknownWordsBe.length; i++) {
        if (pageWordsLowerCase[a] == unknownWordsBe[i]) {
          print(
              "unknowadd: pageWordsLowerCase ${pageWordsLowerCase[a]} unknownWordsBe ${unknownWordsBe[i]}");
          colorItemList[a].knowladge = "unknown";
        }
      }
      if (pageWordsLowerCase[a] == kiemelendobe) {
        colorItemList[a].knowladge = "highlighted";
      }
    }
    bool containssdfs = pageText.contains(kiemelendobeModositatlan);
    if (pageText.contains(kiemelendobeModositatlan)) {
      int highlightTextPlace = pageText.indexOf(kiemelendobeModositatlan);
      int caracterr = 0;
      for (int i = 0; i < colorItemList.length; i++) {
        if (caracterr >= highlightTextPlace) {
          for (int a = i;
              a < i + kiemelendobeModositatlan.split(" ").length;
              a++) {
            colorItemList[a].knowladge = "highlighted";
          }

          break;
        }
        caracterr += colorItemList[i].text.length + 1;
      }
    }

    return colorItemList;
  }

  selectionControl() {
    return FlutterSelectionControls(toolBarItems: [
      ToolBarItem(
          item: Text("translate"),
          onItemPressed:
              (String highlightedText, int startIndex, int endIndex) async {
            asdasd1 = highlightedText;
            print('Highlighted Text: $asdasd1');
            var translation;
            try {
              translation =
                  await translator.translate(asdasd1, to: translateTo);
            } catch (e) {
              translation = e;
            }

            String ize = translation.toString();
            print(ize);
            ppp.showTranslationDialog(ize, context);
          }),
      ToolBarItem(
          item: Text("known"),
          onItemPressed:
              (String highlightedText, int startIndex, int endIndex) async {
            await toKnownWordsList(highlightedText);
          }),
      ToolBarItem(
          item: Text("unknown"),
          onItemPressed:
              (String highlightedText, int startIndex, int endIndex) async {
            await toUnknownWordsList(highlightedText);
          }),
      /* ToolBarItem(item: Text("caracter"),
           onItemPressed: ( String highlightedText, int startIndex, int endIndex) async {
             int sajt =nowPage;
             int caracterNumber=0;
             for(int i=0;sajt-1>i;i++){
               caracterNumber=caracterNumber+stringList[i].length;
             }
             print("start index: $startIndex end index: $endIndex");
             print("sajtcaracer ${caracterNumber+startIndex}");
           }),*/

      //  ToolBarItem(item: Text('Select All'), itemControl: ToolBarItemControl.selectAll),
      ToolBarItem(item: Text("copy"), itemControl: ToolBarItemControl.copy),

      //  ToolBarItem(item: Icon(Icons.cut), itemControl: ToolBarItemControl.cut),
      //  ToolBarItem(item: Icon(Icons.paste), itemControl: ToolBarItemControl.paste),
    ]);
  }

  toKnownWordsList(String text) async {
    //List<String> lknownWords=await ppp.pMSharedListGet("knownwordslist");

    text = text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'), '');
    List<String> textList = text.split(" ");
    for (int i = 0; i < textList.length; i++) {
      if (!knownWords.contains(textList[i])) {
        //if not contains
        knownWords.add(textList[i]);
      }
      if (unknownWords.contains(textList[i])) {
        unknownWords.remove(textList[i]);
      }

      print("toknown: ");
    }
    setState(() {});
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);
  }

  toUnknownWordsList(String text) async {
    text = text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'), '');
    List<String> textList = text.split(" ");
    for (int i = 0; i < textList.length; i++) {
      if (!unknownWords.contains(textList[i])) {
        //if not contains
        unknownWords.add(textList[i]);
      }
      if (knownWords.contains(textList[i])) {
        knownWords.remove(textList[i]);
      }

      print("toknown: ");
    }
    setState(() {});

    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);
    var translation;
    try {
      translation = await translator.translate(text, to: translateTo);
    } catch (e) {
      translation = e;
    }

    String ize = translation.toString();
    print(ize);
    ppp.showTranslationDialog(ize, context);
  }

  clearUnAndKnownLists() async {
    knownWords = [];
    unknownWords = [];
    await sharedPreferences.setStringList("unknownwordslist", []);
    await sharedPreferences.setStringList("knownwordslist", []);
    setState(() {});
    /* print("words.length ");
List <String> words=["asd"];
   words = book.ebookString.split(" ");
    print("words.length ${words.length}");
    Map<String,int> count = <String,int>{};
    for (final w in words) {
      count[w] = 1 + (count[w] ?? 0);
      //print(" count w ${count[w]}");
    }

    var ordered = count.keys.toList();
    var orderedNumbers = count.values.toList();
ordered.sort((a, b) => count[b]!.compareTo(count[a]!));
    orderedNumbers.sort((b, a) => a.compareTo(b));
    print("orderedlength ${ordered.length}");
    print("orderednumberlength ${orderedNumbers.length}");
    var list;
        for(int i=0;i<10;i++){
          print("$i. : ${ordered[i]}  ${orderedNumbers[i]} ");
        }*/

//count.sort((b, a) => a.compareTo(b));

    //print("ordered$ordered");
  }

  cameraIconButtonOnPress() async {
    String photoText = await mfp.photoToText();
    int talalatHely =
        await mfp.pMSearchForPhoto(book.bookCode, book.ebookString, photoText);
    kiemelendoText = book.ebookString.substring(talalatHely, talalatHely + 20);
    int page = caracterToPagenumber(talalatHely);
    _pageController.jumpToPage(page - 1);
    if (page > 1) {
      await sharedPreferences.setString(
          "onedaypitcsearch", DateTime.now().toString());
      pictureSearchIsAvailbiable = false;
    }
  }

  orientationChange() async {
    print('orientationChange start');
    int caracterLocationBeforRotation = await pageToCaracterNumber(nowPage);

    final controlBloc = BlocProvider.of<PageControlBloc>(context);
    // WidgetsBinding.instance!.addPostFrameCallback((_) async{
    print('orientationChange start2');
    await controlBloc.getSizeFromBloc(pageKey, sidePadding);
    await controlBloc.getSplittedTextFromBloc(_textStyle, book.ebookString);
    stringList = BlocProvider.of<PageControlBloc>(context).splittedTextList;
    print("string list hossza: ${stringList.length}");
    print('setstate3');
    elsobetoltes = true;
    setState(() {});
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      int pageNumber =
          await caracterToPagenumber(caracterLocationBeforRotation);
      _pageController.jumpToPage(pageNumber - 1);

      setState(() {});
    });

    // });
  }

  caracterToPagenumber(int caracter) {
    int caracterValue = 0;
    int oldalszam = 0;
    //stringList=BlocProvider.of<PageControlBloc>(context).splittedTextList;
    print("stringliiiiiiiist: ${stringList.length}");
    for (int i = 0; i < stringList.length; i++) {
      caracterValue += stringList[i].length;
      if (caracter < caracterValue) {
        print(
            ' if(baseStringTalalatHely<caracterValue : $caracterValue oldalszam $i)');
        oldalszam = i;

        break;
      }
    }
    return oldalszam + 1;
  }

  textViewSearch(String searchWords) {
    int searchWordsCaracterPlace = book.ebookString.indexOf(searchWords);
    print('searchWordsCaracterPlace $searchWordsCaracterPlace');
    if (searchWordsCaracterPlace > 0) {
      // searchWordsCaracterPlace=searchWordsCaracterPlace-searchWords.split(' ').first.length;
      print('searchWordsCaracterPlace: $searchWordsCaracterPlace');
      kiemelendoText = searchWords;
      int pageNumber = caracterToPagenumber(searchWordsCaracterPlace);
      _pageController.jumpToPage(pageNumber - 1);
      setState(() {});
    } else {
      ppp.popup('no resoult');
    }
  }

  /* setPage()async{
    print('stringList.length${stringList.length}');
print('setpage start');
if(!nowReadingBetoltve){

  book =await mfp.pmNowReadingGet();
  nowReadingBetoltve=true;
  print('setPage');
}

    bool lastWasEbook=book.lastWasEbook;
    int oldalszam=0;
    if(lastWasEbook){
      await keres();
    }else{


      int mp=book.bookMarkMp;
      print('bookMarkMp $mp');
      await mfp.doSomethingAndLoad(context, 1, bookCode);
      if(!nowReadingBetoltve){

        book =await mfp.pmNowReadingGet();
        nowReadingBetoltve=true;
        print('elsesetPage');
      }
      int audioPointToText=book.bookMarkCaracter;
      print('bookMarkCaracter ${book.bookMarkCaracter}');
      String kivagottDarab=book.ebookString.substring(audioPointToText,audioPointToText+200);
      print('kivagottDarab${kivagottDarab}');
      List<String> words=kivagottDarab.split(' ');
      words=words.sublist(1,6);
      print('affterremove$words');
      book.bookMarkText=words.join('');
      print('words.join('');${words.join(' ' )}');
     kiemelendoText=words.join(' ' );
      print(' kiemelendoText=words[0];);${ kiemelendoText}');
      //int audioPointToText=await mfp.audioPontToTextPont(book.bookCode, mp);
      print("audioPointToText=$audioPointToText");
      int caracterValue=0;
      print('stringList.length${stringList.length}');
      for(int i=0;i<stringList.length;i++){

        caracterValue+= stringList[i].length;
        if(audioPointToText<caracterValue){
          print(' if(baseStringTalalatHely<caracterValue)');
          oldalszam=i;
          _pageController.jumpToPage(oldalszam);
          print('setstate1');
        setState(() {});

          break;
        }
      }
    }


    print('setpage vege');
  }*/

  caracterToFiveWord(int caracterPoint) {
    String fiveWord = '';
    String kivagottDarab =
        book.ebookString.substring(caracterPoint, caracterPoint + 200);
    print(
        'kivagottDarab${kivagottDarab}caracter tofive ${book.ebookString.length}');
    List<String> words = kivagottDarab.split(' ');
    print('sdélfjéas words $words');
    words = words.sublist(1, 6);
    print('affterremove$words');
    book.bookMarkText = words.join('');
    print('words.join(' ');${words.join(' ')}');
    fiveWord = words.join(' ');
    return fiveWord;
  }

  pageToCaracterNumber(int page) {
    print('nowpage444${page}');
    print("string list length: ${stringList.length}");
    int caracterNumber = 0;

    for (int i = 0; page - 1 > i; i++) {
      caracterNumber = caracterNumber + stringList[i].length;
    }
    return caracterNumber;
  }

  setBookmark(String text) async {
    print("111 ${book.bookMarkCaracter}");
    if (firstLoadedPage != nowPage) {
//      book.bookMarkMp=-1;
    }
    print("222 ${book.bookMarkCaracter}");
    print('bookcodee4 ${bookCode}');
    // await mfp.setTextBookmark(bookCode, text);
    book.bookMarkText = text;

    print(
        'caracterNumber length ${pageToCaracterNumber(nowPage)}-----------------------------');
    // await mfp.setTextCaracterBookmark(bookCode, pageToCaracterNumber(nowPage));
    book.bookMarkCaracter = pageToCaracterNumber(nowPage);
    print("333 ${book.bookMarkCaracter}");
    print('bookcode setabookmark $bookCode');
    book.lastWasEbook = true;
    await mfp.pMSetBook(book);
  }

  textKiemelo(String text) {
    print('kiemelendoText$kiemelendoText');

    var returnText;
    String first = '';
    String second = '';
    String third = '';
    returnText = colorItemListToTextWidget(knowladgeListsToOneList(
        text, knownWords, unknownWords, kiemelendoText));

    /*  if(text.contains(kiemelendoText)){
      print('contaiiiiiins kiemelendo text: $kiemelendoText');
      int hely=text.toLowerCase().indexOf(kiemelendoText.toLowerCase());
      print('hellllllllllly${hely}');
      first =text.substring(0,hely);
      second=kiemelendoText;
      third=text.substring(hely+kiemelendoText.length);
      returnText=   SelectableText.rich(

         TextSpan(
          text: '',
          style: _textStyle,
          children:  <TextSpan>[
            TextSpan(text: first, style: _textStyle),
            TextSpan(text: second,style: TextStyle(color: Colors.blue, fontSize: fontSizea)),
            TextSpan(text: third, style: _textStyle,),

          ],
        ),
          cursorWidth: 0 ,

          selectionControls: selectionControl()
      );
      turnLastWasEbookTrue();
    }else{
      print('nemcontaiiins');
    // returnText=SelectableText(text, style: _textStyle,cursorWidth: 0 ,
   //    selectionControls: selectionControl(),);

    }*/

    print("page build end");
    return returnText;
  }

  pageBuild() async {
    if (!nowReadingBetoltve) {
      book = await mfp.pmNowReadingGet();
      nowReadingBetoltve = true;
      print('staaart');
    }

    bookCode = book.bookCode;

    final controlBloc = BlocProvider.of<PageControlBloc>(context);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      controlBloc.getSizeFromBloc(pageKey, sidePadding);
      controlBloc.getSplittedTextFromBloc(_textStyle, book.ebookString);
      buildingUtan(controlBloc);
    });
  }

  initAsync() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sidePadding =
        double.parse(await ppp.pMSharedStringGet("marginsize") ?? 0.toString());
    fontSizea =
        double.parse(await ppp.pMSharedStringGet("fontsize") ?? 18.toString());
    unknownWords = sharedPreferences.getStringList("unknownwordslist") ?? [];
    knownWords = sharedPreferences.getStringList("knownwordslist") ?? [];

    _textStyle = TextStyle(color: color, fontSize: fontSizea);

    fontSizeController.text = fontSizea.toString();
    marginSizeController.text = sidePadding.toString();

    if (!nowReadingBetoltve) {
      book = await mfp.pmNowReadingGet();
      nowReadingBetoltve = true;

      print('staaart');
    }

    bookCode = book.bookCode;
    syncPontokList = await ppp.pMSharedListSyncPontokGet(bookCode);
    print(
        "nowpageeeeeeeeeeee: $nowPage boookcaracter: ${book.bookMarkCaracter} ize ${book.bookCode}");
    translateTo = await ppp.pMSharedStringGet("language") ?? "en";
    syncPurchased = await ppp.pMSharedBoolGet('syncPurchased') ?? false;
    syncIsAvailbiable = await checkSyncAvailability("ondaysyncdate");
    pictureSearchIsAvailbiable =
        await checkSyncAvailability("onedaypitcsearch");
    await start();
  }

  start() async {
    final controlBloc = BlocProvider.of<PageControlBloc>(context);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      controlBloc.getSizeFromBloc(pageKey, sidePadding);
      controlBloc.getSplittedTextFromBloc(_textStyle, book.ebookString);
      buildingUtan(controlBloc);
    });

    print('startkeszxxxxxxxxxxxxxxxxxxxxxxxxx');
  }

  buildingUtan(var asdf) async {
    print('setstate3');
    setState(() {});
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setPage2(); //csak a building betoltes utan tortenik meg
    });
  }

  setPage2() async {
    print('setpage2 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    print('stringList.length${stringList.length}');
    print('setpage start');
    if (!nowReadingBetoltve) {
      book = await mfp.pmNowReadingGet();
      nowReadingBetoltve = true;
      print('setPage');
    }

    // if(false) {
    int avilbiableSyncPont = checkAvilbiableSyncPont();
    print("avilbiableSyncPont $avilbiableSyncPont");

    print('lastWasEbook false');

    firstLoadedPage = caracterToPagenumber(book.bookMarkCaracter);

    /*else{

        await mfp.doSomethingAndLoad(context, 1, bookCode);
        Book book2 =await mfp.pmNowReadingGet();
        book.bookMarkCaracter=book2.bookMarkCaracter;
        print('boookamarkcraracter setpage2 ${book2.bookMarkCaracter}');
        //   await keres();

        kiemelendoText=caracterToFiveWord(book.bookMarkCaracter);
        firstLoadedPage=caracterToPagenumber(book.bookMarkCaracter);
      }*/

    stringList = BlocProvider.of<PageControlBloc>(context).splittedTextList;
    print("caracter numbeeer ${book.bookMarkCaracter}");

    print("jup to page $firstLoadedPage");
    _pageController.jumpToPage(firstLoadedPage - 1);
  }

  setPageFromAudio() async {
    if (!nowReadingBetoltve) {
      book = await mfp.pmNowReadingGet();
      nowReadingBetoltve = true;
      print('setPage');
    }

    print('lastWasEbook false');

    await mfp.doSomethingAndLoad(context, 1, bookCode);
    Book book2 = await mfp.pmNowReadingGet();
    book.bookMarkCaracter = book2.bookMarkCaracter;
    print('boookamarkcraracter setpage2 ${book2.bookMarkCaracter}');

    kiemelendoText = caracterToFiveWord(book.bookMarkCaracter);
    firstLoadedPage = caracterToPagenumber(book.bookMarkCaracter);

    stringList = BlocProvider.of<PageControlBloc>(context).splittedTextList;
    print("caracter numbeeer ${book.bookMarkCaracter}");

    print("jup to page $firstLoadedPage");
    _pageController.jumpToPage(firstLoadedPage - 1);
    await sharedPreferences.setString(
        "ondaysyncdate", DateTime.now().toString());
    book.lastWasEbook=true;
    await mfp.pMSetBook(book);
    setState(() {

    });
  }

  Future<void> openFontMarginDialog() async {
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Font and Margin"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      children: [
                        Text("Font Size:"),
                        Expanded(
                          child: TextField(
                            controller: fontSizeController,
                            onChanged: (String onchangedValue) async {
                              await ppp.pMSharedStringSet(
                                  "fontsize", onchangedValue);
                              fontSizea = double.parse(onchangedValue);
                              _textStyle = TextStyle(
                                  fontSize: fontSizea, color: Colors.black);
                            },
                            onSubmitted: (String value) async {
                              //  await Future.delayed(Duration(milliseconds: 500));
                              //  await start();
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Margin Size:"),
                        Expanded(
                          child: TextField(
                            controller: marginSizeController,
                            onChanged: (String onchangedValue) async {
                              sidePadding = double.parse(onchangedValue);
                              await ppp.pMSharedStringSet(
                                  "marginsize", onchangedValue);
                            },
                            onSubmitted: (String value) async {
                              /*
                          int caracterLocationBeforFontMarginChange=await pageToCaracterNumber(nowPage);

                          await Future.delayed(Duration(milliseconds: 500));
                          await start();
                          int pageNumber=   await caracterToPagenumber(caracterLocationBeforFontMarginChange);
                          _pageController.jumpToPage(pageNumber-1);*/
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('close'),
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Future.delayed(Duration(milliseconds: 500));
                await textSizeMarginChange();
                Navigator.pop(context);
                // Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("apply"),
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Future.delayed(Duration(milliseconds: 500));
                await textSizeMarginChange();
                setState(() {});
                // await start();
              },
            )
          ],
        );
      },
    );
  }

  @override
  dispose() {
    Wakelock.disable();
    fontSizeController.dispose();
    marginSizeController.dispose();
    setBookmark(mentendoBookMarkString);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fontSizeController = TextEditingController();

    marginSizeController = TextEditingController();
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    initAsync();
  }

  @override
  Widget build(BuildContext context) {
    bool localIsPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    print('isportratit: $localIsPortrait');
    if (isPortrait != localIsPortrait) {
      isPortrait = (MediaQuery.of(context).orientation == Orientation.portrait);

      orientationChange();
    }

    print("basic build start");
    final controlBloc = BlocProvider.of<PageControlBloc>(context);

    return

       Scaffold(

        body: SafeArea(
          child: Column(
            children: [
              //    topMenu(),
              Expanded(
                child: Stack(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    color: textBackgroundColor,
                    key: pageKey,
                    child: PageView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (val) {
                          controlBloc.changeState(val);
                        },
                        itemCount: controlBloc.splittedTextList.length,
                        itemBuilder: (context, index) {
                          print('build elsobetoltes $elsobetoltes');
                          if (elsobetoltes) {
                            stringList = BlocProvider.of<PageControlBloc>(context)
                                .splittedTextList;
                            print(
                                '${stringList.length} striiiiiiiiiiiiiiinglist');
                            //   timer = Timer.periodic(Duration(seconds: 5), (Timer t) =>setPage2());
                            //  setPage2();
                            elsobetoltes = false;
                          } else {
                            mentendoBookMarkString =
                                controlBloc.splittedTextList[index];

                            nowPage = index + 1;
                            print("nowpageindex: $nowPage");
                            // nowPageInCaracter=pageToCaracterNumber(nowPage);

                            // print(controlBloc.splittedTextList[index]);
                          }
                          /*  if(reCalculatePage){
                            WidgetsBinding.instance?.addPostFrameCallback((_) {
                              nowPage=caracterToPagenumber(zsagabela);
                              print("jup to page $firstLoadedPage");
                              _pageController.jumpToPage(nowPage-1);
                              print("asdjfésldjf1 $nowPage");
                            });
                            reCalculatePage=false;
                          }*/

                          return textKiemelo(controlBloc.splittedTextList[index])

                              /*    Text(
                            controlBloc.splittedTextList[index],
                            style: _textStyle,
                          )*/
                              ;
                        }),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("asdtap");
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  print("baltap");
                                  _pageController.previousPage(
                                      duration: kDuration, curve: kCurve);
                                },
                              )),
                          Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () {
                                  if (bottomMenuApears) {
                                    bottomMenuApears = false;
                                  } else {
                                    bottomMenuApears = true;
                                  }
                                  setState(() {});
                                },
                              )),
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  print("jobb");
                                  _pageController.nextPage(
                                      duration: kDuration, curve: kCurve);
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [topMenu(), Spacer(), _pageControll()],
                  )
                ]),
              ),

              //     _pageControll()
            ],
          ),
        ),
      );

    buildFinished = true;
  }

  Widget topMenu() {
    return Visibility(
        visible: bottomMenuApears && book.lastWasEbook == false,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: syncIsAvailbiable
                        ? Text("Go where I left off in the audiobook")
                        : Text("Daily one sync, is used up"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: syncIsAvailbiable
                        ? ElevatedButton(
                            onPressed: () async {
                              if (syncPurchased) {
                                //purchased
                                await setPageFromAudio();
                              } else {
                                //when not purchased but have daily one sync
                                await ppp.showDialoWithButtons(
                                    "Warning",
                                    "You have only one ebook and audio bookmark synchronisation /day.",
                                    context,
                                    "cancel",
                                    "Go",
                                    setPageFromAudio);
                              }
                            },
                            child: Text("Go"))
                        : ElevatedButton(
                            onPressed: () {
                              upgrade();
                            },
                            child: Text("Upgrade")),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 1,
                  )
                ],
              ),
            ],
          ),
        ));
  }

  asdasd12() {
    print("object12");
  }

  asdasd2() {
    print("object2");
  }

  Widget _pageControll() {
    return Visibility(
      visible: bottomMenuApears,
      child: Container(
        color: Colors.white,
        child: BlocBuilder<PageControlBloc, int>(
          builder: (context, state) {
            print("_pageControll start");
            final int _length = BlocProvider.of<PageControlBloc>(context)
                .splittedTextList
                .length;

            return Container(
              child: Column(
                children: [
                  Visibility(
                      visible: searchApears,
                      child: Container(
                        //  decoration: mBoxDecorationWhiteButtomMenu,
                        padding: EdgeInsets.all(5),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                        "Search for page number or text!",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      if (searchApears) {
                                        searchApears = false;
                                      } else {
                                        searchApears = true;
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.clear_outlined))
                              ],
                            ),
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "search",
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                String kiirando = "alap";

                                if (double.tryParse(value) != null) {
                                  //igaz ha csak szám
                                  int intValue = int.parse(value);
                                  if (intValue < _length && intValue > 0) {
                                    _pageController.jumpToPage(intValue - 1);
                                  }
                                  kiirando = "csakszam";
                                } else {
                                  textViewSearch(value);
                                  kiirando = "nemszam";
                                }

                                print(kiirando);
                              },
                            ),
                          ],
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PopupMenuButton(
                        icon: Icon(Icons.menu_rounded),
                        onSelected: (value) {
                          switch (value.toString()) {
                            case ("search"):
                              {
                                if (searchApears) {
                                  searchApears = false;
                                } else {
                                  searchApears = true;
                                }
                                setState(() {});
                              }
                              break;

                            case ("ebooksettings"):
                              {
                                Navigator.pushNamed(context, '/ebooksettings')
                                    .then((_) async {
                                  unknownWords = sharedPreferences
                                          .getStringList("unknownwordslist") ??
                                      [];
                                  knownWords = sharedPreferences
                                          .getStringList("knownwordslist") ??
                                      [];
                                  translateTo =
                                      await ppp.pMSharedStringGet("language") ??
                                          "en";
                                  print("set language to: $translateTo");
                                  setState(() {});
                                  // This block runs when you have returned back to the 1st Page from 2nd.
                                });
                              }
                              break;
                            case ("fontmargin"):
                              {
                                bottomMenuApears = false;
                                setState(() {});

                                openFontMarginDialog();
                              }
                              break;
                            case ("proba"):
                              {
                                proba();
                              }
                              break;

                            case ("wordlearning"):
                              {
                                Navigator.pushNamed(context, '/wordlearning')
                                    .then((_) async {
                                  unknownWords = sharedPreferences
                                          .getStringList("unknownwordslist") ??
                                      [];
                                  knownWords = sharedPreferences
                                          .getStringList("knownwordslist") ??
                                      [];
                                  setState(() {});
                                  // This block runs when you have returned back to the 1st Page from 2nd.
                                });
                              }
                              break;
                            case ("knownwordlist"):
                              {
                                Navigator.pushNamed(context, '/knownwordlist')
                                    .then((_) async {
                                  unknownWords = sharedPreferences
                                          .getStringList("unknownwordslist") ??
                                      [];
                                  knownWords = sharedPreferences
                                          .getStringList("knownwordslist") ??
                                      [];
                                  setState(() {});
                                  // This
                                  // This block runs when you have returned back to the 1st Page from 2nd.
                                });
                              }
                              break;
                            case ("unknownwordlist"):
                              {
                                Navigator.pushNamed(context, '/unknownwordlist')
                                    .then((_) async {
                                  unknownWords = sharedPreferences
                                          .getStringList("unknownwordslist") ??
                                      [];
                                  knownWords = sharedPreferences
                                          .getStringList("knownwordslist") ??
                                      [];
                                  setState(() {});
                                  // This
                                  // This block runs when you have returned back to the 1st Page from 2nd.
                                });
                              }
                              break;
                          }

                          // your logic
                        },
                        itemBuilder: (BuildContext bc) {
                          return const [
                            PopupMenuItem(
                              child: Text("Search"),
                              value: 'search',
                            ),
                            PopupMenuItem(
                              child: Text("Settings"),
                              value: 'ebooksettings',
                            ),
                            PopupMenuItem(
                              child: Text("Font and margin"),
                              value: 'fontmargin',
                            ),

                            /*   PopupMenuItem(
                    child: Text("proba"),
                    value: 'proba',
                  ),*/

                            PopupMenuItem(
                              child: Text("Most used words"),
                              value: 'wordlearning',
                            ),
                            PopupMenuItem(
                              child: Text("known word list"),
                              value: 'knownwordlist',
                            ),
                            PopupMenuItem(
                              child: Text("unknown word list"),
                              value: 'unknownwordlist',
                            ),
                          ];
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.first_page),
                          onPressed: () {
                            _pageController.jumpToPage(state - 10);
                            //  _pageController.jumpToPage(0);
                          }),
                      IconButton(
                        icon: Icon(Icons.navigate_before),
                        onPressed: () {
                          _pageController.previousPage(
                              duration: kDuration, curve: kCurve);
                        },
                      ),
                      Text(
                        '${state + 1}/$_length',
                      ),
                      IconButton(
                        icon: Icon(Icons.navigate_next),
                        onPressed: () {
                          _pageController.nextPage(
                              duration: kDuration, curve: kCurve);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.last_page),
                        onPressed: () {
                          _pageController.jumpToPage(state + 10);

                          // _pageController.jumpToPage(_length);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined),
                        onPressed: () async {
                          if (syncPurchased) {
                            await cameraIconButtonOnPress();
                          } else {
                            if (pictureSearchIsAvailbiable) {
                              await ppp.showDialoWithButtons(
                                  "Picture Search",
                                  "You can search only ones a day with free plan.",
                                  context,
                                  "cancel",
                                  "search",
                                  cameraIconButtonOnPress);
                            } else {
                              await ppp.showDialoWithButtons(
                                  "Picture Search",
                                  "Your daily one camera search is used up.",
                                  context,
                                  "cancel",
                                  "Upgrade",
                                  upgrade);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ColorItem {
  String text = "";
  String knowladge = "";

  ColorItem(btext, bknowladge) {
    text = btext;
    knowladge = bknowladge;
  }
}
