import 'package:flutter/material.dart';

Color mColoPurple=Colors.deepPurple;
Color mGrey=Colors.grey;
//Color mGreyBackground=Colors.grey[80];

BoxDecoration mBoxDecorationWhite=BoxDecoration(
    color: Colors.white,
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1),
      spreadRadius: 0.5,
      blurRadius: 1,
    )],
    borderRadius: BorderRadius.all(Radius.circular(10))
);

BoxDecoration mBoxDecorationGrey=BoxDecoration(
    color: Colors.grey[80],
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1),
      spreadRadius: 0.5,
      blurRadius: 1,
    )],
    borderRadius: BorderRadius.all(Radius.circular(10))
);


BoxDecoration mBoxDecorationWhiteButtomMenu=BoxDecoration(
    color: Colors.white,
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2),
      spreadRadius:3,
      blurRadius: 4,
    )],
    //borderRadius: BorderRadius.all(Radius.circular(10))
);
BoxDecoration mBoxDecorationWhiteSearch=BoxDecoration(
  color: Colors.white,
  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2),
    spreadRadius:3,
    blurRadius: 4,
    offset: Offset(0,4)
  )],
  //borderRadius: BorderRadius.all(Radius.circular(10))
);