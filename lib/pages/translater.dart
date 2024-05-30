import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:audio_ebook_sync/variables.dart';
import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class ChoseLanguage extends StatefulWidget {
  const ChoseLanguage({Key? key}) : super(key: key);

  @override
  State<ChoseLanguage> createState() => _ChoseLanguageState();
}

class _ChoseLanguageState extends State<ChoseLanguage> {
  final translator = GoogleTranslator();
  PPP ppp=PPP();
  @override
  void initState() {



    //  findOutputPath();
    // initstate2();


    super.initState();
  }
  initStateAsync(){

  }

 // var translation = await translator.translate("Dart is very cool!", to: 'pl');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('translate')),
      body: SizedBox(
        width: double.infinity,
        child: Column(children: [Expanded(
          child: SearchableList<String>(
            initialList: languages,
            builder: (String user) => Container(child: Text(user),padding: EdgeInsets.all(20), decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),)),
            filter: (value) => languages.where((element) => element.toLowerCase().contains(value),).toList(),
            emptyWidget:  Text("no item found"),
            onItemSelected: (String item) async {print(item);
              print("lagnuagelength: ${languages.length} languashorts: ${languageShorts.length}");
              int position=3;

              for(int i=0;i<languages.length;i++){
                if(languages[i].contains(item)){
                  position=i;
                  print("contains");
                  break;
                }
              }


              await ppp.pMSharedStringSet("language", languageShorts[position]);
            await ppp.pMSharedStringSet("languagelong", languages[position]);
            print("languageshort: ${languageShorts[position]}");
              Navigator.pop(context);



              },
            inputDecoration: InputDecoration(
              labelText: "Search Actor",

              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.blue,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),],),
      ),
    );
  }
}
