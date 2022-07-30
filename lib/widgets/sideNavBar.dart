import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../private.dart';
import '../providers/auth_provider.dart';
import '../screen/manage_order_screen.dart';
import '../screen/manage_product_screen.dart';
import '../screen/orders_screen.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColour = Theme.of(context).primaryColor;
    final deviceWidth = MediaQuery.of(context).size.width;
    final authData = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      width: deviceWidth * 0.07,
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          InkWell(
            onTap: () {
              context.push("/");
            },
            child: Column(
              children: [
                const Icon(Icons.shopping_bag, size: 20, color: Colors.purple),
                Text("Home", style: TextStyle(fontSize: deviceWidth * 0.012))
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              context.go(OrdersScreen.routeName);
            },
            child: Column(
              children: [
                const Icon(Icons.payment, size: 20, color: Colors.purple),
                Text("Orders", style: TextStyle(fontSize: deviceWidth * 0.012))
              ],
            ),
          ),
          const Divider(),
          if (authData.emailAdress == AdminEmail.email)
            InkWell(
              onTap: () {
                context.go(ProductManagementScreen.routeName);
              },
              child: Column(
                children: [
                  const Icon(Icons.create, size: 20, color: Colors.purple),
                  Text("Manage\nProducts",
                      style: TextStyle(fontSize: deviceWidth * 0.01))
                ],
              ),
            ),
          if (authData.emailAdress == AdminEmail.email) const Divider(),
          if (authData.emailAdress == AdminEmail.email)
            InkWell(
              onTap: () {
                context.go(ManageOrderScreen.routeName);
              },
              child: Column(
                children: [
                  const Icon(Icons.create, size: 20, color: Colors.purple),
                  Text("Manage\nOrders",
                      style: TextStyle(fontSize: deviceWidth * 0.01))
                ],
              ),
            ),
          if (authData.emailAdress == AdminEmail.email) const Divider(),
          InkWell(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logOut();
            },
            child: Column(
              children: [
                const Icon(Icons.logout, size: 20, color: Colors.purple),
                Text("logout", style: TextStyle(fontSize: deviceWidth * 0.012))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
