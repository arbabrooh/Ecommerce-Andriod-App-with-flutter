import "dart:math";

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";

import "../providers/order_provider.dart";
import "../models/product_model.dart";

class OrderDetails extends StatefulWidget {
  final OrderItem itemOrdered;
  const OrderDetails({Key? key, required this.itemOrdered}) : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 7,
        child: Column(children: [
          ListTile(
              leading: Column(children: [
                const Text("Order Id"),
                Text("${widget.itemOrdered.orderNo}"),
              ]),
              title: Text("₦${widget.itemOrdered.totalPrice}"),
              subtitle: Text(
                  DateFormat.yMMMEd().format(widget.itemOrdered.orderDate!)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              )),
          //
          if (_expanded)
            Container(
              height:
                  min((widget.itemOrdered.products?.length as int) * 80.0, 250),
              child: ListView.builder(
                  itemCount: widget.itemOrdered.products?.length,
                  itemBuilder: (ctx, i) {
                    return Card(
                        child: ListTile(
                            leading: const Text(""),
                            title: Text(
                                "${widget.itemOrdered.products![i].title}"),
                            subtitle: Text(
                                "₦ ${widget.itemOrdered.products![i].price}"),
                            trailing: Text(
                                "X ${widget.itemOrdered.products![i].quantity}")));
                  }),
            )
        ]));
  }
}
