import 'package:async/async.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class UnknownWords extends StatefulWidget {
  const UnknownWords({Key? key}) : super(key: key);

  @override
  State<UnknownWords> createState() => _UnknownWordsState();
}

class _UnknownWordsState extends State<UnknownWords> {
  late SharedPreferences sharedPreferences;

  List<String> knownWords = [];
  List<String> unknownWords = [];
  final translator = GoogleTranslator();
  String translateTo = "en";
  PPP ppp = PPP();
  List<String> translationList = [];

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
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);
  }

  translate(int number) async {
    var translation =
        await translator.translate(unknownWords[number], to: translateTo);

    translationList[number] = translation.toString();
    print("$number translation= ${translation.toString()}");
  }

  translateWords() async {
    final futureGroup = FutureGroup();
    int asdf = unknownWords.length;
    for (int i = 0; i < unknownWords.length; i++) {
      futureGroup.add(translate(i));
    }
    futureGroup.close();
    await futureGroup.future;

    /*
    var translation;
    try{

      translation =  await translator.translate(list[i], to: translateTo);
      print("translation= $translation");
    }catch (e){
      translation=e;
    }
*/
  }

  initAsync() async {
    sharedPreferences = await SharedPreferences.getInstance();
    translateTo = await ppp.pMSharedStringGet("language") ?? "en";

    unknownWords =
        await sharedPreferences.getStringList("unknownwordslist") ?? [];
    knownWords = sharedPreferences.getStringList("knownwordslist") ?? [];
    unknownWords = unknownWords.reversed.toList();
    knownWords = knownWords.reversed.toList();
    for (int i = 0; i < unknownWords.length; i++) {
      translationList.add("x");
    }
    setState(() {});
    await translateWords();
    setState(() {});
    print("list:");
    print(translationList);
    print("finish");
  }

  @override
  void initState() {
    initAsync();

    //  findOutputPath();
    // initstate2();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: SafeArea(
        child: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.all(5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_ios),
                      color: Colors.black,
                    ))),
            Text("Unfamiliar word list",style: TextStyle(color: Colors.black,fontSize: 30),),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Mark familiar",
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
              ],
            ),
            Expanded(
              child: unknownWords.length==0 ? Center(child: Text("EMPTY",style: TextStyle(fontSize: 40)),) :ListView.builder(
                shrinkWrap: true,
                itemCount: unknownWords.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Row(
                      children: [
                        Text(
                          "${unknownWords[index]} - ",
                          style: TextStyle(fontSize: 30),
                        ),
                        Expanded(
                            child: Text(
                          translationList[index],
                          style: TextStyle(fontSize: 30),
                        )),
                        OutlinedButton(
                            onPressed: () async {
                              await toKnownWordsList(unknownWords[index]);
                              //print("add knownlist ${unknownWords[index]}");
                              setState(() {});
                            },
                            child: Text("+",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 30))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PopupMenuButton(
                  //  icon: Icon(Icons.menu_rounded),
                    child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                        //  color: Colors.grey
                    ),child: Text("copy",style: TextStyle(fontSize: 30))),

                    itemBuilder: (BuildContext bc) {
                      return const [
                        PopupMenuItem(
                          child: Text("copy words"),
                          value: 'coppywords',
                        ),
                        PopupMenuItem(
                          child: Text("copy words with translation"),
                          value: 'copywithtranslation',
                        ),
                      ];
                    },
                    onSelected: (value) {
                      switch (value.toString()) {
                        case ("coppywords"):{
                          String text = unknownWords.join("\n");

                            Clipboard.setData(ClipboardData(text: text));
                            ppp.popup("Copied");
                          }
                          break;
                        case ("copywithtranslation"):{
                          String text = "";

                          for (int i = 0; i < unknownWords.length; i++) {
                            text += "\n${unknownWords[i]} - ${translationList[i]}";
                          }

                          Clipboard.setData(ClipboardData(text: text));
                          ppp.popup("Copied");
                          }
                          break;
                      }
                    },

                  ),
                ),
                /*   OutlinedButton(
                    onPressed: () {
                      String text = unknownWords.join("\n");

                      Clipboard.setData(ClipboardData(text: text));
                      ppp.popup("Copied");
                    },
                    child: Text("copy list", style: TextStyle(fontSize: 20))),
              OutlinedButton(
                    onPressed: () {
                      String text = "";

                      for (int i = 0; i < unknownWords.length; i++) {
                        text += "\n${unknownWords[i]} - ${translationList[i]}";
                      }

                      Clipboard.setData(ClipboardData(text: text));
                      ppp.popup("Copied");
                    },
                    child: Text(
                      "copy with translation",
                      style: TextStyle(fontSize: 20),
                    )),*/
              ],
            )
          ],
        ),
      ),
    );
  }
}
