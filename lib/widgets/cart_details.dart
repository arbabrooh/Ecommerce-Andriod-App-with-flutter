import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/cart_provider.dart";

class CartDetails extends StatefulWidget {
  final double price;
  final int quantity;
  final String id;
  final String title;
  final String productId;

  CartDetails(this.price, this.quantity, this.id, this.title, this.productId);

  _CartDetailsState createState() => _CartDetailsState();
}

class _CartDetailsState extends State<CartDetails> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final cartData = Provider.of<Cart>(
      context,
    );
    final theme = Theme.of(context);
    //Dismissilbe use to remove widget via sliding.... requires a key which needs to be pass to ValueKey()
    return Dismissible(
        key: ValueKey(widget.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          //confirmDismiss return a future<bool>
          //showDialog displays a Material dialog above the current contents of the app
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("Are you sure?"),
                    content: Text("Do you want to remove this item?"),
                    actions: [
                      TextButton(
                          child: Text("YES"),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          }),
                      TextButton(
                          child: Text("NO"),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          }),
                    ]);
              });
        },
        onDismissed: (dimissDirection) {
          //calling Provider directly
          cartData.removeItem(widget.productId);
        },
        background: Container(
            color: theme.errorColor,
            padding: EdgeInsets.all(11),
            //margin: EdgeInsets.all(20),
            child: Icon(Icons.delete, color: Colors.white),
            alignment: Alignment.centerRight),
        child: Card(
          elevation: 5,
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Row(children: [
                Container(
                    width: deviceWidth * 0.1,
                    child: CircleAvatar(
                        child: FittedBox(
                            child:
                                Text("₦${widget.price * widget.quantity}")))),
                Container(
                    width: deviceWidth > 600
                        ? deviceWidth * 0.45
                        : deviceWidth * 0.6,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FittedBox(
                              child: Text(widget.title,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(width: 5),
                          Text("X: ${widget.quantity}")
                        ])),
                Container(
                    width: deviceWidth > 600
                        ? deviceWidth * 0.1
                        : deviceWidth * 0.13,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    cartData.addSingleItem(widget.productId);
                                  });
                                }),
                            IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    cartData.removeSingleItem(widget.productId);
                                  });
                                }),
                          ]),
                    ))
              ])),
        ));
  }
}
