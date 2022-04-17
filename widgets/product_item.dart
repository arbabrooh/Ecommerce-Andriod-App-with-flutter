import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/product_model.dart";
import "../screen/product_details.dart";
import "../providers/cart_provider.dart";
import "../providers/auth_provider.dart";

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);
  // final String productId;
  // final String imageUrl;
  // final String productTitle;
  // final double productPrice;

  // ProductItem(@required this.productId, @required this.imageUrl, @required this.productTitle, @required this.productPrice);

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context);
    final deviceOrientation = MediaQuery.of(context).size;

    final product = Provider.of<ProductModel>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<AuthProvider>(context, listen: false);

    //ClipRRect use to give the image rounded edges and fit to it container
    return ClipRRect(
        borderRadius: BorderRadius.circular(deviceOrientation.height * 0.02),
        //just like a ListTile
        child: GridTile(
            child: InkWell(
              //use to make a widget clickable
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ProductDetails.routeName, arguments: product.id);
              },
              splashColor: themeColor.primaryColor,
              child: Hero(
                  // A widget that marks its child as being a candidate for hero animations.
                  tag: product.id
                      as String, //The identifier for this particular hero.
                  child: FadeInImage(
                      // a widget that provides a placeholder image while a network image is loading... requires a placeholder and an image argument
                      placeholder: const AssetImage(
                          "assets/images/cart_shopping.png"), //Fetches an image from an [AssetBundle]
                      image: NetworkImage(product.imageUrl as String),
                      fit: BoxFit.cover)),
            ),
            //GridTileBar use to create a container that will fit to the widget
            footer: GridTileBar(
                backgroundColor: Colors.black87,
                //consumer use to make part of a widget tree listen to changes instead of all the widget ....receives a context,generic type and a optional child.
                //the child argument is use to hold widget that wont change after a rebuild
                leading: Consumer<ProductModel>(builder: (ctx, product, child) {
                  //switching icons using product.isFavourite property
                  return IconButton(
                      icon: Icon(product.isFavourite
                          ? Icons.favorite
                          : Icons.favorite_border),
                      onPressed: () {
                        product.toggleFavourite(
                            authData.token as String, authData.userId);
                      },
                      color: themeColor.colorScheme.secondary);
                }),
                subtitle: Text(
                  "₦${product.price}",
                  style: const TextStyle(color: Colors.white),
                ),
                title: Text(
                  product.title as String,
                  style: TextStyle(
                      color: themeColor.colorScheme
                          .secondary), /*textAlign: TextAlign.center*/
                ),
                trailing: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      if (product.quantity! > 0) {
                        cartData.addItem(product.id as String, product.price!,
                            product.title!);
                      }

                      //ScaffoldMessenger manages snackBar for the scaffold descendent
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Added to cart"),
                          //creating a duration object that sets the duration for the snackbar
                          duration: const Duration(seconds: 1),
                          action: SnackBarAction(
                            label: "UNDO",
                            onPressed: () {
                              cartData.removeSingleItem(product.id!);
                            },
                          )));
                    },
                    color: themeColor.colorScheme.secondary))));
  }
}
