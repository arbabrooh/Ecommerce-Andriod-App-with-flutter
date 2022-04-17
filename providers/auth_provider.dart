import "dart:convert";
import "dart:async";
import 'dart:developer';

import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

import "../models/exception_model.dart";
import "../private.dart";

class AuthProvider with ChangeNotifier {
  String? _token = "";
  String? _userId;
  String? _userEmail;
  DateTime? _tokenExpiryDate;
  Timer? _authTimer;

  final _apiKey = AuthApi.apiKey;

  String? get userId {
    return _userId;
  }

  Future<void> authenticated(
      String email, String password, String option) async {
    const urlName = "https://identitytoolkit.googleapis.com/v1/accounts";
    try {
      // var url = Uri.https(
      //     "identitytoolkit.googleapis.com", "/v1/accounts:signUp?key=$_apiKey");
      var url = Uri.parse("$urlName:$option?key=$_apiKey");
      final response = await http.post(url,
          body: (json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          })));
      final responseData = json.decode(response.body);
      //print(responseData["idToken"]);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      //if there's no error.
      _token = responseData["idToken"];
      // print(_token);
      _userId = responseData["localId"];
      _userEmail = responseData["email"];
      _tokenExpiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      _autoLogOut(); //autoLogout called after login....

      notifyListeners(); //add the expiresTime to the current time

      //save client login data on the device so he can login next time automatically
      final pref =
          await SharedPreferences.getInstance(); //Obtain shared preferences.
      final userLoginData = json.encode({
        //data encoded in json format
        "token": _token,
        "userId": _userId,
        "tokenExpiryDate": _tokenExpiryDate!
            .toIso8601String(), //to ensure date can be converted back to data format with compromise
        "userEmail": _userEmail,
      });
      pref.setString("loginData",
          userLoginData); //save the userloginData on device with a key loginData

    } catch (error) {
      rethrow;
    }
  }

  Future<bool> onDeviceLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("loginData")) {
      return false;
    }

    final dataExtracted =
        json.decode(prefs.getString("loginData")!) as Map<String, dynamic>;
    final tokenExpiryDate = DateTime.parse(dataExtracted[
        "tokenExpiryDate"]); //dataExtracted["tokenExpiryDate"] converted back to a Date object

    if (tokenExpiryDate.isBefore(DateTime.now())) {
      //check if token is expired
      return false;
    }
    //else
    _token = dataExtracted["token"];
    _userId = dataExtracted["userId"];
    _tokenExpiryDate = tokenExpiryDate;
    _userEmail = dataExtracted["userEmail"];

    notifyListeners();
    _autoLogOut();
    return true;
  }

  String? get token {
    if (_token != null &&
        _tokenExpiryDate != null &&
        _tokenExpiryDate!.isAfter(DateTime.now())) {
      return _token!;
    }
    return null;
  }

  bool get isAuth {
    if (token != null) {
      return true;
    }
    return false; //return true if token is not null
  }

  String get emailAdress {
    return _userEmail!;
  }

  Future<void> signUp(String email, String password) async {
    return authenticated(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    // final String option = "signInWithPassword";
    // var url = Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:$option?key=$_apiKey");
    // print("inside signIn");
    // print(email);
    // print(password);
    // final response = await Http.post(url,
    //     body: (json.encode({
    //       "email": email,
    //       "password": password,
    //       "returnSecureToken": true,
    //     })));
    // final responseData = json.decode(response.body);
    // print(responseData["idToken"]);

    //var url = Uri.https("identitytoolkit.googleapis.com", "/v1/accounts:signUp?key=$apiKey");

    return authenticated(email, password, "signInWithPassword");
  }

  Future<void> logOut() async {
    _token = null;
    _tokenExpiryDate = null;
    _userId = null;
    _userEmail = null;

    if (_authTimer != null) {
      // to cancel the existing timer before setting a new one.
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final pref =
        await SharedPreferences.getInstance(); //Obtain shared preferences.
    pref.remove("loginData");
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      // to cancel the existing timer before setting a new one.
      _authTimer!.cancel();
    }
    final timeDifference =
        _tokenExpiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeDifference),
        logOut); //the Timer takes a Duration object and a callback function... the callback function is invoke after the given duration
  }

  Future<void> passwordReset(String email) async {
    try {
      var url = Uri.parse(
          "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey");
      final response = await http.post(
        url,
        body: json.encode({
          "requestType": "PASSWORD_RESET",
          "email": email,
        }),
      );
      //log(response.body);
    } catch (e) {
      rethrow;
    }
  }
}
