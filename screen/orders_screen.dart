import 'dart:io';

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/order_provider.dart";
import "../widgets/order_Details.dart";
import "../widgets/main_drawer.dart";
import "../providers/product_provider.dart";

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  static const routeName = "/orderScreen";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;

  @override
  void initState() {
    //Future.delayed ensures that it content is run last ie after build thereby it now have context
    //which is not usually available in initState
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<OrderProvider>(context, listen: false)
            .fetchAndSetOrders();
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("an error occur")));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<OrderProvider>(context, listen: false);
    //final productData = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Your Orders")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) {
                // i is the index
                // return ChangeNotifierProvider.value(
                //   //.value useful when providing for a widget. A ProductModel listener for the manageOrderItem widget
                //   value: productData.items[i],
                //   child: OrderDetails(orderData.orders[i]), //data passed using providers instead of arguments.
                // );
                return OrderDetails(itemOrdered: orderData.orders[i]);
              }),
      drawer: AppDrawer(),
    );
  }
}
