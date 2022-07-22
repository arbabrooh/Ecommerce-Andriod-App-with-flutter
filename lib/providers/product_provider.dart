import "dart:convert";
// import 'dart:async';
// import 'dart:io';
//necessary to use the changeNotifier mixin
import "package:flutter/material.dart";
//neccessary to use the http package
import 'package:http/http.dart' as http;

import "../models/exception_model.dart";
import "../models/product_model.dart";

class ProductProvider with ChangeNotifier {
  List<ProductModel> _items = [
    // ProductModel(avaliableSizes: [
    //   "UK 8",
    //   "UK 10"
    // ], id: "pdt1", quantity: 20, imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/01/054237/1.jpg?1980", price: 3199.99, title: "Sunbi Red And Animal Print Shift Dress", description: "Two colour toned Red and Animal print dress, made from Polyester and spandex"),
    // ProductModel(
    //   id: "pdt2",
    //   imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/20/146543/1.jpg?0621",
    //   price: 2000,
    //   title: "Midi Pencil Skirt",
    //   description: "Black smart fit Bodycon Pencil Skirt made of Polyester",
    //   quantity: 20,
    //   avaliableSizes: [
    //     "S",
    //     "L",
    //     "XL"
    //   ],
    // ),
    // ProductModel(quantity: 20, id: "pdt3", title: "Crossbody HandBag", description: "Luxury Designer Chain Crossbody Women Handbag", imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/07/719164/1.jpg?3132", price: 1400, avaliableSizes: [
    //   "23cm(L)x7cm(W)x19cm(H)"
    // ]),
    // ProductModel(quantity: 20, title: "Polka Dot Short Sleeve", price: 6000, id: "pdt4", imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/37/268383/1.jpg?9312", description: "flower printed gown made of Polyester", avaliableSizes: [
    //   "S",
    //   "L"
    // ]),
    // ProductModel(quantity: 20, title: "Ladies Mini Hand Bag", id: "pdt5", price: 6520.40, imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/29/359409/1.jpg?8555", description: " Smart Leather Mini Hand Bag - RED "),
    // ProductModel(
    //   id: "pdt6",
    //   quantity: 20,
    //   title: "Shoulder Leather HandBag",
    //   price: 1200,
    //   description: "Pattern All Outfit Matching Quality Shoulder PU Leather Female Handbag",
    //   imageUrl: "https://ng.jumia.is/unsafe/fit-in/500x500/filters:fill(white)/product/82/699054/1.jpg?6357",
    // )
  ];

  final String? authToken;
  final String? userId;

  ProductProvider(this.authToken, this._items, this.userId);

  List<ProductModel> get items {
    return [..._items];
  }

  ProductModel findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> removeItem(String id) async {
    final _itemIndex = _items.indexWhere((product) => product.id == id);
    dynamic _currentItem = _items[_itemIndex];
    var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
        "/products/$id.json", {'auth': authToken});
    final respond = await http.delete(url);
    _items.removeAt(_itemIndex);
    notifyListeners();
    if (respond.statusCode >= 400) {
      _items.insert(_itemIndex, _currentItem);
      notifyListeners();
      throw HttpException(
          "An error occur. You cannot delete now, try again."); //custom writen exception that implement the Exception Class
    }
    _currentItem = null;
  }

  List<ProductModel> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  //void addProduct(ProductModel product) {
  //appProduct change to a future to ensure we can run a function once addProduct is done executing
  //and other below can run asynchronously

//Asyn using .then, catchError and whenComplete keyword
  // Future<void> addProduct(ProductModel product) {
  //   /*sending http request... the /products is use to create for folder for the file... Uri.https Creates a new https URI from authority, path and query. */
  //   var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com]][", "/products.json");
  //   //https.post use to send or store data to the db.. it receives a url and body which endecoded to maps
  //   //since addProduct is a future is should return the http request
  //   return http
  //       .post(url,
  //           body: json.encode({
  //             //json.encode is use to encode the data to a json object which is accept by the db
  //             "title": product.title,
  //             "quantity": product.quantity,
  //             "price": product.price,
  //             "description": product.description,
  //             "imageUrl": product.imageUrl,
  //             "isFavourite": product.isFavourite,
  //           })
  //           //a future is todo function which runs in background while other code down it continue asynchronously
  //           //since http.post is a future, we can return a function that will run when future is done
  //           )
  //       .then((response) {
  //     //response is a unique id from firebase.. hence we can use it as an id
  //     final newProduct = ProductModel(
  //         quantity: product.quantity,
  //         imageUrl: product.imageUrl,
  //         //hence response is gotten flutter, it in json form.. hence, it has to be decoded to a map with json.decode
  //         //reponse.body gives us the body of the data recieved and we get the id using the ["name"] key
  //         id: json.decode(response.body)["name"],
  //         title: product.title,
  //         description: product.description,
  //         price: product.price);
  //     _items.add(newProduct);
  //     notifyListeners();
  //   }).catchError((error){
  //       throw error;
  //   });

  // }

  //using Async with the async and await keyword
  Future<void> addProduct(ProductModel product) async {
    /*sending http request... the /products is use to create for folder for the file... Uri.https Creates a new https URI from authority, path and query. */

    //https.post use to send or store data to the db.. it receives a url and body which endecoded to maps
    //since addProduct is a future is should return the http request

    try {
      var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/products.json", {'auth': authToken});
      //the response is a unique id from firebase.. hence we can use it as an id
      final response = await http.post(url,
          body: json.encode({
            //json.encode is use to encode the data to a json object which is accept by the db
            "title": product.title,
            "quantity": product.quantity,
            "price": product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "category": product.category
          })
          //a future is todo function which runs in background while other code down it continue asynchronously
          );

      //the code below await run only after the await return a result
      final newProduct = ProductModel(
          quantity: product.quantity,
          imageUrl: product.imageUrl,
          //hence response is gotten flutter, it in json form.. hence, it has to be decoded to a map with json.decode
          //reponse.body gives us the body of the data recieved and we get the id using the ["name"] key
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          category: product.category,
          price: product.price);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, ProductModel newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);
    //check to ensure product is updated for where id is found
    if (productIndex >= 0) {
      try {
        var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
            "/products/$id.json", {'auth': authToken});
        await http.patch(url,
            body: json.encode({
              "title": newProduct.title,
              "quantity": newProduct.quantity,
              "price": newProduct.price,
              "description": newProduct.description,
              "imageUrl": newProduct.imageUrl,
            }));
        _items[productIndex] = newProduct;
      } catch (error) {
        // print(error);
        rethrow;
      }
    }
    notifyListeners();
  }

  Future<void> fetchAndSetProduct() async {
    List<ProductModel> _newProductList = [];
    try {
      //print(authToken);
      var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/products.json", {'auth': authToken} //use to add authtoken path
          );
      final response = await http.get(
        url,
        // headers: {
        //   HttpHeaders.authorizationHeader: '$authToken',
        // },
      );
      //decoding to extractedDbData will start when http.get is done executing
      final _extractedDdData =
          json.decode(response.body) as Map<String?, dynamic>;
      // if (_extractedDdData == null) {
      //   return;
      // }
      var favUrl = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/userFavourite/$userId.json", {'auth': authToken});
      final responseFavUrl = await http.get(favUrl);
      final favResponseData = json.decode(responseFavUrl.body);

      _extractedDdData.forEach((key, product) {
        final double? price = double.parse(product['price'].toString());
        //debugPrint(product.toString());
        //key is the prodId;
        _newProductList.insert(
            0,
            ProductModel(
                category: product["category"] as String?,
                id: key,
                price: price, //double.parse("$"),
                quantity: product["quantity"] as int?,
                description: product["description"] as String?,
                title: product["title"] as String?,
                imageUrl: product["imageUrl"] as String?,
                isFavourite: favResponseData == null
                    ? false
                    : favResponseData[key] ?? false));
      });
      _items = _newProductList;
    } catch (error) {
      rethrow;
    }
  }

  List<ProductModel>? searchResult(String input) {
    List<ProductModel> searchList = _items
        .where((element) =>
            element.title!.toLowerCase().contains(input.toLowerCase()))
        .toList();
    return searchList;
  }

  List<ProductModel> bagProducts() {
    List<ProductModel> searchList =
        _items.where((element) => element.category == "Bags").toList();
    return searchList;
  }

  List<ProductModel> shoeProducts() {
    List<ProductModel> searchList =
        _items.where((element) => element.category == "Shoes").toList();
    return searchList;
  }

  List<ProductModel> clothingProducts() {
    List<ProductModel> searchList =
        _items.where((element) => element.category == "Clothing").toList();
    return searchList;
  }

  List<ProductModel> hairProducts() {
    List<ProductModel> searchList =
        _items.where((element) => element.category == "Hairs").toList();
    return searchList;
  }
}
