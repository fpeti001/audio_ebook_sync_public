import 'dart:async';
import 'dart:io';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audio_ebook_sync/bg_player/common.dart';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:audio_ebook_sync/services/ppp.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';



import 'package:file_picker/file_picker.dart';

class BgPlayer extends StatefulWidget {
  const BgPlayer({Key? key}) : super(key: key);
  @override
  _BgPlayerState createState() => _BgPlayerState();
}

class _BgPlayerState extends State<BgPlayer> with WidgetsBindingObserver{
  List<String> mp3PathList=[];
  List<int> durationList=[];
  int? songIndex=0;
 bool firstSpeedChange=true;
  int _nextMediaId = 0;
  String? soundDirectory;
  List<AudioSource> audioList= [];
  late AudioPlayer _player;
  Mfp mfp = Mfp();
  PPP ppp=new PPP();
  Book book=Book();
  String aBookName='load aBookName';
  int mPBookmark=0;
  int startMpBookmark=0;
  List<double>? _accelerometerValues;
final _streamSubscriptions = <StreamSubscription<dynamic>>[];
Color buttonBackground=Colors.grey;
String buttonText="Sleep function\n";
  static  late Timer _timer;
  int timerStartingSec=10*60;
  int _start = 10*60;
  bool isTimerRuning=false;
  bool sleepFunctionTurndOn=false;
  late StateSetter _setState;
  late BuildContext popupContext;
  double recuiredShakeForce=0.05;
Duration firstPosition=Duration();
bool timerInitialited=false;
bool accelerometerOn=true;
bool quietingTimeron=false;
  List<SyncPontok> syncPontokList=[];
  bool syncPurchased=false;
  bool syncIsAvailbiable=false;
  late SharedPreferences sharedPreferences;
  int avilbiableSyncPont=0;
  bool pictureSearchIsAvailbiable=false;

  upgrade()async{



    Navigator.pushNamed(context, '/purchase',
        arguments: "sajtargument").then((_) async {
      syncIsAvailbiable= await checkSyncAvailability("ondaysyncdate");
      pictureSearchIsAvailbiable=await checkSyncAvailability("onedaypitcsearch");
      setState(()  {

      });
      // This block runs when you have returned back to the 1st Page from 2nd.

    });
  }
  checkSyncAvailability(String sharedKey)async{
    bool available=false;
    if(syncPurchased){
      available = true;
    }else {
//ondaysyncdate
      String string = sharedPreferences.getString(sharedKey) ?? "";

      if (string == "") {

        available = true;
        //   await sharedPreferences.setString ("rateusdate", DateTime.now().add(Duration(days: 6)).toString());
      } else {
        DateTime datetime = DateTime.parse(string);
        DateTime datetimeNow = DateTime.now();

        int dayDifference = (datetime.day.compareTo(datetimeNow.day)).abs();

        if (dayDifference > 0) {
          //   await sharedPreferences.setString ("rateusdate", DateTime.now().toString());
          available = true;
          print("ondaysyncdate ddaydiference= $dayDifference");
        }
      }
    }
    return available;
  }
  checkAvilbiableSyncPont() {
    int rVariable=0;
    for(int i=0;i<syncPontokList.length;i++){
      if(book.bookMarkCaracter-2000<syncPontokList[i].textKarakterSzam&&syncPontokList[i].textKarakterSzam<book.bookMarkCaracter+2000){
        rVariable=syncPontokList[i].audioMp;
        break;
      }


    }
    return rVariable;


  }
probaButton()async{
  int? localIndex= songIndex;
  int localMp=mPBookmark!;
  List<AudioSource> LocalaudioList= [];

  Directory appDocumentDir = await getApplicationDocumentsDirectory();

  String rawDocumentPath = appDocumentDir.path;

  LocalaudioList.add( AudioSource.uri(


    Uri.parse("$rawDocumentPath/outputName2.mp3"),
    tag: MediaItem(
      id: '${_nextMediaId++}',
      album: "",
      title:"",
      artUri: Uri.file(
          book.bookCoverPath
      ),
    ),
  ));
  await  _player.setAudioSource(
    ConcatenatingAudioSource(children: LocalaudioList,),

  );
 /* await Future.delayed( Duration(seconds:9));

  /* await _player.setAsset(           // Load a URL
      'assets/param.wav');*/

  await  _player.setAudioSource(
      ConcatenatingAudioSource(children: audioList));
  // setMp();

  await _player.seek(Duration(seconds: localMp), index: localIndex);*/
}

playParam()async{
  print("playparam");
int? localIndex= songIndex;
int localMp=mPBookmark!;
List<AudioSource> LocalaudioList= [];
LocalaudioList.add( AudioSource.uri(
    Uri.parse("asset:///assets/param.wav"),
  tag: MediaItem(
    id: '${_nextMediaId++}',
    album: "",
    title:"",
    artUri: Uri.file(
        book.bookCoverPath
    ),
  ),
));
await  _player.setAudioSource(
    ConcatenatingAudioSource(children: LocalaudioList,),

);
await Future.delayed( Duration(seconds:1));

 /* await _player.setAsset(           // Load a URL
      'assets/param.wav');*/

  await  _player.setAudioSource(
      ConcatenatingAudioSource(children: audioList));
 // setMp();

  await _player.seek(Duration(seconds: localMp), index: localIndex);

}

stopForSec(int sec)async{

  await _player.pause();
  await Future.delayed( Duration(seconds:sec));
  await _player.play();
}
stopSensor(){
  for (final subscription in _streamSubscriptions) {
    subscription.cancel();
  }}
startSensor()async{
  _streamSubscriptions.add(
    userAccelerometerEvents.listen(
          (UserAccelerometerEvent  event) async {

        _accelerometerValues = <double>[event.x.abs(), event.y.abs(), event.z.abs()];
        if (event.x>recuiredShakeForce||event.y>recuiredShakeForce||event.z>recuiredShakeForce){
          if(isTimerRuning&& accelerometerOn&&_player.playing){
//asd
              _player.setVolume(1.0);
              _timer.cancel();

              if (sleepFunctionTurndOn) startSleepTimer();

              accelerometerOn=false;
            if(quietingTimeron) await playParam();
              quietingTimeron=false;
              await Future.delayed(Duration(seconds: 5));
              accelerometerOn=true;

          }
        }
      },
    ),
  );
}
  photoButton()async{
    String photoText= await mfp.photoToText();
    int findingPlace=await mfp.pMSearchForPhoto(book.bookCode, book.ebookString, photoText);
    book.bookMarkCaracter=findingPlace;
    await mfp.pMSetBook(book);


    await mfp.doSomethingAndLoad(context, 2, book.bookCode);
    Book book2=await mfp.pmNowReadingGet();
    book.bookMarkMp=book2.bookMarkMp;
    startMpBookmark=book.bookMarkMp;
    print('set Mp startMpBookmark $startMpBookmark-----------------------------');
    List<int> indexMpList=mpToIndexAndMp(startMpBookmark);
    //  await _player.seek(Duration(seconds: startMpBookmark));
    print('sadsaf indesx: ${indexMpList[0]} és mp: ${indexMpList[1]}');
    await _player.seek(Duration(seconds: indexMpList[1]), index: indexMpList[0]);
    if(indexMpList[0]!=0&&indexMpList[1]!=0){
      await sharedPreferences.setString ("onedaypitcsearch", DateTime.now().toString());
      pictureSearchIsAvailbiable=false;
    }


  }
firstStartCeckAndSet()async{
  if(await ppp.pMSharedBoolGet('firsttime')==null){
    print('fiiiiiiirsttimeee true');
await ppp.pMSharedBoolSet('sleepfunction', false);
    await ppp.sharedIntSet('timerduration', 10*60);
    await ppp.sharedDoubleSet('force', 0.05);

    await ppp.pMSharedBoolSet('firsttime', false);

  }
}
saveAndSetRecuiredShakeForce( double force)async{
  recuiredShakeForce=force;
  await ppp.sharedDoubleSet('force', force);
}
saveSleepFunction(bool Position)async{
 await ppp.pMSharedBoolSet('sleepfunction', Position);
}
  setAndSaveSleepTimerDuration(int sec)async{

    timerStartingSec=sec;
    _start = sec;
    await ppp.sharedIntSet("timerduration", sec);

  }
  void startSleepTimer() {
    if(isTimerRuning==false)startSensor();
    timerInitialited=true;
    isTimerRuning=true;
    _start=timerStartingSec;
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {

        if (_start == 0) {
          setState(() {
            timer.cancel();
            startQuietingTimer();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );

  }
  startQuietingTimer()async{
  quietingTimeron=true;
    int quietingInterval=10;
    _start=quietingInterval;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) async {
            mPBookmark=_player.position.inSeconds;
        if (_start == 0) {
          setState(() {
            timer.cancel();

          });
          _player.setVolume(_player.volume-0.1);
          print(_player.volume);
          if(_player.volume>0){
            startQuietingTimer();
          }else{
            print("timerStartingSec $timerStartingSec _player.position: ${_player.position }_player.position-Duration(seconds: timerStartingSec~/4 ${_player.position-Duration(seconds: timerStartingSec~/4)}");
            //await _player.seek(_player.position-Duration(seconds: timerStartingSec~/4));
            mPBookmark=(mPBookmark!-timerStartingSec~/4)!;
            print("position1: ${_player.position}");
            _player.pause();
            print("position2: ${_player.position}");
            _player.setVolume(1);


            _start=timerStartingSec;
            isTimerRuning=false;

            setState(() {

            });
          }
        } else {
          setState(() {
            _start--;
          });


        }
      },
    );
  }

  whenPlayerFulliLoaded()async{
    print('whenPlayerFulliLoaded start');
    await setMp();
    book.lastWasEbook=false;


    await mfp.pMSetBook(book);

  }

  setMp()async{
    print('setMp start');
    bool lastWasEbook=book.lastWasEbook;
    print('lastWasEbook ${lastWasEbook}');
    List<int> indexMpList=[];
print('book.bookMarkCaracter ${book.bookMarkCaracter}');

      /*  await mfp.doSomethingAndLoad(context, 2, book.bookCode);
        Book book2=await mfp.pmNowReadingGet();
        book.bookMarkMp=book2.bookMarkMp;
        startMpBookmark=book.bookMarkMp;
        print('set Mp startMpBookmark $startMpBookmark-----------------------------');
      indexMpList=mpToIndexAndMp(startMpBookmark);
        //  await _player.seek(Duration(seconds: startMpBookmark));
        print('sadsaf indesx: ${indexMpList[0]} és mp: ${indexMpList[1]}');*/

    //if(false){



      startMpBookmark=book.bookMarkMp;
      print('set Mp startMpBookmark $startMpBookmark-----------------------------');
      indexMpList=mpToIndexAndMp(startMpBookmark);





    await _player.seek(Duration(seconds: indexMpList[1]), index: indexMpList[0]);
    firstPosition=_player.position;

  }
  setMpFromEbook()async{


    List<int> indexMpList=[];
    print('book.bookMarkCaracter ${book.bookMarkCaracter}');

    int avilbiableSyncPont=checkAvilbiableSyncPont();

      if(avilbiableSyncPont>0){
        indexMpList=mpToIndexAndMp(avilbiableSyncPont);
      }else{
        await mfp.doSomethingAndLoad(context, 2, book.bookCode);
        Book book2=await mfp.pmNowReadingGet();
        book.bookMarkMp=book2.bookMarkMp;
        startMpBookmark=book.bookMarkMp;
        print('set Mp startMpBookmark $startMpBookmark-----------------------------');
        indexMpList=mpToIndexAndMp(startMpBookmark);
        //  await _player.seek(Duration(seconds: startMpBookmark));
        print(' index: ${indexMpList[0]} and mp: ${indexMpList[1]}');
        setState(() {

        });
      }
      //if(false){


    await _player.seek(Duration(seconds: indexMpList[1]), index: indexMpList[0]);
    firstPosition=_player.position;
    await sharedPreferences.setString ("ondaysyncdate", DateTime.now().toString());
    book.lastWasEbook=false;
    await mfp.pMSetBook(book);
    setState(() {

    });

  }
  mpToIndexAndMp(int mp){
    List<int> returnList=[];
    int index=0;
    int mpAfterIndex=0;
    int mpSum=0;
    returnList.add(index);
    returnList.add(mpAfterIndex);
    for(int i=0;mpSum<mp;i++ ){
      mpSum=mpSum+durationList[i];
      if (mpSum>mp){
        index=i;
        mpAfterIndex=mp-(mpSum-durationList[i]);

        returnList.insert(0,index);
        returnList.insert(1,mpAfterIndex);
      }
    }
return returnList;
  }
  setBookmark()async{
  if(firstPosition!=_player.position){
    //book.bookMarkCaracter=-1;
  }
int fileDurationSum=0;

    for (int i=0;i<songIndex!;i++){
      fileDurationSum=fileDurationSum+durationList[i];

    }
  print("position3: ${_player.position}");
      fileDurationSum=fileDurationSum+mPBookmark;
  print("position4: ${_player.position}");



    print("mPBookmark $mPBookmark induration: ${Duration(seconds: mPBookmark??9)}");
  print("fileDurationSum $fileDurationSum induration: ${Duration(seconds: fileDurationSum??9)}");
    book.bookMarkMp=fileDurationSum;

    await mfp.pMSetBook(book);

    book.lastWasEbook=false;
    await mfp.pMSetBook(book);
    print('saved');
  }
  initAsync()async{
    sharedPreferences=await SharedPreferences.getInstance();
    _player = AudioPlayer();
   await firstStartCeckAndSet();
    book=await mfp.pmNowReadingGet();
    syncPontokList = await ppp.pMSharedListSyncPontokGet(book.bookCode);
      sleepFunctionTurndOn=await ppp.pMSharedBoolGet('sleepfunction');
    recuiredShakeForce=await ppp.sharedDoubleGet('force');
     avilbiableSyncPont=checkAvilbiableSyncPont();

      if(sleepFunctionTurndOn){
        buttonBackground=Colors.deepPurple;
      }else{
        buttonBackground=Colors.grey;
      }
setState(() {

});
      timerStartingSec=await ppp.sharedIntGet("timerduration");
   // timerStartingSec=5;
      _start = timerStartingSec;

    print('lastwasebok2 ${  book.lastWasEbook}');
    durationList=await ppp.pMSharedIntListGet('durationList${book.bookCode}');
    mp3PathList=await ppp.pMSharedListGet('mp3PathList${book.bookCode}');
    syncPurchased=await ppp.pMSharedBoolGet('syncPurchased')??false;
    syncIsAvailbiable=await checkSyncAvailability("ondaysyncdate");
    pictureSearchIsAvailbiable=await checkSyncAvailability("onedaypitcsearch");
    addToPlayList(mp3PathList);
    startMpBookmark=book.bookMarkMp;
    aBookName=book.aBookName;

    WidgetsBinding.instance?.addObserver(this);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
   // await refresh();
    print('initstateAsyc _init');
    _init();






  }


  plusMinute(int minute)async{
    if(_player.position.inSeconds + minute<_player.duration!.inSeconds){
      await _player.seek(Duration(seconds: _player.position.inSeconds + minute));
    }

  }
  minusMinute(int minute)async{
    if(_player.position.inSeconds>minute){ await _player.seek(Duration(seconds: _player.position.inSeconds - minute));}

  }
  rememberSpeed() async{
    if(!firstSpeedChange){
      await ppp.sharedDoubleSet('speed', _player.speed);
    }else{
      try{   _player.setSpeed(await ppp.sharedDoubleGet('speed'));}catch(e){print('ppp.sharedDoubleGet(speed)');}
      firstSpeedChange=false;}
  }





  @override
  void initState() {
    super.initState();

    initAsync();


  }
  Future<void> _init() async {

    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        });

    _player.currentIndexStream.listen((duration) {
      songIndex = _player.playbackEvent.currentIndex;
      print('current index: $songIndex, duration: $duration');
      String mp3pathLocal=mp3PathList[songIndex!];
      setState(() {
        aBookName=mp3pathLocal.split('/').last;
      });


    });

    _player.speedStream.listen((event) {
      rememberSpeed();
    });
    _player.playingStream.listen((state) {
print ('playingStream=$state');
      if(state ){

        setBookmark();
        if(isTimerRuning){
          _timer.cancel();
          _player.setVolume(1.0);
          _start=timerStartingSec;
          quietingTimeron=false;
          setState(() {

          });
        }

      }else{
        if(sleepFunctionTurndOn){
          startSleepTimer();
      //    isTimerRuning=true;
        }

      }
    });



    // Try to load audio from a source and catch any errors.

    try {

      await  _player.setAudioSource(
        ConcatenatingAudioSource(children: audioList/*[

          AudioSource.uri(
            Uri.file("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/04 The Way of Kings (Grahpic Audio) - Chapter 1.mp3"),
            tag: MediaItem(
              id: '${_nextMediaId++}',
              album: "Science Friday",
              title: "A Salute To Head-Scratching Science",
              artUri: Uri.parse(
                  "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
            ),
          ),
          AudioSource.uri(
            Uri.file("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/05 The Way of Kings (Grahpic Audio) - Chapter 2.mp3"),
            tag: MediaItem(
              id: '${_nextMediaId++}',
              album: "Science Friday",
              title: "From Cat Rheology To Operatic Incompetence",
              artUri: Uri.parse(
                  "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
            ),
          ),
          AudioSource.uri(
            Uri.parse("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/06 The Way of Kings (Grahpic Audio) - Chapter 3.mp3"),
            tag: MediaItem(
              id: '${_nextMediaId++}',
              album: "Public Domain",
              title: "Nature Sounds",
              artUri: Uri.parse(
                  "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
            ),
          ),
        ]*/)
       /* ConcatenatingAudioSource(
          // Start loading next item just before reaching it.
          useLazyPreparation: true, // default
          // Customise the shuffle algorithm.
          shuffleOrder: DefaultShuffleOrder(), // default
          // Specify the items in the playlist.
          children: [
            AudioSource.uri(Uri.file("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/04 The Way of Kings (Grahpic Audio) - Chapter 1.mp3")),
            AudioSource.uri(Uri.file("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/05 The Way of Kings (Grahpic Audio) - Chapter 2.mp3")),
            AudioSource.uri(Uri.file("/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/06 The Way of Kings (Grahpic Audio) - Chapter 3.mp3")),
          ],

        ),
        // Playback will be prepared to start from track1.mp3
        initialIndex: 0, // default
        // Playback will be prepared to start from position zero.
        initialPosition: Duration.zero, // default
*/


      /*  AudioSource.uri(
        Uri.file('/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/04 The Way of Kings (Grahpic Audio) - Chapter 1.mp3'),
//file:////data/user/0/com.example.audio_ebook_sync/cache/file_picker/Throne of Glass egybe.mp3
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: '134',
          // Metadata to display in the notification:
          album: "Album name",
          title: "Song name",
          //  artUri: Uri.file(book.aBookPath),

        ),
      )*/
        ,);
      //   await _player.setFilePath(book.aBookPath);
    } catch (e) {
      print("Error loading audio source: $e");
    }


    whenPlayerFulliLoaded();
  }


  /*refresh()async{
    soundDirectory= await  ppp.pMSharedStringGet('soundDirectory');
    List<String>fileList=await mfp.folderPathToContainingMp3Paths(soundDirectory!);
    for(int i=0;i<fileList.length;i++){
      print(fileList[i]);
    }
    addToPlayList(fileList);
   mfp.pathListToDurationList(fileList);

  }*/
  loadImage(String path){
    if(path.isNotEmpty){
      return Image.file(new File(path));
    }else{
      return Padding(padding: EdgeInsets.all(3),child:Image.asset("assets/no-image.png") ,);
    }

    //  Image.file(new File(bookList[index].bookCoverPath)),

  }
  addToPlayList(List<String> pathList){


    audioList=[];
   for(int i=0;i<pathList.length;i++){
     print('bookcoverpath${book.bookCoverPath}');
      audioList.add( AudioSource.uri(
        Uri.file(pathList[i]),
        tag: MediaItem(
          id: '${_nextMediaId++}',
          album: "",
          title: pathList[i].substring(pathList[i].lastIndexOf('/')+1),
          artUri: Uri.file(
              book.bookCoverPath
          ),
        ),
      ));

   //   print('aaaaaaaaaaaaa alap:$kalap')
    }
    /*
    audioList.add( AudioSource.uri(
      Uri.file('/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/04 The Way of Kings (Grahpic Audio) - Chapter 1.mp3'),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ));
    audioList.add( AudioSource.uri(
      Uri.file('/storage/emulated/0/könyv/hangos/The Stormlight Archive 1 - The Way of Kings (1 of 5)/05 The Way of Kings (Grahpic Audio) - Chapter 2.mp3'),
      tag: MediaItem(
        id: '${_nextMediaId++}',
        album: "Science Friday",
        title: "A Salute To Head-Scratching Science",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ));*/
    print('addToPlayList _init');
 //_init();

  }

  @override
  void dispose() {
    setBookmark();
    _player.dispose();
    if(timerInitialited)_timer.cancel();

   stopSensor();


    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));




  @override
  Widget build(BuildContext context) {
    print("build");
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Expanded(
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) return SizedBox();
                    final metadata = state!.currentSource!.tag as MediaItem;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:


                            loadImage(book.bookCoverPath),

                            //   Image.file(new File(metadata.artUri.toString()))

                          ),
                        ),
                        topMenu(),
                        Text(
                           metadata.title,
                            style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*  ElevatedButton(onPressed: () async {
                                 await probaButton();
                                }, child: Text("play")),
                              ElevatedButton(onPressed: () async {await ppp.pMcut(mp3PathList[0],"outputName2.mp3",100,110);}, child: Text("convert")),*/
                              IconButton(padding: EdgeInsets.symmetric(horizontal: 30),onPressed: () async {

                                if(syncPurchased){
                                  await photoButton();
                                }else{
                                  if(pictureSearchIsAvailbiable){
                                    await  ppp.showDialoWithButtons("Picture Search", "You can search only ones a day with free plan.", context, "cancel", "search", photoButton);
                                  }else{
                                    await  ppp.showDialoWithButtons("Picture Search", "Your daily one camera search is used up.", context, "cancel", "Upgrade", upgrade);
                                  }
                                }


                                }, icon: Icon(Icons.photo_camera_outlined,size: 50,)),
                              ElevatedButton(onPressed: (){




                                if(isTimerRuning){
                                  stopSensor();
                                  _timer.cancel();
                                  isTimerRuning=false;
                                  _start=timerStartingSec;
                                  setState(() {

                                  });
                                }
                                if(sleepFunctionTurndOn){
                                  sleepFunctionTurndOn=false;
                                  buttonBackground=Colors.grey;
                                  saveSleepFunction(false);
                                  setState(() {

                                  });

                                }else{
                                  if(_player.playing&& !isTimerRuning){
                                    startSleepTimer();
                                  }
                                  buttonBackground=Colors.deepPurple;
                                  sleepFunctionTurndOn=true;

                                  saveSleepFunction(true);
                                  setState(() {

                                  });

                                }
    },onLongPress: (){
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
                                                    Text('Sleep Timer:'),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [

                                                        OutlinedButton( style: TextButton.styleFrom(side: BorderSide(width: 2,color:timerStartingSec==5*60?Colors.deepPurple:Colors.grey)),onPressed: (){setAndSaveSleepTimerDuration(5*60);Navigator.of(context).pop();}, child: Text('5p'),),
                                                        OutlinedButton(style: TextButton.styleFrom(side: BorderSide(width: 2,color:timerStartingSec==10*60?Colors.deepPurple:Colors.grey)),onPressed: (){setAndSaveSleepTimerDuration(10*60);Navigator.of(context).pop();}, child: Text('10p')),
                                                        OutlinedButton(style: TextButton.styleFrom(side: BorderSide(width: 2,color:timerStartingSec==15*60?Colors.deepPurple:Colors.grey)),onPressed: (){setAndSaveSleepTimerDuration(15*60);Navigator.of(context).pop();}, child: Text('15p')),
                                                      ],

                                                    ),
                                                    Text('Sensitivity:'),
                                                    OutlinedButton(style: TextButton.styleFrom(side: BorderSide(width: 2,color:recuiredShakeForce==0.05?Colors.deepPurple:Colors.grey)),onPressed: (){saveAndSetRecuiredShakeForce(0.05);Navigator.of(context).pop();}, child: Text('Litle shake'),),
                                                    OutlinedButton(style: TextButton.styleFrom(side: BorderSide(width: 2,color:recuiredShakeForce==0.1?Colors.deepPurple:Colors.grey)),onPressed: (){saveAndSetRecuiredShakeForce(0.1);Navigator.of(context).pop();}, child: Text('Medium shake')),
                                                    OutlinedButton(style: TextButton.styleFrom(side: BorderSide(width: 2,color:recuiredShakeForce==2?Colors.deepPurple:Colors.grey)),onPressed: (){saveAndSetRecuiredShakeForce(2);Navigator.of(context).pop();}, child: Text('Hard shake')),
                                                  ],
                                                ),
                                              );
                                          },
                                        ),
                                        actions: <Widget>[
                                      /*    TextButton(
                                            child: const Text('Back'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),*/
                                          TextButton(
                                            child: const Text('ok'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                          //    choosingFinished(context);
                                            },
                                          ),


                                        ],



                                      );
                                    });
                              },


                                child: Text('${buttonText+(_start.toInt()~/60).toString()}:${(_start%60).toString()}',textAlign: TextAlign.center,),style: ElevatedButton.styleFrom(
                                primary:buttonBackground, // This is what you need!
                              ),),
                            ],
                          )

                      ],
                    );
                  },
                ),
              ),
              ControlButtons(_player),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Expanded(child: TextButton(onPressed: (){minusMinute(60);}, child: Text('-1m',style: TextStyle(color: Colors.black)))),
                Expanded(child: TextButton(onPressed: (){minusMinute(15);}, child: Text('-15s',style: TextStyle(color: Colors.black)))),
                  Expanded(child: TextButton(onPressed: (){plusMinute(15);}, child: Text('+15s',style: TextStyle(color: Colors.black)))),
                  Expanded(child: TextButton(onPressed: (){plusMinute(60);}, child: Text('+1m',style: TextStyle(color: Colors.black)))),


              ],),

              StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {

                  final positionData = snapshot.data;
                  mPBookmark=positionData?.position  .inSeconds??0;



                  return SeekBar(

                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition:
                    positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: (newPosition) {
                      _player.seek(newPosition);


                    },
                  );
                },
              ),

              SizedBox(height: 8.0),


            ],
          ),
        ),

      ),
    );
  }
  Widget topMenu(){
    return Visibility(
        visible: book.lastWasEbook==true && avilbiableSyncPont==0,
        child: Container(
          color: Colors.white,

          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: syncIsAvailbiable? Text("Go where I left off in the audiobook"): Text("Daily one sync, is used up"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: syncIsAvailbiable ?ElevatedButton( onPressed: () async {
                      if(syncPurchased){
                        //purchased
                        await setMpFromEbook();
                        book.lastWasEbook=false;
                        await mfp.pMSetBook(book);
                        setState(() {

                        });
                      }else{
                        //when not purchased but have daily one sync
                        await ppp.showDialoWithButtons("Warning", "You have only one ebook and audio bookmark synchronisation /day.", context, "cancel", "Go",   setMpFromEbook);
                      }

                    }, child: Text("Go")) : ElevatedButton(onPressed: (){upgrade();}, child: Text("Upgrade")),
                  ),
                  Divider(color: Colors.black,height: 1,)

                ],
              ),
            ],
          ),
        )
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

PPP ppp=PPP();
  ControlButtons(this.player);

  next()async{
    await player.seekToNext();
  }
  previous()async{
    await player.seekToPrevious();
  }



  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(Icons.arrow_back_rounded,),
          onPressed:(){previous();} ,
        ),


        IconButton(
          icon: Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),


        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),


        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                stream: player.speedStream,
                onChanged: player.setSpeed,

              );
            },
          ),
        ),
        IconButton(icon: Icon(Icons.arrow_forward_rounded,),
          onPressed:(){next();} ,

        ),

      ],
    );
  }
}