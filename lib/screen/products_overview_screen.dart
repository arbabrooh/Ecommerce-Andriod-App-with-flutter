import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../helpers/searching.dart';
import '../models/product_model.dart';
import "../widgets/product_gridview.dart";
import "../widgets/badge.dart";
import "../providers/cart_provider.dart";
import "../providers/product_provider.dart";
import "./cart_screen.dart";
import "../widgets/main_drawer.dart";
// import "../providers/auth_provider.dart";
// import "./auth_screen.dart";

enum FavFilters {
  favourite,
  all,
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);
  @override
  _ProductsScreenState createState() {
    return _ProductsScreenState();
  }
}

class _ProductsScreenState extends State<ProductsScreen> {
  var _isLoading = false;
  // var _initRun = false;

  List<Map<String, Object>> _screenList = [];

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    // Future<void> init()async{

    //try {
    Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProduct()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    }).then((_) {
      final productsData = Provider.of<ProductProvider>(context, listen: false);
      List<ProductModel> _bagProducts = productsData.bagProducts();
      List<ProductModel> _clothingProducts = productsData.clothingProducts();
      List<ProductModel> _hairProducts = productsData.hairProducts();
      List<ProductModel> _shoeProducts = productsData.shoeProducts();

      _screenList = [
        {"screen": ProductGridView(_isFavourite), "title": "AllProduct"},
        {
          "screen": ProductGridView(_isFavourite, _bagProducts),
          "title": "Bags"
        },
        {
          "screen": ProductGridView(_isFavourite, _clothingProducts),
          "title": "Clothings"
        },
        {
          "screen": ProductGridView(_isFavourite, _hairProducts),
          "title": "Hairs"
        },
        {
          "screen": ProductGridView(_isFavourite, _shoeProducts),
          "title": "Shoes"
        },
      ];
    });

    ///....
    // } catch (error) {

    //   await showDialog(
    //       context: context,
    //       builder: (ctx) {
    //         return AlertDialog(title: Text("Hello!"), content: Text("An Error error. Try again"), actions: [
    //           TextButton(
    //               child: Text("Okay"),
    //               onPressed: () {
    //                 Navigator.of(ctx).pop(true);
    //               })
    //         ]);
    //       });
    // }

    // }

    super.initState();
  }

  int _screenIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _screenIndex = index;
    });
  }

  var _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    //final authRef = Provider.of<AuthProvider>(context, listen:false);

    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text("Ese Shop"), actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                    context: context, delegate: ProductSearch(_isFavourite));
              }),
          PopupMenuButton(
              //to create a popmenu on the screen
              onSelected: (selValue) {
                setState(() {
                  if (selValue == FavFilters.favourite) {
                    _isFavourite = true;
                  } else {
                    _isFavourite = false;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (ctx) => [
                    const PopupMenuItem(
                        child: Text("Show Favourite"),
                        value: FavFilters.favourite),
                    const PopupMenuItem(
                        child: Text("Show All"), value: FavFilters.all),
                  ]),
          Consumer<Cart>(
              builder: (_, cartClass, consChild) {
                return Badge(
                    value: cartClass.itemCount.toString(), child: consChild!);
              },
              child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    //if (authRef.isAuth) {
                    Navigator.of(context).pushNamed(
                      CartScreen.routeName,
                    );
                    // } else {
                    //   Navigator.of(context).pushNamed(AuthScreen.routeName);
                    // }
                  })),
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_screenList[_screenIndex]["screen"] as Widget),
        drawer: AppDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.primaryColor,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.amber,
          items: [
            BottomNavigationBarItem(
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.category),
                label: "Categories"),
            BottomNavigationBarItem(
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.shopping_bag),
                label: "Bags"),
            BottomNavigationBarItem(
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.checkroom),
                label: "Clothings"),
            BottomNavigationBarItem(
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.face_outlined),
                label: "Hairs"),
            BottomNavigationBarItem(
                backgroundColor: theme.primaryColor,
                icon: const Icon(Icons.local_mall),
                label: "Shoes"),
          ],
          onTap: _selectScreen,
          //currentIndex use to ensure flutter knows which we are while switching tab
          currentIndex: _screenIndex,
          //use to add shifting animation to our tab switching
          type: BottomNavigationBarType.shifting,
        ));
  }
}
