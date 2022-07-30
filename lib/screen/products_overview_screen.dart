import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:go_router/go_router.dart";

import '../helpers/searching.dart';
import '../models/product_model.dart';
import "../widgets/product_gridview.dart";
import "../widgets/badge.dart";
import "../providers/cart_provider.dart";
import "../providers/product_provider.dart";
import "./cart_screen.dart";
import "../widgets/main_drawer.dart";

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
  final _allProductKey = GlobalKey();
  final _shoeProductkey = GlobalKey();
  final _hairProductkey = GlobalKey();
  final _clothProductkey = GlobalKey();
  final _bagProductkey = GlobalKey();
  var _isLoading = false;
  int _screenIndex = 0;
  late PageController pageController;

  List<ProductModel>? _bagProducts;
  List<ProductModel>? _clothingProducts;
  List<ProductModel>? _hairProducts;
  List<ProductModel>? _shoeProducts;

  void pageChanger(int page) {
    setState(() {
      _screenIndex = page;
    });
  }

  void navigationTapper(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    pageController = PageController();
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProduct()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  var _isFavourite = false;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context, listen: false);
    _bagProducts = productsData.bagProducts();
    _clothingProducts = productsData.clothingProducts();
    _hairProducts = productsData.hairProducts();
    _shoeProducts = productsData.shoeProducts();
    //final authRef = Provider.of<AuthProvider>(context, listen:false);

    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size.width;
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
                    context.push(CartScreen.routeName);
                  })),
        ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PageView(
                children: [
                  ProductGridView(_allProductKey, _isFavourite),
                  ProductGridView(_bagProductkey, _isFavourite, _bagProducts),
                  ProductGridView(
                      _clothProductkey, _isFavourite, _clothingProducts),
                  ProductGridView(_hairProductkey, _isFavourite, _hairProducts),
                  ProductGridView(_shoeProductkey, _isFavourite, _shoeProducts),
                ],
                onPageChanged: pageChanger,
                controller: pageController,
              ),
        drawer: deviceSize > 600 ? null : AppDrawer(),
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
          onTap: navigationTapper,
          //currentIndex use to ensure flutter knows which we are while switching tab
          currentIndex: _screenIndex,
          //use to add shifting animation to our tab switching
          type: BottomNavigationBarType.shifting,
        ));
  }
}
