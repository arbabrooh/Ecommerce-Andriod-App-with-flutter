import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:firebase_core/firebase_core.dart';

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

//import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); //options: DefaultFirebaseOptions.currentPlatform);

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final navigatorKey = GlobalKey<NavigatorState>();
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
        return MaterialApp(
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.orangeAccent,
              fontFamily: "Lato",
            ),
            home: authData.isAuth
                ? const ProductsScreen()
                :
                //Future is use to active the onDeviceLogin since it a future and the futurebuilder will run everything build is run
                FutureBuilder(
                    future: authData.onDeviceLogin(),
                    builder: (cxt, dataSnapShot) =>
                        (dataSnapShot.connectionState ==
                                ConnectionState.waiting)
                            ? SplashScreen()
                            : const AuthScreen()),
            routes: {
              AuthScreen.routeName: (ctx) => const AuthScreen(),
              ManageOrderScreen.routeName: (ctx) => const ManageOrderScreen(),
              DeliveryScreen.routeName: (ctx) => const DeliveryScreen(),
              ProductDetails.routeName: (ctx) => const ProductDetails(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              ProductManagementScreen.routeName: (ctx) =>
                  const ProductManagementScreen(),
              AddItem.routeName: (ctx) => AddItem(navKey: navigatorKey),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (ctx) => const ProductsScreen(),
              ); /*_favouritePlayers*/
            });
      }),
    );
  }
}
