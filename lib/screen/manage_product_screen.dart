import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:go_router/go_router.dart';

import "../providers/product_provider.dart";
import "../widgets/main_drawer.dart";
import "../widgets/manageProduct_item.dart";
import '../widgets/sideNavBar.dart';
import "./addItem.dart";

class ProductManagementScreen extends StatelessWidget {
  ProductManagementScreen({Key? key}) : super(key: key);
  static const routeName = "/managementscreen";
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> refreshProductScreen(BuildContext ctx) async {
    await Provider.of<ProductProvider>(ctx, listen: false).fetchAndSetProduct();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Product")),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            context.push(AddItem.routeName);
          }),
      drawer: deviceWidth > 600 ? null : AppDrawer(),
      body: Row(
        children: [
          if (deviceWidth > 600) const SideNavBar(),
          Container(
            width: deviceWidth > 600 ? deviceWidth * 0.9 : deviceWidth,
            padding: deviceWidth > 600
                ? EdgeInsets.symmetric(horizontal: deviceWidth * 0.1)
                : EdgeInsets.all(deviceWidth * 0.001),
            child: RefreshIndicator(
                //RefreshIndicator use to make the page refreshable....onRefresh is a Future
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
          ),
        ],
      ),
    );
  }
}
