import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ppp.dart';

class EbookSettings extends StatefulWidget {
  const EbookSettings({Key? key}) : super(key: key);

  @override
  State<EbookSettings> createState() => _EbookSettingsState();
}

class _EbookSettingsState extends State<EbookSettings> {

  PPP ppp=PPP();
  String translateTo="chooseelso";
  List<String> knownWords=[];
  List<String> unknownWords=[];
  late SharedPreferences sharedPreferences;



  clearUnAndKnownLists()async {
    knownWords = [];
    unknownWords = [];

    await sharedPreferences.setStringList("unknownwordslist", []);
    await sharedPreferences.setStringList("knownwordslist", []);
    setState(() {

    });
  }
  @override
  void initState() {
    initAsync();
    // TODO: implement initState

    super.initState();
  }
  initAsync()async{
    sharedPreferences=await SharedPreferences.getInstance();

    translateTo=await ppp.pMSharedStringGet("languagelong")??"chooseas";
    unknownWords= sharedPreferences.getStringList("unknownwordslist")??[];
    knownWords= sharedPreferences.getStringList("knownwordslist")??[];
    print("egy");
    setState(() {
      
    });
  }
  @override
  Widget build(BuildContext context) {
    print("ketto");
    return Scaffold(
      appBar: AppBar(title: Text("Ebook Settings")),
      body: Column(children: [
        Text("Translater:"),
        Row(children: [
          Text("Translate to"),
          ElevatedButton(onPressed: (){
            Navigator.pushNamed(context, '/chooselanguage').then((_) async {

              translateTo=await ppp.pMSharedStringGet("languagelong");
              print("set language to: $translateTo");
              setState(() {

              });
              // This block runs when you have returned back to the 1st Page from 2nd.

            });

          }, child: Text(translateTo))
        ],),
        Row(children: [
          ElevatedButton(onPressed: (              )async{
            return showDialog<void>(
              context: context,
              // barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title:  Text("Are you sure?"),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children:  <Widget>[
                       // SelectableText(),

                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () async {
                        await clearUnAndKnownLists();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('No'),
                      onPressed: () async {

                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }, child: Text("Clear known and unknown list"))
        ],)

      ],),
    );
  }
}
