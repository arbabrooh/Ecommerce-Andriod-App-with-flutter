import 'dart:developer';

import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/order_provider.dart";
import "../widgets/manage_order_item.dart";
import "../widgets/main_drawer.dart";
import '../widgets/sideNavBar.dart';

class ManageOrderScreen extends StatefulWidget {
  const ManageOrderScreen({Key? key}) : super(key: key);
  static const routeName = "/manageOrder";

  @override
  _ManageOrderScreenState createState() => _ManageOrderScreenState();
}

class _ManageOrderScreenState extends State<ManageOrderScreen> {
  Future? _futureHolder;

  Future<void> _futureHolderMethod() {
    return Provider.of<OrderProvider>(context, listen: false).fechAllOrders();
  }

  @override
  void initState() {
    _futureHolder = _futureHolderMethod();
    super.initState();
  }
  // var _isLoading = false;
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero).then((_) async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     try {
  //       await Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrders();
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     } catch (error) {
  //
  //     }
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: const Text("Manange Orders")),
        body: Row(
          children: [
            if (deviceWidth > 600) const SideNavBar(),
            Container(
              width: deviceWidth > 600 ? deviceWidth * 0.9 : deviceWidth,
              padding: deviceWidth > 600
                  ? EdgeInsets.symmetric(horizontal: deviceWidth * 0.1)
                  : EdgeInsets.all(deviceWidth * 0.001),
              child: FutureBuilder(
                future: _futureHolder,
                builder: (ctx, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapShot.error != null) {
                      return const Center(child: Text("An Error Occur"));
                    } else {
                      return Consumer<OrderProvider>(
                          //a provider to listen to changes on the orderprovider and rebuild the listView accordingly
                          builder: (ctx, orderData, _) => ListView.builder(
                              itemCount: orderData.allOrders.length,
                              itemBuilder: (ctx, i) {
                                return ManageOrderItem(
                                    orderItem: orderData.allOrders[i]);
                              }));
                    }
                  }
                },
              ),
            ),
          ],
        ),
        drawer: deviceWidth > 600 ? null : AppDrawer());
  }
}
