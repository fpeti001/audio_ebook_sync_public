import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_ebook_sync/splitted_text/constant.dart';
import 'package:audio_ebook_sync/splitted_text/logic/dyamicSize.dart';
import 'package:audio_ebook_sync/splitted_text/logic/splittedText.dart';

class PageControlBloc extends Cubit<int> {
  PageControlBloc() : super(0) ;

  DynamicSize _dynamicSize = DynamicSizeImpl();
  SplittedText _splittedText = SplittedTextImpl();
  Size ?_size;
  List<String> _splittedTextList = [];
  List<String> get splittedTextList => _splittedTextList;

  getSizeFromBloc(GlobalKey pagekey,double sidePadding) {
    double height=0;
    double width=0;
    _size = _dynamicSize.getSize(pagekey);
height=_size!.height;
//a -1 a selectable text miaatt kell mert hiába szeded le a cursorWidth-t 1pixel szünet mindenképp marad a végén
    width=(_size!.width-2)-(2*sidePadding);
    _size=Size(width, height);

    print(_size);
  }

  getSplittedTextFromBloc(TextStyle textStyle,String bookString) {
    _splittedTextList =
        _splittedText.getSplittedText(_size!, textStyle, bookString);
  }

  void changeState(int currentIndex) {
    emit(currentIndex);
  }
}
