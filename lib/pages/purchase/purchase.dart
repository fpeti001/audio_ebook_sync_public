import 'dart:io';



import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:audio_ebook_sync/services/mFP.dart';
import 'package:audio_ebook_sync/services/ppp.dart';

import '../../aebook_styles.dart';
import '../../auth/secrets.dart';


class Purchase extends StatefulWidget {
  const Purchase({Key? key}) : super(key: key);

  @override
  State<Purchase> createState() => _PurchaseState();
}
enum PackageType{monthly,annual, sixMont, threeMonth, twoMonth, weekly, lifetime,empty}

class _PurchaseState extends State<Purchase> {
  PPP ppp = PPP();
  Mfp mfp = Mfp();
  late Offerings offerings;
  String nowPageTitle = "";
  int offerNumber = 0;
  int productNumber = 0;

  List<String> stringList=[];
  PackageType payPeriod=PackageType.monthly;

  List<MProduct> mProductList=[];
  List<MOffering> mofferList=[];

  bool syncPurchased=false;
  static final facebookAppEvents = FacebookAppEvents();


  restore() async {
    await Purchases.syncPurchases();
/*
  try {

    PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
    print("restored inffoooo: $restoredInfo");
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      if (purchaserInfo.entitlements.all["50_token_offer"]!.isActive) {
        // Grant user "pro" access
        ppp.popup(' purchase Activee');
        print(" purchase Activee");
      }
    } on PlatformException catch (e) {
      ppp.popup('is purchased EROR');
      print("is purchased EROR");
      // Error fetching purchaser info
    }
    // ... check restored purchaserInfo to see if entitlement is now active
  } on PlatformException catch (e) {
    // Error restoring purchases
  }*/
  }

  isitpurchased() async {
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      if (purchaserInfo.entitlements.all["50_token_offer"]!.isActive) {
        // Grant user "pro" access
        ppp.popup(' purchase Activee');
        print(" purchase Activee");
      }
    } on PlatformException catch (e) {
      ppp.popup('is purchased EROR');
      print("is purchased EROR");
      // Error fetching purchaser info
    }
  }
getPackage(){
  String duration=mofferList[offerNumber].productList[productNumber].productDuration;
  Package? package;
 /*

  Three Month
  Six Month
  Annual
  Lifetime*/
    switch(duration){
      case "Weekly":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.weekly;
        break;
      case "Monthly":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.monthly;
        break;
      case "Two Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.twoMonth;
        break;
      case "Three Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.threeMonth;
        break;
      case "Six Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.sixMonth;
        break;
      case "Annual":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.annual;
        break;
      case "Lifetime":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.lifetime;
        break;

  }

  return package;








}
  purchase() async {

    if(!syncPurchased){
      Offerings offerings = await Purchases.getOfferings();

      Package? packagee = getPackage();
      try {
        PurchaserInfo purchaserInfo = await Purchases.purchasePackage(packagee!);
        if (purchaserInfo.entitlements.all["1entitlement"]!.isActive) {
          facebookAppEvents.logEvent(
              name: 'costum_purchase_event',
              parameters: {
                'button_id': 'the_costum_purchase_event_button',
              },);
          await ppp.pMSharedBoolSet("syncPurchased", true);
          ppp.showMyDialog("Purchase Succesfull!", "", context);



          // Unlock that great "pro" content
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
          ppp.showMyDialog("Error", "Error: $e", context);
        }
      }
    }else{
      ppp.showMyDialog("You already subscribed!", "", context);
    }



   /* if (offerings.getOffering("asdsdga")?.monthly != null) {
      try {
                PurchaserInfo purchaserInfo =
            await Purchases.purchasePackage(packagee!);
        if (purchaserInfo.entitlements.all["asdsdga"]!.isActive) {
          // Unlock that great "pro" content
          print("vááááááásáRLÁÁÁÁÁÁÁÁÁÁS KÉSSSSSSSSSSSSSSSZ");
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
          (e);
          print("vááááááásáRLÁÁÁÁÁÁÁÁÁÁS EROOOOOOOOOOOR");
        }
      }
    }*/
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

  initDataTre() async {
    List<Offering> offeringList = [];
    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        print("printoffering:  ${offerings}");
        // Display current offering with offerings.current
      }
    } on PlatformException catch (e) {
      // optional error handling
    }
    try {
      List<String> keyList = offerings.all.keys.toList();
      for (int i = 0; keyList.length > i; i++) {
        offeringList.add(offerings.all[keyList[i]]!);
      }
    } catch (e) {}





   for(int i=0;i<offeringList.length;i++){

     List<MProduct> mProductList=[];
     try{mProductList.add(MProduct("Weekly", " ${offeringList[i].weekly!.product.price} ${offeringList[i].weekly!.product.currencyCode}"));}catch(e){};
     try{mProductList.add(MProduct("Monthly", " ${offeringList[i].monthly!.product.price} ${offeringList[i].monthly!.product.currencyCode}"));}catch(e){};
     try{   mProductList.add(MProduct("Two Month",  " ${offeringList[i].twoMonth!.product.price} ${offeringList[i].twoMonth!.product.currencyCode}"));}catch(e){};
     try{mProductList.add(MProduct("Three Month",  " ${offeringList[i].threeMonth!.product.price} ${offeringList[i].threeMonth!.product.currencyCode}"));}catch(e){};
     try{mProductList.add(MProduct("Six Month",  " ${offeringList[i].sixMonth!.product.price} ${offeringList[i].sixMonth!.product.currencyCode}"));}catch(e){};
     try{ mProductList.add(MProduct("Annual",  " ${offeringList[i].annual!.product.price} ${offeringList[i].annual!.product.currencyCode}"));}catch(e){};
     try{mProductList.add(MProduct("Lifetime",  " ${offeringList[i].lifetime!.product.price} ${offeringList[i].lifetime!.product.currencyCode}"));}catch(e){};

     mofferList.add(MOffering(offeringList[i].identifier, offeringList[i].serverDescription, mProductList,offeringList[i].identifier));
   }

 print("mofferlist= $mofferList");

  }

  initAsync() async {
    print("--------------------------------initAsync");
    syncPurchased=await ppp.pMSharedBoolGet('syncPurchased')??false;
    await initPurchase();
    await initDataTre();
   // createOfferingList();
    //showDurationOffers();
    setState(() {});
  }

  updatePurchaseStatus() async {
    final purechaserInfo = await Purchases.getPurchaserInfo();
    final entitlement = purechaserInfo.entitlements.active.values.toList();
    print("Purechaser INfoo: $entitlement");
  }

  @override
  void initState() {
    Purchases.addPurchaserInfoUpdateListener((info) async {
      updatePurchaseStatus();
      // handle any changes to customerInfo
    });
    print("object");
    initAsync();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try{   stringList= mofferList[offerNumber].offeringDescription.split("|");
    for(int i=0;i<stringList.length;i++){
      stringList[i].replaceAll("|", "");
    }}catch(e){}



    // String arguments = (ModalRoute.of(context)?.settings.arguments ?? "nemment")as String;
    return Scaffold(
      backgroundColor:Colors.grey[80],

        // appBar: AppBar(title: Text("purchase"),),
        body:
        SafeArea(child: Column(children: [
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
        syncPurchased? Center(child: Text("Subscribed!",style: TextStyle(fontSize: 30,color: Colors.deepPurple),)):Spacer(),

        Row(children:
          offerTitles()??[]
        ,),
          Padding(
            padding: const EdgeInsets.only(left:20.0),
            child: Row(children:
              productTitles()??[]
            ,),
          ),

          Expanded(
            flex: 6,
              child: Column(children: offerDescription()??[])),




          showPrice()??Text(""),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: StadiumBorder(),
                    minimumSize: const Size(double.infinity,
                        double.infinity), // <--- this line helped me
                  ),
                  onPressed: () async {
                    print("purchase");
                    facebookAppEvents.logEvent(
                        name: 'costum_purchase_event',
                    );
                        // purchase();

                  },
                  child: Text("Buy Now")),
            ),
          ),
          Text("Cancel anytime and 7-day free trial!",style: TextStyle(fontSize: 18)),


        ]



        )));
  }



   offerTitles() {
    List<Widget> widgedtList = [];
    //  List<Offering> offeringList=offerings.all;
    try {
      for (int i = 0; i < mofferList.length; i++) {
        String description = mofferList[i].offeringDescription;

        widgedtList.add(Padding(
          padding: EdgeInsets.all(3),
          child: TextButton(
              style: TextButton.styleFrom(
                 // side: BorderSide(color: Colors.blue),
                  backgroundColor: i==offerNumber ? Colors.white:Colors.grey[80],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              onPressed: () {
                offerNumber = i;
                productNumber=0;
                print("packagenumber $offerNumber");
                setState(() {});
              },
              child: Text(description.substring(0, description.indexOf("|")), style: TextStyle(color: Colors.black),)),
        ));
      }

      print("try finish");
      return        widgedtList;
    } catch (e) {}



  }
productTitles(){
  List<Widget> widgedtList = [];
  try {
    for (int i = 0; i < mofferList[offerNumber].productList.length; i++) {

      widgedtList.add(Padding(
        padding: EdgeInsets.all(3),
        child: TextButton(
            style: TextButton.styleFrom(
              // side: BorderSide(color: Colors.blue),
                backgroundColor: i==productNumber ? Colors.white:Colors.grey[80],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
            onPressed: () {
              productNumber = i;
              print("packagenumber $offerNumber");
              setState(() {});
            },
            child: Text(mofferList[offerNumber].productList[i].productDuration, style: TextStyle(color: Colors.black),))),
      );
    }

    print("try finish");
    return        widgedtList;
  } catch (e) {}

}





   offerDescription() {
     List<Widget> widgetList=[];
    try {

    List<String> stringList= mofferList[offerNumber].offeringDescription.split("|");
    for(int i=0;i<stringList.length;i++){
      stringList[i].replaceAll("|", "");
    }
    for(int i=1;i<stringList.length;i++){
      widgetList.add(
      Padding(
        padding:  EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
            decoration: mBoxDecorationWhite,
            //  color: Colors.grey,
            width:double.infinity,
            child: Text(stringList[i],style: TextStyle(fontSize: 20),)),
      )
      );
    }



    return widgetList;

/*
      ElevatedButton(child: Text('purchase'),onPressed: (){ purchase();},),
      ElevatedButton(child: Text('is it purchased?'),onPressed: (){ isitpurchased();},),
      ElevatedButton(child: Text('restore'),onPressed: (){ restore();},),
      ElevatedButton(child: Text('offers'),onPressed: (){ offers();},),




      ElevatedButton(onPressed: (){setState(() {
        print("refresh");
      });}, child: Text("refresh"))
    */
    

    } catch (e) {

    }
  }

  showPrice(){
    try{return   Text("Price: ${mofferList[offerNumber].productList[productNumber].productPrice} ${mofferList[offerNumber].productList[productNumber].productDuration}",style: TextStyle(fontSize: 20),);}catch(e){}

  }

}
class MProduct  {
  String productDuration="";
  String productPrice="";



  MProduct( String productDuration, String productPrice){
    this.productDuration=productDuration;
    this.productPrice=productPrice;

  }
}
class MOffering  {
  String offeringIdentifier="";
  String offeringDescription="";
  String offeringName="";
  List<MProduct> productList=[];


  MOffering(String offeringName, String offeringDescription, List<MProduct> productList,offeringIdentifier){
    this.offeringIdentifier=offeringIdentifier;
   this.offeringName=offeringName;
    this.productList=productList;
    this.offeringDescription=offeringDescription;
  }
}