import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../aebook_styles.dart';
import '../../services/mFP.dart';

class WordLearning extends StatefulWidget {
  const WordLearning({Key? key}) : super(key: key);

  @override
  State<WordLearning> createState() => _WordLearningState();
}

class _WordLearningState extends State<WordLearning> {
  late SharedPreferences sharedPreferences;
  Mfp mfp=Mfp();
  Book book=Book();
 List<String> mostUsedWords=[];
List<int>  wordRepetition=[];
  List<String> knownWords=[];
  List<String> unknownWords=[];









  initAsync()async{
    sharedPreferences=await SharedPreferences.getInstance();
    book= await mfp.pmNowReadingGet();

    unknownWords= sharedPreferences.getStringList("unknownwordslist")??[];
    knownWords= sharedPreferences.getStringList("knownwordslist")??[];



    await   getMostUsedWordList();
  }
  @override
  void initState() {

    initAsync();

    //  findOutputPath();
    // initstate2();


    super.initState();
  }
  toKnownWordsList(String text, int index)async{
    //List<String> lknownWords=await ppp.pMSharedListGet("knownwordslist");

    text=text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'');
    List<String> textList=text.split(" ");
    for(int i=0;i<textList.length;i++){

      if(!knownWords.contains(textList[i])){ //if not contains
        knownWords.add(textList[i]);
        mostUsedWords.removeAt(index);
        wordRepetition.removeAt(index);


      }
      if(unknownWords.contains(textList[i])){
        unknownWords.remove(textList[i]);
        mostUsedWords.removeAt(index);
        wordRepetition.removeAt(index);
      }

      print("toknown: ");
    }
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);
  }
  toUnknownWordsList(String text, int index)async{

    text=text.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'');
    List<String> textList=text.split(" ");
    for(int i=0;i<textList.length;i++){

      if(!unknownWords.contains(textList[i])){ //if not contains
        unknownWords.add(textList[i]);
        mostUsedWords.removeAt(index);
        wordRepetition.removeAt(index);
      }
      if(knownWords.contains(textList[i])){
        knownWords.remove(textList[i]);
        mostUsedWords.removeAt(index);
        wordRepetition.removeAt(index);
      }

      print("toknown: ");
    }
    await sharedPreferences.setStringList("unknownwordslist", unknownWords);
    await sharedPreferences.setStringList("knownwordslist", knownWords);







  }


getMostUsedWordList()async{

   print("words.length ");
List <String> words=["asd"];
String ebookString= book.ebookString.toLowerCase().replaceAll(new RegExp(r'[^\w\s]+'),'');
   words = ebookString.split(" ");
    print("words.length ${words.length}");
    Map<String,int> count = <String,int>{};
    for (final w in words) {
      count[w] = 1 + (count[w] ?? 0);
      //print(" count w ${count[w]}");
    }

     mostUsedWords = count.keys.toList();
     wordRepetition = count.values.toList();
mostUsedWords.sort((a, b) => count[b]!.compareTo(count[a]!));
    wordRepetition.sort((b, a) => a.compareTo(b));
    print("orderedlength ${mostUsedWords.length}");
    print("orderednumberlength ${wordRepetition.length}");

        for(int i=0;i<10;i++) {
          print("$i. : ${mostUsedWords[i]}  ${wordRepetition[i]} ");
        }

      for(int i=0;i<knownWords.length;i++){
        int index = mostUsedWords.indexWhere((element) =>
        element == knownWords[i]);
        if (index >= 0) {
          mostUsedWords.removeAt(index);
          wordRepetition.removeAt(index);

        }



          // if(mostUsedWords.contains(knownWords[i]))print("contains: ${knownWords[i]}");
      //  mostUsedWords.remove(knownWords[i]);
      }
   for(int i=0;i<unknownWords.length;i++){
     int index = mostUsedWords.indexWhere((element) =>
     element == unknownWords[i]);
     if (index >= 0) {
       mostUsedWords.removeAt(index);
       wordRepetition.removeAt(index);

     }



     // if(mostUsedWords.contains(knownWords[i]))print("contains: ${knownWords[i]}");
     //  mostUsedWords.remove(knownWords[i]);
   }





        setState(() {

        });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:  SafeArea(
        child: Container(
          color: Colors.grey[80],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Text("unfamiliar |",style: TextStyle(color: Colors.black,fontSize: 30),),
                  Text("familiar ",style: TextStyle(color: Colors.black,fontSize: 30)),



                ],
              ),
              Expanded(
                child: mostUsedWords.length==0 ? Center(child: Text("EMPTY",style: TextStyle(fontSize: 40)),) : ListView.builder(
                  itemCount: mostUsedWords.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return  Container(
                      padding: EdgeInsets.all(3),
                        decoration: mBoxDecorationWhite,
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                        child: SizedBox(
                          height: 50,
                          child: Row(

                            children: [
                              Text( "${wordRepetition[index].toString()}   " ,style: TextStyle(fontSize: 30),),
                             Expanded(child: Text(mostUsedWords[index],style: TextStyle(fontSize: 30),)),

                              Padding(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: OutlinedButton(onPressed: () async {
                                  await toUnknownWordsList(mostUsedWords[index],index);
                                  print("add unknownlist ${mostUsedWords[index]}");
                                  setState(() {});
                                  },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("-",style: TextStyle(color: Colors.black,fontSize: 30)),
                                    )),
                              ),
                              OutlinedButton(onPressed: () async {
                                await toKnownWordsList(mostUsedWords[index],index);
                                print("add knownlist ${mostUsedWords[index]}");
                                setState(() {});
                              }, child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("+",style: TextStyle(color: Colors.black,fontSize: 30)),
                              )),
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
      ),
    );
  }
}
