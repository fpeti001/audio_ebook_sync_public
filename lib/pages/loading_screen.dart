import 'dart:async';

import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key, required this.toDo,required this.bookCode}) : super(key: key);
  final  int toDo;
  final String bookCode;

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  PPP ppp=new PPP();
  Mfp mfp=new Mfp();
int toDo2=0;
String bookCode2="";
int percentage=0;
String percentageString='Loading';
  Timer? timer;

eBookBookmarkToAbookMp()async{
await  ppp.setPercent(0);
  timer = Timer.periodic(Duration(seconds: 2), (Timer t) => setLoadPercentage());
  Book book =await mfp.pmNowReadingGet();
print ('eBookBookmarkToAbookMp {book.bookMarkCaracter ${book.bookMarkCaracter}');
//szentem itt meg mukodott
  book.bookMarkMp=await mfp.searchInAudioBook(book.bookCode, book.bookMarkCaracter,context);

  await mfp.pMSetBook(book);



  Navigator.pop(context);
}
  aBookBookmarkToEbookPage()async {
   // timer = Timer.periodic(Duration(seconds: 2), (Timer t) => setLoadPercentage());
    Book book =await mfp.pmNowReadingGet();
    int audioPointToText;
    if(book.bookMarkMp>60){
       audioPointToText =await mfp.audioPontToTextPont(book.bookCode, book.bookMarkMp, context);
       if(audioPointToText==0)ppp.showMyDialog("error", "SSync failed, the two book is maybe different, or audiobook quality is bad, or it is in wrong language. ", context);

    }else{ audioPointToText=1;}

 book.bookMarkCaracter=audioPointToText;
await mfp.pMSetBook(book);
   Navigator.pop(context);

  }

  setBookString(String bookCode,int number)async{

    Book book= await mfp.pMGetBook(bookCode);
    String bookName=book.ebookPath;
    print('booknameee $bookName');
    String ebookFormat=bookName.substring(bookName.lastIndexOf('.'));
    print("abookFormat $ebookFormat contains ${ebookFormat.contains('pdf')}");
    if(ebookFormat.contains('pdf')||ebookFormat.contains('PDF')) await mfp.pMPDFtoString( bookCode,context);
    if(ebookFormat.contains('epub')) await mfp.pMEpubtoString( bookCode,context);

      if(ebookFormat.contains('epub')||ebookFormat.contains('pdf')||ebookFormat.contains('PDF')) {

      }else{
        ppp.showMyDialog("Error", "$ebookFormat is wrong file format :/ \n For Ebook acceptable file format is: PDF and EPUB", context);
      }
        // await Future.delayed(Duration(seconds: 5));
        Navigator.pop(context);




  }
doSomething(String bookCode,int number)async{


  switch(number){

    case 0:
      percentageString='Loading..\nit can take about 10 sec';
      Future.delayed(const Duration(milliseconds: 200), () async {
        await setBookString(bookCode,number);
      });

      break;

    case 1:
      aBookBookmarkToEbookPage();
      break;
    case 2:

      eBookBookmarkToAbookMp();

      break;


  }
}
setLoadPercentage()async{
  percentage=await ppp.getPercent();
  percentageString='Loading $percentage %';
  setState(() {

  });
}
start()async{

}
@override
  void dispose() {
  timer?.cancel();
 // Navigator.pop(context);
    super.dispose();
  }
  @override
  void initState() {

    super.initState();

   initAsync();


  }
  initAsync()async{
    start();
    toDo2=widget.toDo;
    bookCode2=widget.bookCode;

   await doSomething(bookCode2, toDo2);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.grey,
        body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: SpinKitFadingCube(
                  color: Colors.white,
                  size: 50.0,
                )
            ),
            SizedBox(height: 30,),
            Text(percentageString,style:TextStyle(color: Colors.white)),
          ],
        )
    );
  }


}
