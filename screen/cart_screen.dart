import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/cart_provider.dart";
import "../widgets/cart_details.dart";
import "./delivery_details_screen.dart";

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  static const routeName = "/cart_screen";
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(title: const Text("Your Cart")),
        body: Column(children: [
          Card(
              elevation: 5,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontSize: 20)),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Chip(
                          label: Text("₦ ${cartData.cartPrice}"),
                        ),
                      ),
                      TextButton(
                          child: (cartData.items.isEmpty)
                              ? const Text("Add some items")
                              : const Text("BUY HERE"),
                          onPressed: () {
                            if (cartData.items.isEmpty) {
                              Navigator.of(context).pushNamed("/");
                            } else {
                              Navigator.of(context)
                                  .pushNamed(DeliveryScreen.routeName);
                            }
                          }),
                      //OrderButton(),
                    ],
                  ))),
          const SizedBox(height: 15),
          Expanded(
              child: ListView.builder(
                  itemCount: cartData.packageCount,
                  itemBuilder: (ctx, index) {
                    return CartDetails(
                      cartData.items.values.toList()[index].price as double,
                      cartData.items.values.toList()[index].quantity as int,
                      cartData.items.values.toList()[index].id!,
                      cartData.items.values.toList()[index].title as String,
                      cartData.items.keys.toList()[index],
                    );
                  })),
        ]));
  }
}
