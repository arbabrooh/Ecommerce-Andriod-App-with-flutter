import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/product_provider.dart";
import "../providers/cart_provider.dart";
import "../widgets/badge.dart";
import "./cart_screen.dart";
import "../providers/auth_provider.dart";
import "./auth_screen.dart";

class ProductDetails extends StatelessWidget {
  const ProductDetails({Key? key}) : super(key: key);
  static const routeName = "/product_details";

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    //final authRef = Provider.of<AuthProvider>(context, listen: false);
    //modalRoute use to get the data passed via product_item
    final productId = ModalRoute.of(context)!.settings.arguments as String;
    final currentProduct =
        Provider.of<ProductProvider>(context).findById(productId);
    final mediaQuery = MediaQuery.of(context);
    final contentHeight = mediaQuery.size.height;
    final theme = Theme.of(context);

    return Scaffold(
      // appBar: AppBar(title: Text(currentProduct.title),
      //     //icon button that has a provider to take us to the cartScreen and also let us see how many in the cart already
      //     actions: [
      //       Consumer<Cart>(
      //           builder: (_, cartClass, consChild) {
      //             return Badge(value: cartClass.itemCount.toString(), child: consChild);
      //           },
      //           child: IconButton(
      //               icon: Icon(Icons.shopping_cart),
      //               onPressed: () {
      //                 // if (authRef.isAuth) {
      //                 Navigator.of(context).pushNamed(
      //                   CartScreen.routeName,
      //                 );
      //                 // } else {
      //                 //   Navigator.of(context).pushNamed(AuthScreen.routeName);
      //                 // }
      //               })),
      //     ]),
      body: CustomScrollView(slivers: [
        SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            actions: [
              Consumer<Cart>(
                  builder: (_, cartClass, consChild) {
                    return Badge(
                        value: cartClass.itemCount.toString(),
                        child: consChild!);
                  },
                  child: IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        // if (authRef.isAuth) {
                        Navigator.of(context).pushNamed(
                          CartScreen.routeName,
                        );
                        // } else {
                        //   Navigator.of(context).pushNamed(AuthScreen.routeName);
                        // }
                      })),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                  color: Colors.black54,
                  child: Text(currentProduct.title!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      //overflow ensure that if the text is too long, it will fade out
                      overflow: TextOverflow.fade)),
              background: Container(
                  child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Hero(
                  tag: currentProduct.id!,
                  child: Image.network(currentProduct.imageUrl!,
                      height:
                          (contentHeight - AppBar().preferredSize.height) * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              )),
            )),
        SliverList(
            delegate: SliverChildListDelegate(
          [
            SizedBox(height: contentHeight * 0.03),
            Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.primaryColor),
                width: mediaQuery.size.width * 0.7,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("PRICE: ₦${currentProduct.price}",
                          style: const TextStyle(color: Colors.white)),
                      TextButton(
                          child: Text("ADD To Cart",
                              style: TextStyle(
                                  color: theme.colorScheme.secondary)),
                          onPressed: () => cartData.addItem(currentProduct.id!,
                              currentProduct.price!, currentProduct.title!))
                    ])),
            SizedBox(height: contentHeight * 0.02),
            Card(
                child: Column(children: [
              const Text("Description",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.orange)),
              Text(currentProduct.description!)
            ])),
            const SizedBox(height: 500),
          ],
        )),
      ]),

      // Card(
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //     child: Column(children: [
      //       Stack(children: [
      //         Container(
      //             child: ClipRRect(
      //           borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      //           child: Hero(
      //             tag: currentProduct.id,
      //             child: Image.network(currentProduct.imageUrl, height: (contentHeight - AppBar().preferredSize.height) * 0.6, width: double.infinity, fit: BoxFit.cover),
      //           ),
      //         )),
      //         Positioned(
      //             bottom: 20,
      //             right: 15,
      //             child: Container(
      //                 color: Colors.black54,
      //                 child: Text(currentProduct.title,
      //                     style: TextStyle(
      //                       fontSize: 15,
      //                       color: Colors.white,
      //                     ),
      //                     softWrap: true,
      //                     //overflow ensure that if the text is too long, it will fade out
      //                     overflow: TextOverflow.fade)))
      //       ]),
      //       SizedBox(height: contentHeight * 0.03),
      //       Chip(
      //           backgroundColor: theme.primaryColor,
      //           label: Container(
      //               width: mediaQuery.size.width * 0.7,
      //               child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      //                 Text("PRICE: ₦${currentProduct.price}", style: TextStyle(color: Colors.white)),
      //                 FlatButton.icon(
      //                     color: Colors.white,
      //                     icon: Icon(
      //                       Icons.shopping_cart,
      //                       color: theme.accentColor,
      //                     ),
      //                     label: Text("ADD To Cart", style: TextStyle(color: theme.accentColor)),
      //                     onPressed: () => cartData.addItem(currentProduct.id, currentProduct.price, currentProduct.title))
      //               ]))),
      //       SizedBox(height: contentHeight * 0.02),
      //       Card(
      //           child: Column(children: [
      //         Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.orange)),
      //         Text(currentProduct.description)
      //       ])), ]))
    );
  }
}
