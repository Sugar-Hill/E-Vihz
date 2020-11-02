import 'package:flutter/foundation.dart';

class itemQuantity with ChangeNotifier {
  int _numberOfItems=0;
  int get nuberOfIetms=>_numberOfItems;
  @override
  void dispose() {
    // TODO: implement dispose
    notifyListeners();
  }
}
