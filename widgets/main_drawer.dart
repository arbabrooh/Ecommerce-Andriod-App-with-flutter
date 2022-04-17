import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../screen/orders_screen.dart";
import "../screen/manage_product_screen.dart";
import "../screen/manage_order_screen.dart";
import "../providers/auth_provider.dart";
import "../private.dart";

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final contentHeight = MediaQuery.of(context).size.height;
    final authData = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);
    return Drawer(
        child: Column(children: [
      // Container(
      //   alignment: Alignment.center,
      //   height: contentHeight * 0.2,
      //   color: theme.primaryColor,
      //   child: Padding(
      //       padding: EdgeInsets.all(10),
      //       child: Row(children: [
      //         Icon(Icons.local_mall, color: Colors.white, size: 30),
      //         SizedBox(width: 10),
      //         Text("Ese Fashion", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))
      //       ])),
      // ),
      AppBar(
          title: Row(children: const [
        Icon(Icons.local_mall, color: Colors.white, size: 24),
        SizedBox(width: 10),
        Text("Ese Fashion",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
      ])),
      ListTile(
        title: const Text("Shop", style: TextStyle(fontSize: 20)),
        leading: const Icon(Icons.shopping_bag, size: 20),
        onTap: () {
          Navigator.of(context).pushReplacementNamed("/");
        },
      ),
      const Divider(),
      ListTile(
          title: const Text("Orders", style: TextStyle(fontSize: 20)),
          leading: const Icon(Icons.payment, size: 20),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          }),
      const Divider(),
      if (authData.emailAdress == "mradmin@admin.ese")
        ListTile(
            title:
                const Text("Manage Products", style: TextStyle(fontSize: 20)),
            leading: const Icon(Icons.create, size: 20),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProductManagementScreen.routeName);
            }),
      if (authData.emailAdress == AdminEmail.email) const Divider(),
      if (authData.emailAdress == AdminEmail.email)
        ListTile(
            title: const Text("Manage Orders", style: TextStyle(fontSize: 20)),
            leading: const Icon(Icons.create, size: 20),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ManageOrderScreen.routeName);
            }),
      if (authData.emailAdress == AdminEmail.email) const Divider(),
      ListTile(
          title: const Text("logout", style: TextStyle(fontSize: 20)),
          leading: const Icon(Icons.logout, size: 20),
          onTap: () {
            Navigator.of(context)
                .pop(); //to ensure the drawer is alway close to avoid an error;
            Navigator.of(context).pushReplacementNamed("/");
            authData.logOut();
          }),
    ]));
  }
}
