import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/product_provider.dart";
import "../widgets/main_drawer.dart";
import "../widgets/manageProduct_item.dart";
import "./addItem.dart";

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);
  static const routeName = "/managementscreen";

  Future<void> refreshProductScreen(BuildContext ctx) async {
    await Provider.of<ProductProvider>(ctx, listen: false).fetchAndSetProduct();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Product")),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(AddItem.routeName);
          }),
      drawer: AppDrawer(),
      //RefreshIndicator use to make the page refreshable....onRefresh is a Future
      body: RefreshIndicator(
          onRefresh: () {
            return refreshProductScreen(context);
          },
          child: ListView.builder(
              itemCount: productData.items.length,
              itemBuilder: (context, i) {
                return ManagedItem(
                  productId: productData.items[i].id!,
                  quantity: productData.items[i].quantity!,
                  title: productData.items[i].title!,
                  imageUrl: productData.items[i].imageUrl!,
                );
              })),
    );
  }
}
