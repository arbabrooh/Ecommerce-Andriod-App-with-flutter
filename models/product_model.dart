import "dart:convert"; //neccessary to use json.encode and json.decode

import "package:flutter/foundation.dart";
import 'package:flutter/widgets.dart';

import "package:http/http.dart" as http;
import "./exception_model.dart";

class ProductModel with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  final int? quantity;
  final List<String>? avaliableSizes;
  bool isFavourite;
  String? category;

  ProductModel(
      {@required this.category,
      this.avaliableSizes,
      @required this.quantity,
      @required this.imageUrl,
      @required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      this.isFavourite = false});

  Future<void> toggleFavourite(String? authToken, String? userId) async {
    var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
        "/userFavourite/$userId/$id.json", {'auth': authToken});
    var _favStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final respond = await http.put(url,
          body: json.encode(
            isFavourite,
          ));
      if (respond.statusCode >= 400) {
        isFavourite = _favStatus;
        notifyListeners();
        throw HttpException("An Error");
      }
    } catch (error) {
      rethrow;
    }
  }
}
