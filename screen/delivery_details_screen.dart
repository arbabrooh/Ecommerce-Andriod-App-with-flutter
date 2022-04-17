import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/cart_provider.dart";
import "../providers/order_provider.dart";

enum PaymentMethod {
  cashOnDelivery,
  paymentOnline,
}

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);
  static const routeName = "/delivery_screen";
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameFocus = FocusNode();
  final _phoneNoFocus = FocusNode();
  final _addressFocus = FocusNode();
  PaymentMethod _payment = PaymentMethod.cashOnDelivery;
  var _firstName = "";
  var _address = "";
  var _phoneNo = "";
  var _lastName = "";

  var _newDelivery = OrderItem(
      customerFirstName: "",
      customerLastName: "",
      customerAddress: "",
      customerPhoneNo: "",
      totalPrice: 0.0,
      orderDate: null,
      orderNo: "",
      id: null,
      products: []);

  Future<void> saveForm() async {
    final formValidate = _formKey.currentState?.validate();
    if (formValidate!) {
      _formKey.currentState?.save();
      try {
        await Provider.of<OrderProvider>(context, listen: false).addOrders(
            cartContent:
                Provider.of<Cart>(context, listen: false).items.values.toList(),
            total: Provider.of<Cart>(context, listen: false).cartPrice,
            lastName: _lastName,
            firstName: _firstName,
            address: _address,
            phoneNo: _phoneNo);
        await showDialog(
            //await necessary to make the showDialog work outside the build method.
            context: context,
            builder: (ctx) => AlertDialog(
                    title:
                        const Center(child: Text("ORDER SUCCESSFULY PLACED")),
                    actions: [
                      TextButton(
                          child: const Text("okay"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ]));
        Provider.of<Cart>(context, listen: false).clearCart();
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An error occur. Try again",
                textAlign: TextAlign.center)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(title: const Text("Your Information")),
        body: Column(children: [
          Container(
              padding: const EdgeInsets.all(10),
              height: deviceHeight * 0.45,
              child: Form(
                  key: _formKey,
                  child: ListView(children: [
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Enter First Name"),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Your First Name";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_lastNameFocus);
                        },
                        onSaved: (value) {
                          _firstName = value as String;
                        }),
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Enter your last name"),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Your Second Name";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_addressFocus);
                        },
                        onSaved: (value) {
                          _lastName = value!;
                        }),
                    TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Enter address"),
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Your Address";
                          }
                          if (value.length <= 20) {
                            return "please make your address more concise";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_phoneNoFocus);
                        },
                        onSaved: (value) {
                          _address = value as String;
                        }),
                    TextFormField(
                        decoration: const InputDecoration(
                            labelText: "Enter phone number"),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please Enter Your phone Number";
                          }
                          if (value.length != 11 &&
                              !value.startsWith("07") &&
                              !value.startsWith("08") &&
                              !value.startsWith("09")) {
                            return "please make enter a valid phone number";
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          //saveForm();
                        },
                        onSaved: (value) {
                          _phoneNo = value as String;
                        }),
                  ]))),
          const SizedBox(height: 10),
          Card(
              child: Column(children: [
            RadioListTile<PaymentMethod>(
              title: const Text('Pay with cash'),
              value: PaymentMethod.cashOnDelivery,
              groupValue: _payment,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _payment = value!;
                });
              },
            ),
          ])),
          OrderButton(formSaver: saveForm),
        ]));
  }
}

class OrderButton extends StatefulWidget {
  final Function? formSaver;
  const OrderButton({Key? key, this.formSaver}) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final theme = Theme.of(context);
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FlatButton(
            color: theme.primaryColor,
            child: const Text(
              "ORDER NOW",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: cartData.items.isEmpty
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                    });
                    widget.formSaver!();
                    setState(() {
                      _isLoading = false;
                    });
                  });
  }
}
