import "dart:convert";

import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import "package:http/http.dart" as http;
//import "package:provider/provider.dart";

import "./cart_provider.dart";

class OrderItem {
  final String? id;
  final String? orderNo;
  final double? totalPrice;
  final List<CartItem>? products;
  final DateTime? orderDate;
  final String? customerLastName;
  final String? customerFirstName;
  final String? customerPhoneNo;
  final String? customerAddress;

  OrderItem(
      {@required this.orderNo,
      @required this.id,
      @required this.totalPrice,
      @required this.products,
      @required this.orderDate,
      @required this.customerFirstName,
      @required this.customerPhoneNo,
      @required this.customerAddress,
      @required this.customerLastName});
}

class OrderProvider with ChangeNotifier {
  var _trnId = 10000;
  var _trckId = "";

  final String? authToken;
  final String? userId;
  List<OrderItem> _orders = [];
  List<OrderItem> _allOrders = [];
  OrderProvider(this.authToken, this._orders, this._allOrders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  List<OrderItem> get allOrders {
    return [..._allOrders];
  }

  set setTrckId(String _idString) {
    _trckId = _idString;
  }

  String get getTrckId {
    return _trckId;
  }

  String setAndGetTrckId() {
    _trnId += 1;
    setTrckId = _trnId.toString();
    return getTrckId;
  }

  Future<void> addOrders(
      {List<CartItem>? cartContent,
      double? total,
      String? lastName,
      String? firstName,
      String? address,
      String? phoneNo}) async {
    final timeInstance = DateTime.now();
    final orderNoInstance = setAndGetTrckId();
    try {
      var url = Uri.https(
          "ese-server-db-default-rtdb.firebaseio.com", "/orders/$userId.json", {
        "auth": authToken,
      });

      final respond = await http.post(url,
          body: json.encode({
            "userId": userId,
            "totalPrice": total,
            "orderDate": timeInstance.toIso8601String(),
            "orderNo": orderNoInstance,
            "customerLastName": lastName,
            "customerAddress": address,
            "customerFirstName": firstName,
            "customerPhoneNo": phoneNo,
            "products": cartContent!.map((product) {
              return {
                "price": product.price,
                "title": product.title,
                "quantity": product.quantity,
                "id": product.id,
              };
            }).toList(),
          }));

      _orders.insert(
          0,
          OrderItem(
              orderNo: orderNoInstance,
              id: json.decode(respond.body)["name"],
              customerAddress: address,
              customerLastName: lastName,
              customerFirstName: firstName,
              customerPhoneNo: phoneNo,
              totalPrice: total,
              products: cartContent,
              orderDate: timeInstance));
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetOrders() async {
    List<OrderItem> newOrder = [];
    try {
      var url = Uri.https(
          "ese-server-db-default-rtdb.firebaseio.com", "/orders/$userId.json", {
        "auth": authToken,
      });
      final respond = await http.get(url);
      final _extractedData = json.decode(respond.body) as Map<String, dynamic>;
      // if (_extractedData == null) {
      //   return;
      // }
      //id is the map key... data is the value
      _extractedData.forEach((id, data) {
        newOrder.insert(
            0,
            OrderItem(
              customerFirstName: data["customerFirstName"],
              customerPhoneNo: data["customerPhoneNo"],
              customerAddress: data["customerAddress"],
              customerLastName: data["customerLastName"],
              id: json.decode(respond.body)["name"],
              orderDate: DateTime.parse(data["orderDate"]),
              orderNo: data["orderNo"],
              totalPrice: data["totalPrice"],
              products: (data["products"] as List<dynamic>).map((item) {
                return CartItem(
                    price: item["price"],
                    quantity: item["quantity"],
                    title: item["title"],
                    id: item["id"]);
              }).toList(),
            ));
      });
      //reversed.toList() is use to change newOrder in a reversed order and then to a list
      _orders = newOrder.reversed.toList();
      notifyListeners();
    } catch (error) {
      //print(error);
      rethrow;
    }
  }

  Future<void> fechAllOrders() async {
    List<OrderItem> newOrder = [];

    try {
      var url = Uri.https(
          "ese-server-db-default-rtdb.firebaseio.com", "/orders.json", {
        "auth": authToken,
      });
      final respond = await http.get(url);
      final _extractedData = json.decode(respond.body) as Map<String, dynamic>;
      // if (_extractedData == null) {
      //   return;
      // }

      //id is the map key... data is the value
      final _extractList = _extractedData.values.toList();

      for (var element in _extractList) {
        final items = element as Map<String, dynamic>;
        final itxs = items.values.toList();
        for (var item in itxs) {
          newOrder.insert(
              0,
              OrderItem(
                  customerLastName: item["customerLastName"],
                  customerFirstName: item["customerFirstName"],
                  customerAddress: item["customerAddress"],
                  customerPhoneNo: item["customerPhoneNo"],
                  orderNo: item["orderNo"],
                  orderDate: DateTime.parse(item["orderDate"]),
                  totalPrice: item["totalPrice"],
                  products: (item["products"] as List<dynamic>).map((item) {
                    return CartItem(
                        price: (item["price"].toDouble()),
                        quantity: item["quantity"],
                        title: item["title"],
                        id: item["id"]);
                  }).toList(),
                  id: item["orderNo"]));
        }
      }
      //reversed.toList() is use to change newOrder in a reversed order and then to a list
      _allOrders = newOrder.reversed.toList();
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }
}
