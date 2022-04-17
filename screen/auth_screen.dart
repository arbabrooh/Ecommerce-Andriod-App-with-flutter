import 'dart:developer';

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/auth_provider.dart";
import "../models/exception_model.dart";

enum AuthMode { signup, login, passwordReset }

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = "/authScreen";

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(children: [
      Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
        Color.fromRGBO(165, 115, 222, 0.9),
        Color.fromRGBO(161, 153, 6, 0.2),
      ], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      SingleChildScrollView(
          child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        child: Container(
                            margin: const EdgeInsets.all(25),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 80.0),
                            child: const Text("ESE FASHION",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white30,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                  )
                                ]))),
                    Flexible(
                      flex: deviceSize.width > 600 ? 2 : 1,
                      child: const AuthItem(),
                    ),
                  ]))),
      //.....authwidget
    ]));
  }
}

class AuthItem extends StatefulWidget {
  const AuthItem({Key? key}) : super(key: key);

  @override
  _AuthItemState createState() => _AuthItemState();
}

class _AuthItemState extends State<AuthItem>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin is Tickerprovider, it Provides a single [Ticker] that is configured to only tick while the current tree is enabled, as defined by [TickerMode].
  final GlobalKey<FormState> _formKey =
      GlobalKey(); // a key to link with the form
  AuthMode _authMode = AuthMode.login;

  Map<String, String> _authData = {
    // a helper Map where the Data collected from user will be kept
    'email': '',
    'password': '',
  };

  var _isLoading = false;
  final _passwordController =
      TextEditingController(); //to hold the text from the form

//every flutter animation needs at least 1. An animation controller as parent 2. an animation object tied to a tween to generate value for animation
  late AnimationController
      _animeController; //Note the controller must also be disposed
  late Animation<Size> _animeHeightController; //size cont
  late Animation<Offset>
      _animeSlideController; //offset extends the offsetBase class that helps to create a slide Transition
  late Animation<double> _opacityAnimationObject;

  @override
  void initState() {
    super.initState();
    _animeController = AnimationController(
        vsync: this,
        duration: const Duration(
            milliseconds:
                400)); //Creates an animation controller..duration and vsync is required, vsync must take a tickerProvider class.. //
    //giving vsync means it points to the current StateObject which ofcourse must mix with a TickerProvider

    _opacityAnimationObject = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animeController, curve: Curves.easeIn));
    _animeSlideController = Tween<Offset>(
            begin: const Offset(0, -1.5), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _animeController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _animeController.dispose(); //disposing the controller to avoid memory leaks
  }

  void _displayDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
              title: const Text("Error Occurred"),
              content: Text(message),
              actions: [
                TextButton(
                    child: const Text("OKAY"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      //to ensure validation of the form
      // Invalid!
      return;
    }

    _formKey.currentState?.save(); //to save the current state/data of the form
    setState(() {
      _isLoading = true;
    });

    // print(_authData["email"]);
    // print(_authData["password"]);

    try {
      if (_authMode == AuthMode.login) {
        // Log user in
        await Provider.of<AuthProvider>(context, listen: false)
            .signIn(_authData["email"]!, _authData["password"]!);
        // print(_authData["email"]);
        // print(_authData["password"]);
      } else if (_authMode == AuthMode.passwordReset) {
        // log("inside reset password");
        try {
          await Provider.of<AuthProvider>(context, listen: false)
              .passwordReset(_authData["email"]!);

          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  content: const Text("Check your Email"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _switchAuthMode();
                        },
                        child: const Text("OKAY"))
                  ],
                );
              });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Error occur"),
            action: SnackBarAction(label: "Okay", onPressed: _switchAuthMode),
          ));
        }
      } else {
        Provider.of<AuthProvider>(context, listen: false)
            .signUp(_authData["email"]!, _authData["password"]!);
      }
    } on HttpException catch (error) {
      var errorMessage = "Authetication failed";
      if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "please input a valid password";
      } else if (error.toString().contains("EMAIL_EXIST")) {
        errorMessage = "email already exist";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "email is not found";
      }
      _displayDialog(errorMessage);
    } catch (error) {
      const errorMessage = "Could not Authenticate you, please try again";
      _displayDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _animeController
          .forward(); //use to activate the controller to start running forwar
    } else if (_authMode == AuthMode.passwordReset) {
      setState(() {
        _authMode = AuthMode.login;
      });
      //_animeController.r(); //use to activate the controller to start running backward
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animeController
          .reverse(); //use to activate the controller to start running backward
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        //buitin animated container widget in flutter.  it gradualy changes it size over a period of time
        duration: const Duration(
            milliseconds: 400), //determines how long the animation will take
        curve: Curves.easeIn,
        height: _authMode == AuthMode.signup
            ? 320
            : _authMode == AuthMode.passwordReset
                ? 100
                : 300,
        constraints: //Creates a widget that combines common painting, positioning, and sizing widgets.
//        The color and decoration arguments cannot both be supplied, since it would potentially result in the decoration drawing over the background color. To supply a decoration with a color, use decoration: BoxDecoration(color: color).
            BoxConstraints(
                minHeight: _authMode == AuthMode.signup
                    ? 320
                    : _authMode == AuthMode.passwordReset
                        ? 190
                        : 300),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty ||
                        !value.contains('@') ||
                        !value.contains(".")) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                if ((_authMode == AuthMode.login) ||
                    (_authMode == AuthMode.signup))
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: ((_authMode == AuthMode.login) ||
                                (_authMode == AuthMode.signup))
                            ? 70
                            : 0,
                        maxHeight: (_authMode == AuthMode.login ||
                                _authMode == AuthMode.signup)
                            ? 130
                            : 0),
                    child: TextFormField(
                      enabled: ((_authMode == AuthMode.login) ||
                          (_authMode == AuthMode.signup)),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true, // asterisk the password
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return 'Password is too short!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _authData['password'] = value!;
                      },
                    ),
                  ),
                // if (_authMode == AuthMode.Signup)
                AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve:
                        Curves.easeIn, //note a duration and curve is required
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.signup ? 70 : 0,
                        maxHeight: _authMode == AuthMode.signup ? 130 : 0),
                    child: FadeTransition(
                        //create an opacity transition.. requires a child and opacity.
                        opacity:
                            _opacityAnimationObject, //takes an Animation Object
                        //Note animationController start be forwarded and reverse
                        child: SlideTransition(
                            //make the widget slide in or out
                            position:
                                _animeSlideController, //requires a Animation object
                            child: TextFormField(
                              enabled: _authMode ==
                                  AuthMode
                                      .signup, //will activate only when AuthMode.signup is true
                              decoration: const InputDecoration(
                                  labelText: 'Confirm Password'),
                              obscureText: true,
                              validator: _authMode == AuthMode.signup
                                  ? (value) {
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match!';
                                      }
                                    }
                                  : null,
                            )))),
                const SizedBox(
                  height: 12,
                ),
                (_isLoading)
                    ? const CircularProgressIndicator()
                    : RaisedButton(
                        child: Text(_authMode == AuthMode.login
                            ? 'LOGIN'
                            : _authMode == AuthMode.passwordReset
                                ? "SUBMIT"
                                : 'SIGN UP'),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button!.color,
                      ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve:
                        Curves.easeIn, //note a duration and curve is required
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.login ? 30 : 0,
                        maxHeight: _authMode == AuthMode.login ? 130 : 0),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            _authMode = AuthMode.passwordReset;
                          });
                        },
                        child: const Text("Forget password",
                            style: TextStyle(color: Colors.red)))),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: theme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
