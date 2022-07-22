import "dart:math";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/order_provider.dart";
import "../models/product_model.dart";

class ManageOrderItem extends StatefulWidget {
  final OrderItem? orderItem;

  const ManageOrderItem({Key? key, this.orderItem}) : super(key: key);

  @override
  _ManageOrderItemState createState() => _ManageOrderItemState();
}

class _ManageOrderItemState extends State<ManageOrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    // final cartDeliveryStatus = widget.orderItem.products;
    return Card(
        child: Column(children: [
      ListTile(
          leading: Column(children: [
            Text(widget.orderItem?.customerFirstName as String),
            Text(widget.orderItem?.customerLastName as String)
          ]),
          title: Text(widget.orderItem?.customerAddress as String),
          subtitle: Text(widget.orderItem?.customerPhoneNo as String),
          trailing: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              })),
      if (_expanded)
        Container(
          height: min((widget.orderItem?.products?.length as int) * 90.0, 450),
          child: ListView.builder(
              itemCount: widget.orderItem?.products?.length,
              itemBuilder: (ctx, i) {
                return Card(
                    elevation: 10,
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FittedBox(
                                child: Text(
                                    "${widget.orderItem?.products![i].title}"),
                                fit: BoxFit.contain),
                            FittedBox(
                                child: Text(
                                    "₦ ${widget.orderItem?.products![i].price}"),
                                fit: BoxFit.contain),
                            FittedBox(
                                child: Text(
                                    "X ${widget.orderItem?.products![i].quantity}"),
                                fit: BoxFit.contain)
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                                child: const FittedBox(
                                    child: Text("CONFIRM",
                                        style: TextStyle(fontSize: 10))),
                                onPressed: () {}
                                //   //  productModel.deliveryStatus==DeliveryStatus.Pending?null:() {
                                //   if (productModel.deliveryStatus == DeliveryStatus.Pending) {
                                //     productModel.deliveryStatus = DeliveryStatus.Confirm;
                                //   }
                                // }
                                ),
                            TextButton(
                                child: const FittedBox(
                                    child: Text("IN DELIVERY",
                                        style: TextStyle(fontSize: 10))),
                                onPressed: () {}
                                // productModel.deliveryStatus==DeliveryStatus.Confirm?null: () {
                                //   if (productModel.deliveryStatus == DeliveryStatus.Confirm) {
                                //     productModel.deliveryStatus = DeliveryStatus.InDelivery;
                                //   }
                                // }
                                ),
                            TextButton(
                                child: const FittedBox(
                                    child: Text("DELIVERED",
                                        style: TextStyle(fontSize: 10))),
                                onPressed: () {}
                                // productModel.deliveryStatus==DeliveryStatus.InDelivery?null:() {
                                //   if (productModel.deliveryStatus == DeliveryStatus.InDelivery && productModel.deliveryStatus != DeliveryStatus.Cancelled) {
                                //     productModel.deliveryStatus = DeliveryStatus.Delivered;
                                //   }
                                // }
                                ),
                            TextButton(
                                child: const FittedBox(
                                    child: Text("CANCEL",
                                        style: TextStyle(fontSize: 10))),
                                onPressed: () {
                                  // productModel.deliveryStatus==DeliveryStatus.InDelivery?null:() {
                                  //   if (productModel.deliveryStatus == DeliveryStatus.InDelivery && productModel.deliveryStatus != DeliveryStatus.Delivered) {
                                  //     productModel.deliveryStatus = DeliveryStatus.Cancelled;
                                  //   }
                                  // }
                                }),
                          ]),
                    ]));
              }),
        )
    ]));
  }
}
