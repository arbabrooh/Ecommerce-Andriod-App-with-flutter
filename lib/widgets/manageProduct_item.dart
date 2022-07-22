import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import "package:provider/provider.dart";
import 'package:go_router/go_router.dart';

import "../providers/product_provider.dart";
import "../screen/addItem.dart";

class ManagedItem extends StatelessWidget {
  final String? productId;
  final String? imageUrl;
  final String? title;
  final int? quantity;

  const ManagedItem(
      {Key? key,
      required this.productId,
      required this.quantity,
      required this.imageUrl,
      required this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Card(
        elevation: 5,
        child: ListTile(
            leading:
                CircleAvatar(backgroundImage: NetworkImage(imageUrl as String)),
            title: Text(title!),
            subtitle: Text("quantity X: ${quantity!}"),
            trailing: Container(
                width: screenSize.width * 0.44,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                      icon: Icon(Icons.edit, color: theme.accentColor),
                      onPressed: () {
                        context.push(
                          AddItem.routeName,
                          extra: productId,
                        );
                      }),
                  IconButton(
                      icon: Icon(Icons.delete, color: theme.errorColor),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text("Do you want to delete?"),
                                  actions: [
                                    TextButton(
                                        child: const Text("YES"),
                                        onPressed: () async {
                                          try {
                                            await Provider.of<ProductProvider>(
                                                    context,
                                                    listen: false)
                                                .removeItem(productId!);
                                          } catch (error) {
                                            scaffoldMessenger
                                                .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Error occur. retry "),
                                              //creating a duration object that sets the duration for the snackbar
                                              duration: Duration(seconds: 1),
                                            ));
                                          }
                                          Navigator.of(context).pop();
                                        }),
                                    TextButton(
                                        child: const Text("NO"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ]);
                            });
                      })
                ]))));
  }
}
