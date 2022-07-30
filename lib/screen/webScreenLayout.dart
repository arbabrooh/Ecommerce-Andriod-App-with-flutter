import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_project/providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

import '../helpers/searching.dart';
import '../models/product_model.dart';
import '../private.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_gridview.dart';
import '../widgets/sideNavBar.dart';
import 'cart_screen.dart';
import '../widgets/main_drawer.dart';
import 'manage_order_screen.dart';
import 'manage_product_screen.dart';
import 'orders_screen.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({Key? key}) : super(key: key);

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  var _isFavourite = false;
  var _isLoading = true;
  var _isHairs = false;
  var _isShoes = false;
  var _isClothings = false;
  var _isBag = false;
  final _allProductKey = GlobalKey();
  final _shoeProductkey = GlobalKey();
  final _hairProductkey = GlobalKey();
  final _clothProductkey = GlobalKey();
  final _bagProductkey = GlobalKey();
  List<ProductModel>? _bagProducts = [];
  List<ProductModel>? _clothingProducts = [];
  List<ProductModel>? _hairProducts = [];
  List<ProductModel>? _shoeProducts = [];
  int _screenIndex = 0;
  late PageController pageController;

  void pageChanger(int page) {
    setState(() {
      _screenIndex = page;
    });
  }

  void navigationTapper(int page) {
    setState(() {
      _screenIndex = page;
    });
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
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context, listen: false);

    _bagProducts = productsData.bagProducts();
    _clothingProducts = productsData.clothingProducts();
    _hairProducts = productsData.hairProducts();
    _shoeProducts = productsData.shoeProducts();
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        drawer: deviceSize.width > 600 ? null : AppDrawer(),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  context.push("/");
                },
                child: Text(
                  "Ese Shop",
                  style: TextStyle(
                      fontSize:
                          deviceSize.width > 800 ? deviceSize.width / 50 : 30,
                      color: Colors.yellowAccent),
                ),
              ),
              SizedBox(
                width: deviceSize.width * 0.05,
              ),
              InkWell(
                onTap: () {
                  navigationTapper(1);
                },
                child: Text("Hairs",
                    style: TextStyle(
                      fontSize:
                          deviceSize.width > 800 ? deviceSize.width / 60 : 14,
                    )),
                focusColor: Colors.yellowAccent,
              ),
              InkWell(
                onTap: () {
                  navigationTapper(2);
                },
                child: Text("Bags",
                    style: TextStyle(
                      fontSize:
                          deviceSize.width > 800 ? deviceSize.width / 60 : 14,
                    )),
                focusColor: Colors.yellowAccent,
              ),
              InkWell(
                  onTap: () {
                    navigationTapper(3);
                  },
                  child: Text("Clothings",
                      style: TextStyle(
                        fontSize:
                            deviceSize.width > 800 ? deviceSize.width / 60 : 14,
                      )),
                  focusColor: Colors.yellowAccent),
              InkWell(
                  onTap: () {
                    navigationTapper(4);
                  },
                  child: Text("Shoes",
                      style: TextStyle(
                        fontSize:
                            deviceSize.width > 800 ? deviceSize.width / 60 : 14,
                      )),
                  focusColor: Colors.yellowAccent),
              SizedBox(
                width: deviceSize.width * 0.05,
              )
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                      context: context, delegate: ProductSearch(_isFavourite));
                }),
            IconButton(
                onPressed: () {
                  if (_isFavourite) {
                    setState(() {
                      _isFavourite = false;
                    });
                  } else {
                    setState(() {
                      _isFavourite = true;
                    });
                  }
                },
                icon: _isFavourite
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border)),
            Consumer<Cart>(
              builder: (_, cartData, consumerChild) {
                return Badge(
                  position: BadgePosition.topEnd(top: -2, end: -8),
                  badgeContent: Text(cartData.itemCount.toString()),
                  child: consumerChild,
                );
              },
              child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    context.push(CartScreen.routeName);
                  }),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body: Row(
          children: [
            SideNavBar(),
            Container(
              width: deviceSize.width * 0.8,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(
                      children: [
                        ProductGridView(_allProductKey, _isFavourite),
                        ProductGridView(
                            _hairProductkey, _isFavourite, _hairProducts),
                        ProductGridView(
                            _bagProductkey, _isFavourite, _bagProducts),
                        ProductGridView(
                            _clothProductkey, _isFavourite, _clothingProducts),
                        ProductGridView(
                            _shoeProductkey, _isFavourite, _shoeProducts),
                      ],
                      onPageChanged: pageChanger,
                      controller: pageController,
                    ),
              //  _isHairs
              //     ? ProductGridView(
              //         GlobalKey(), _isFavourite, _hairProducts)
              //     : _isShoes
              //         ? ProductGridView(
              //             GlobalKey(), _isFavourite, _shoeProducts)
              //         : _isClothings
              //             ? ProductGridView(
              //                 GlobalKey(), _isFavourite, _clothingProducts)
              //             : _isBag
              //                 ? ProductGridView(
              //                     GlobalKey(), _isFavourite, _bagProducts)
              //                 : ProductGridView(GlobalKey(), _isFavourite),
            )
          ],
        ));
  }
}
