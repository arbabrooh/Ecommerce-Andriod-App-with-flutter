import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:shop_project/private.dart';

import "../providers/product_provider.dart";
import "../models/product_model.dart";
import "../widgets/product_item.dart";
import "../providers/cart_provider.dart";

class ProductGridView extends StatefulWidget {
  final bool? isFav;
  final List<ProductModel>? searchList;
  const ProductGridView(this.isFav, [this.searchList]);

  @override
  _ProductGridViewState createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  Future? _provHolder;

  Future<void>? _providerFetcher() {
    return Provider.of<Cart>(context, listen: false).fetchAndSetCart();
  }

  @override
  void initState() {
    _provHolder = _providerFetcher();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ProductModel> availableProducts = [];

    final deviceOrientation = MediaQuery.of(context).size;
    final productData = Provider.of<ProductProvider>(context);
    if (widget.searchList != null) {
      availableProducts = widget.searchList!;
    } else {
      availableProducts =
          widget.isFav as bool ? productData.favouriteItems : productData.items;
    }

    //GridView.builder use to generate a dynamic gridItem,
    return FutureBuilder(
        future: _provHolder,
        builder: (context, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapShot.hasError) {
              return const Center(child: Text("An Error occur"));
              //showDialog(
              // context: context,
              // builder: (context){
              //   AlertDialog(title: Text("An error Occur"), actions: [
              //       TextButton(
              //           child: Text("Okay"),
              //           onPressed: () {
              //             Navigator.of(context).pop();
              //           })
              //     ]);
              //     });
            } else {
              return GridView.builder(
                padding: deviceOrientation.width > 800
                    ? EdgeInsets.symmetric(
                        horizontal: deviceOrientation.height * 0.2,
                        vertical: 20)
                    : EdgeInsets.all(deviceOrientation.height * 0.02),
                itemCount: availableProducts.length,
                itemBuilder: (context, index) {
                  //if (productData.items[index].quantity! > 0) {
                  //creating a notifier on a single product item with .value  ...... using a nested provider
                  return ChangeNotifierProvider.value(
                    value: availableProducts[index],
                    child:
                        const ProductItem(), //data passed using providers instead of arguments.
                  );
                  //}
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: deviceOrientation.width > 1000
                        ? 4
                        : deviceOrientation.width > 600
                            ? 3
                            : 2,
                    childAspectRatio: 2 / 2,
                    crossAxisSpacing: deviceOrientation.width * 0.01,
                    mainAxisSpacing: deviceOrientation.height * 0.01),
              );
            }
          }
        });
  }
}
