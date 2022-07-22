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
  List<ProductModel> _bagProducts = [];
  List<ProductModel> _clothingProducts = [];
  List<ProductModel> _hairProducts = [];
  List<ProductModel> _shoeProducts = [];

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProduct()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
      final productsData = Provider.of<ProductProvider>(context, listen: false);
      _bagProducts = productsData.bagProducts();
      _clothingProducts = productsData.clothingProducts();
      _hairProducts = productsData.hairProducts();
      _shoeProducts = productsData.shoeProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        drawer: AppDrawer(),
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
                  if (_isHairs) {
                    setState(() {
                      _isHairs = false;
                    });
                  } else {
                    setState(() {
                      _isHairs = true;
                    });
                  }
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
                  if (_isBag) {
                    setState(() {
                      _isBag = false;
                    });
                  } else {
                    setState(() {
                      _isBag = true;
                    });
                  }
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
                    if (_isClothings) {
                      setState(() {
                        _isClothings = false;
                      });
                    } else {
                      setState(() {
                        _isClothings = true;
                      });
                    }
                  },
                  child: Text("Clothings",
                      style: TextStyle(
                        fontSize:
                            deviceSize.width > 800 ? deviceSize.width / 60 : 14,
                      )),
                  focusColor: Colors.yellowAccent),
              InkWell(
                  onTap: () {
                    if (_isShoes) {
                      setState(() {
                        _isShoes = false;
                      });
                    } else {
                      setState(() {
                        _isShoes = true;
                      });
                    }
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
                  : _isHairs
                      ? ProductGridView(_isFavourite, _hairProducts)
                      : _isShoes
                          ? ProductGridView(_isFavourite, _shoeProducts)
                          : _isClothings
                              ? ProductGridView(_isFavourite, _clothingProducts)
                              : _isBag
                                  ? ProductGridView(_isFavourite, _bagProducts)
                                  : ProductGridView(_isFavourite),
            )
          ],
        ));
  }
}
