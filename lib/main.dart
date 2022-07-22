import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_project/private.dart';

import "./screen/products_overview_screen.dart";
import "./screen/product_details.dart";
import "./providers/product_provider.dart";
import "./providers/cart_provider.dart";
import "./screen/cart_screen.dart";
import "./providers/order_provider.dart";
import "./screen/orders_screen.dart";
import "./screen/manage_product_screen.dart";
import "./screen/addItem.dart";
import "./screen/delivery_details_screen.dart";
import "./screen/manage_order_screen.dart";
import './screen/auth_screen.dart';
import "./providers/auth_provider.dart";
import "./widgets/splashscreen.dart";
import './screen/reponsiveScreen.dart';
import 'screen/mobileScreenLayout.dart';
import 'screen/webScreenLayout.dart';

//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //neccessary for smooth initialization of firebase
  if (kIsWeb) {
    //kIsWeb returns true if it was compile to run on web
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: apikey,
      appId: appId,
      messagingSenderId: msgSenderId,
      projectId: projectId,
      storageBucket: storageBucketName,
    ));
  } else {
    await Firebase
        .initializeApp(); //options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(MyApp());

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // multiProvider is use to capture multi providers
    return MultiProvider(
      providers: [
        //ChangeNotifierProvider link the provider to the root widget for any widget listening
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(" ", [], " "), //null,
          update: (ctx, authData, previousProductData) => ProductProvider(
              authData.token,
              previousProductData == null ? [] : previousProductData.items,
              authData.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, Cart>(
          create: (_) => Cart(" ", {}, " "),
          update: (ctx, authData, previouscartData) => Cart(
              authData.token,
              previouscartData == null ? {} : previouscartData.items,
              authData.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(" ", [], [], " "),
          update: (ctx, authData, previousOrderData) => OrderProvider(
              authData.token,
              previousOrderData == null ? [] : previousOrderData.orders,
              previousOrderData == null ? [] : previousOrderData.allOrders,
              authData.userId),
        ),
      ],
      child: Consumer<AuthProvider>(builder: (ctx, authData, child) {
        //MaterialApp will be rebuild after every change to AuthProvider
        return MaterialApp.router(
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          debugShowCheckedModeBanner: false,
          // navigatorKey: navigatorKey,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.orangeAccent,
            fontFamily: "Lato",
          ),
        );
      }),
    );
  }

  final _router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            final authenData = Provider.of<AuthProvider>(context);
            return authenData.isAuth
                ? //const ProductsScreen()
                const ResponsiveScreen(
                    mobileScreenLayout: MobileScreen(),
                    webScreenLayout: WebScreen(),
                  )
                :
                //Future is use to active the onDeviceLogin since it a future and the futurebuilder will run everything build is run
                FutureBuilder(
                    future: authenData.onDeviceLogin(),
                    builder: (cxt, dataSnapShot) =>
                        (dataSnapShot.connectionState ==
                                ConnectionState.waiting)
                            ? SplashScreen()
                            : const AuthScreen());
          },
        ),
        GoRoute(
          path: AuthScreen.routeName,
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: ManageOrderScreen.routeName,
          builder: (context, state) => const ManageOrderScreen(),
        ),
        GoRoute(
          path: DeliveryScreen.routeName,
          builder: (context, state) => const DeliveryScreen(),
        ),
        GoRoute(
          path: ProductDetails.routeName,
          builder: (context, state) => ProductDetails(
            productId: state.extra! as String,
          ),
        ),
        GoRoute(
          path: CartScreen.routeName,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: OrdersScreen.routeName,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: ProductManagementScreen.routeName,
          builder: (context, state) => ProductManagementScreen(),
        ),
        GoRoute(
            path: AddItem.routeName,
            builder: (context, state) {
              return AddItem(
                navKey: GlobalKey(),
                productId: state.extra != null ? state.extra! as String : null,
              );
            })
      ],
      errorBuilder: (BuildContext context, GoRouterState state) {
        final authenData = Provider.of<AuthProvider>(context);
        return authenData.isAuth
            ? //const ProductsScreen()
            const ResponsiveScreen(
                mobileScreenLayout: MobileScreen(),
                webScreenLayout: WebScreen(),
              )
            :
            //Future is use to active the onDeviceLogin since it a future and the futurebuilder will run everything build is run
            FutureBuilder(
                future: authenData.onDeviceLogin(),
                builder: (cxt, dataSnapShot) =>
                    (dataSnapShot.connectionState == ConnectionState.waiting)
                        ? SplashScreen()
                        : const AuthScreen());
      });
}
