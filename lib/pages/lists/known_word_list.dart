import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnownWords extends StatefulWidget {
  const KnownWords({Key? key}) : super(key: key);

  @override
  State<KnownWords> createState() => _KnownWordsState();
}

class _KnownWordsState extends State<KnownWords> {
  late SharedPreferences sharedPreferences;

  List<String> knownWords=[];
  List<String> unknownWords=[];






  toKnownWordsList(String text)async{
    //List<String> lknownWords=await ppp.pMSharedListGet("knownwordslist");

    text=text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'');
    List<String> textList=text.split(" ");
    for(int i=0;i<textList.length;i++){

      if(!knownWords.contains(textList[i])){ //if not contains
        knownWords.add(textList[i]);



      }
      if(unknownWords.contains(textList[i])){
        unknownWords.remove(textList[i]);

      }

      print("toknown: ");
    }
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);
  }
  toUnknownWordsList(String text)async{

    text=text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'');
    List<String> textList=text.split(" ");
    for(int i=0;i<textList.length;i++){

      if(!unknownWords.contains(textList[i])){ //if not contains
        unknownWords.add(textList[i]);

      }
      if(knownWords.contains(textList[i])){
        knownWords.remove(textList[i]);

      }

      print("toknown: ");
    }
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);







  }
  initAsync()async{
    sharedPreferences=await SharedPreferences.getInstance();


    unknownWords= sharedPreferences.getStringList("unknownwordslist")??[];
    knownWords= sharedPreferences.getStringList("knownwordslist")??[];
    unknownWords= unknownWords.reversed.toList();
    knownWords= knownWords.reversed.toList();
    setState(() {

    });




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
      
      body:  SafeArea(
        child: Column(
          
          children: [
            Row(
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
                Text("Familiar word list",style: TextStyle(color: Colors.black,fontSize: 30),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Mark Unfamiliar",style: TextStyle(color: Colors.black,fontSize: 20),),
                )
              ],
            ),
            Expanded(
              child: knownWords.length==0 ? Center(child: Text("EMPTY",style: TextStyle(fontSize: 40)),) : ListView.builder(
                itemCount: knownWords.length,

                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Card(
                    child: SizedBox(
                      height: 50,
                      child: Row(

                        children: [
                          Expanded(child: Text(knownWords[index],style: TextStyle(fontSize: 30),)),

                          OutlinedButton(onPressed: () async {
                            await toUnknownWordsList(knownWords[index]);
                            print("add unknownlist ${knownWords[index]}");
                            setState(() {});
                          },
                              child: Text("-",style: TextStyle(color: Colors.black,fontSize: 30))),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
