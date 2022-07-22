import "dart:convert";

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "../models/exception_model.dart";

// enum DeliveryStatus {
//   Delivered,
//   Cancelled,
//   InDelivery,
//   Confirm,
//   Pending,
// }

class CartItem {
  final String? id;
  final String? title;
  final double? price;
  int? quantity;
  // DeliveryStatus deliveryStatus = DeliveryStatus.Pending; ///

  CartItem({this.id, this.title, this.price, this.quantity});
}

class Cart with ChangeNotifier {
  var cartId = "";
  Map<String, CartItem> _items = {};
  final String? authToken;
  final String? userId;

  Cart(this.authToken, this._items, this.userId);

  Map<String, CartItem> get items {
    return {..._items};
  }

  int getQuantity(String productId) {
    final item = _items[productId]!.quantity!;
    return item;
  }

  Future<void> addItem(String productId, double price, String title) async {
    var initRun = false;
    if (!_items.containsKey(productId)) {
      try {
        var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
            "/carts/$userId.json", {"auth": authToken});
        final respond = await http.post(url,
            body: json.encode({
              "title": title,
              "price": price,
              "quantity": 1,
              "productId": productId, // this is the key of the map
            }));
        //to ensure cartid is saved after the first run
        if (!initRun) {
          cartId = json.decode(respond.body)["name"];
          initRun = true;
        }
        _items.putIfAbsent(
            productId,
            () => CartItem(
                id: json.decode(respond.body)["name"],
                title: title,
                price: price,
                quantity: 1));
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    } else {
      try {
        cartId = _items[productId]!.id!;
        var url1 = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
            "/carts/$userId/$cartId.json", {"auth": authToken});
        var itemQuantity = getQuantity(productId) + 1;
        await http.patch(url1,
            body: json.encode({
              "quantity": itemQuantity,
            }));
        _items.update(
            productId,
            (oldItem) => CartItem(
                id: oldItem.id,
                price: oldItem.price,
                title: oldItem.title,
                quantity: oldItem.quantity! + 1));
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  int get packageCount {
    return _items.length;
  }

  int get itemCount {
    var totalItem = 0;
    _items.forEach((key, cartValue) {
      totalItem += cartValue.quantity!;
    });
    return totalItem;
  }

  double get cartPrice {
    var totalPrice = 0.0;
    _items.forEach((key, cartValue) {
      totalPrice += (cartValue.price! * cartValue.quantity!);
    });
    return totalPrice;
  }

  Future<void> removeItem(String productId) async {
    cartId = _items[productId]!.id!;
    try {
      var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/carts/$userId/$cartId.json", {"auth": authToken});
      final respond = await http.delete(url);
      _items.remove(productId);
      notifyListeners();
      if (respond.statusCode >= 400) {
        throw HttpException;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> removeSingleItem(String productId) async {
    cartId = _items[productId]!.id!;
    if (!_items.containsKey(productId)) {
      //this is will make the code below return inactive
      return;
    }

    if (_items[productId]!.quantity! > 1) {
      final itemQuantity = getQuantity(productId);
      try {
        var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
            "/carts/$userId/$cartId.json", {"auth": authToken});
        final respond = await http.patch(url,
            body: json.encode({"quantity": itemQuantity - 1}));
        //update the quantity
        _items.update(
            productId,
            (oldItem) => CartItem(
                id: oldItem.id,
                price: oldItem.price,
                title: oldItem.title,
                quantity: oldItem.quantity! - 1));
        notifyListeners();
        if (respond.statusCode >= 400) {
          throw HttpException;
        }
      } catch (error) {
        rethrow;
      }
    } else {
      try {
        var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
            "/carts/$userId/$cartId.json", {"auth": authToken});
        final respond = await http.delete(url);
        //remove the item from the cart
        _items.remove(productId);
        notifyListeners();
        if (respond.statusCode >= 400) {
          throw HttpException;
        }
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> addSingleItem(String productId) async {
    cartId = _items[productId]!.id!;
    if (!_items.containsKey(productId)) {
      //this is will make the code below return inactive
      return;
    }
    final itemQuantity = getQuantity(productId);
    try {
      var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/carts/$userId/$cartId.json", {"auth": authToken});
      final respond = await http.patch(url,
          body: json.encode({"quantity": itemQuantity + 1}));
      //update the quantity
      _items.update(
          productId,
          (oldItem) => CartItem(
              id: oldItem.id,
              price: oldItem.price,
              title: oldItem.title,
              quantity: oldItem.quantity! + 1));
      notifyListeners();
      if (respond.statusCode >= 400) {
        throw HttpException;
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetCart() async {
    Map<String, CartItem> _newCartData = {};
    try {
      var url = Uri.https("ese-server-db-default-rtdb.firebaseio.com",
          "/carts/$userId.json", {"auth": authToken});
      final repond = await http.get(url);

      var _extractedData = json.decode(repond.body);

      if (_extractedData == null) {
        return;
      }

      _extractedData = _extractedData as Map<String?, dynamic>;
      _extractedData.forEach((key, content) {
        _newCartData.putIfAbsent(
            content["productId"],
            () => CartItem(
                id: key,
                price: content["price"] as double?,
                title: content["title"],
                quantity: content["quantity"]));
        //cartId = key;
      });
      _items = _newCartData;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      var url = Uri.https(
          "ese-server-db-default-rtdb.firebaseio.com", "/carts/$userId.json", {
        "auth": authToken,
      });
      final respond = await http.delete(url);
      _items = {};
      notifyListeners();
      if (respond.statusCode >= 400) {
        throw HttpException;
      }
    } catch (error) {
      rethrow;
    }
  }

  //   String setDeliveryStatus() {
  //   if (deliveryStatus == DeliveryStatus.Pending) {
  //     return "Pending";
  //   } else if (deliveryStatus == DeliveryStatus.InDelivery) {
  //     return "item in delivery";
  //   } else if (deliveryStatus == DeliveryStatus.Confirm) {
  //     return "Order Confirmed";
  //   } else if (deliveryStatus == DeliveryStatus.Delivered) {
  //     return "Delivered";
  //   } else if (deliveryStatus == DeliveryStatus.Cancelled) {
  //     return "order is cancelled";
  //   }

  //   return null;
  // }

}
