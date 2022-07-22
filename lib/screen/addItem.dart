import "dart:io";
import "dart:typed_data";
import 'package:image_picker/image_picker.dart';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:firebase_storage/firebase_storage.dart";

import "../models/product_model.dart";
import "../providers/product_provider.dart";
import "../widgets/image_added.dart";
import '../widgets/sideNavBar.dart';

class AddItem extends StatefulWidget {
  final String? productId;
  final GlobalKey? navKey;
  const AddItem({Key? key, required this.navKey, this.productId})
      : super(key: key);
  static const routeName = "/additem";

  @override
  _AddItemState createState() {
    return _AddItemState();
  }
}

class _AddItemState extends State<AddItem> {
  //FocusNode is an An object that can be used by a stateful widget to obtain the keyboard focus and to handle keyboard events.
  final _priceFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  // the get the value of url paste in the url field
  final _imageController = TextEditingController();
  final _imageFocus = FocusNode();
  //_formKey becomes a globalKey object that is associated with the state of a form hence FormState
  final _formKey = GlobalKey<FormState>();

  Uint8List? _productImage; ////File _productImage;
  String attachedImageUrl = "";

  void _imagePicker(Uint8List image) {
    _productImage = image;
  }

  String _selectedCategory =
      ""; //placeholder for the value gotten from dropdown menu
  final List<String> categoryItems = [
    "Shoes",
    "Bags",
    "Hairs",
    "Clothing",
  ];

//variable to keep track of when didchangedependecies run
  var _isInitRun = true;

//variable to keep track of when the http.post requesting is done executing
  var _isLoading = false;

  var _newProduct = ProductModel(
    id: null,
    description: "",
    title: "",
    price: 0.0,
    imageUrl: "",
    quantity: 0,
    category: "",
  );

  // void _saveForm() {
  //   // _formKey.currentState.validate() to ensure the form field validator is called
  //   final formValidate = _formKey.currentState.validate();

  //   if (!formValidate) {
  //     return;
  //     //this ensure the code below it in the method is not run
  //   }
  //   //_formKey is attached to the Form... hence it can be use to manipulate data save in the form
  //   _formKey.currentState.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   //Checking to ensure product without id is add while product with id is edited ie
  //   if (_newProduct.id != null) {
  //     Provider.of<ProductProvider>(context, listen: false).updateProduct(_newProduct.id, _newProduct);
  //     Navigator.of(context).pop();
  //   } else {
  //     Provider.of<ProductProvider>(context, listen: false).addProduct(_newProduct).catchError((error) {
  //       //catchError will execute if the future is unsuccessful or return an errro
  //       print("error");
  //       return showDialog<Null>(
  //           context: context,
  //           builder: (ctx) {
  //             return AlertDialog(title: Text("Hello!"), content: Text("An Error error. Try again"), actions: [
  //               TextButton(
  //                   child: Text("Okay"),
  //                   onPressed: () {
  //                     Navigator.of(ctx).pop();
  //                   })
  //             ]);
  //           });
  //     }).then((response) {
  //       //pop is only run when appProduct is done loading
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   }
  //   //Navigator.of(context).pop();
  // }

// handling _saveForm with async style
  Future<void> _saveForm() async {
    final contxt = widget.navKey?.currentState?.context;

    // _formKey.currentState.validate() to ensure the form field validator is called
    final formValidate = _formKey.currentState?.validate();

    if (!formValidate! || _productImage == null) {
      return;
      //this ensure the code below it in the method is not run
    }

    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final ref = FirebaseStorage.instance
        .ref()
        .child("product_image")
        .child(DateTime.now().toString() + ".jpg");

    await ref.putData(_productImage!).whenComplete(() async {
      attachedImageUrl = await ref.getDownloadURL();
    });

    //_formKey is attached to the Form... hence it can be use to manipulate data save in the form
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    //Checking to ensure product without id is added while product with id is edited
    if (_newProduct.id != null) {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_newProduct.id!, _newProduct);
      } catch (error) {
        await showDialog(
            context: contxt!,
            builder: (ctx) {
              return AlertDialog(
                  title: const Text("Hello!"),
                  content: const Text("An Error error, Can't Edit. Try again"),
                  actions: [
                    TextButton(
                        child: const Text("Okay"),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        })
                  ]);
            });
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_newProduct);
      } catch (error) {
        await showDialog(
            context: contxt!,
            builder: (ctx) {
              return AlertDialog(
                  title: const Text("Hello!"),
                  content: const Text("An Error error. Try again"),
                  actions: [
                    TextButton(
                        child: const Text("Okay"),
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        })
                  ]);
            });
        //it will always run whether the try or catch were successful or not
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    //Navigator.of(context).pop();
  }

  @override
  void initState() {
    //a listener that listens to changes in focus amd run a function updateUrl... the function just rebuild the screen if no focus via setstate
    _imageFocus.addListener(updateUrl);

    super.initState();
  }

  var _initValue = {
    "title": "",
    "price": "",
    "quantity": "",
    "description": "",
    "imageUrl": "",
  };

  @override
  void didChangeDependencies() {
    if (_isInitRun) {
      final productId = widget.productId;
      // to ensure retrieving product don't fail via productId that is null
      if (productId != null) {
        _newProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId as String);
        _initValue = {
          "title": _newProduct.title!,
          "price": _newProduct.price.toString(),
          "quantity": _newProduct.quantity.toString(),
          "description": _newProduct.description!,
          "imageUrl": _newProduct.imageUrl!,
        };
        _imageController.text = _newProduct.imageUrl!;
      }
    }
    _isInitRun = false;
    super.didChangeDependencies();
  }

  void updateUrl() {
    if (!_imageFocus.hasFocus) {
      if ((!_imageController.text.endsWith(".png") ||
              !_imageController.text.endsWith(".jpg") ||
              !_imageController.text.endsWith(".jpeg")) &&
          (!_imageController.text.startsWith("https") ||
              !_imageController.text.startsWith("http"))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageFocus.removeListener(updateUrl);
    _imageFocus.dispose();
    _priceFocus.dispose();
    _quantityFocus.dispose();
    _descriptionFocus.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _deviceScreenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(title: const Text("Add Product")),
        //
        body: Row(
          children: [
            if (_deviceScreenSize.width > 600) const SideNavBar(),
            Container(
              width: _deviceScreenSize.width > 600
                  ? _deviceScreenSize.width * 0.9
                  : _deviceScreenSize.width,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: _deviceScreenSize.width > 600
                          ? EdgeInsets.symmetric(
                              horizontal: _deviceScreenSize.width * 0.2)
                          : const EdgeInsets.all(10),
                      child: Form(
                          key:
                              _formKey, //giving form a key for efficient operation
                          child:
                              //if its a long list a singlechildscrollview and column should be use...
                              ListView(children: [
                            TextFormField(
                                initialValue: _initValue["title"],
                                decoration: const InputDecoration(
                                    labelText: "Enter product Name"),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                //onFieldSubmitted takes a string argument it determines what happens when the submit of the field is pressed
                                onFieldSubmitted: (value) {
                                  //requestFocus request the primary focus of the node... requires a focusnod
                                  FocusScope.of(context)
                                      .requestFocus(_priceFocus);
                                },
                                //onSaved is called the form is submitted
                                onSaved: (value) {
                                  /*value is data received from the form field.... it is a string type */
                                  _newProduct = ProductModel(
                                      category: _newProduct.category,
                                      id: _newProduct.id,
                                      title: value,
                                      quantity: _newProduct.quantity,
                                      description: _newProduct.description,
                                      imageUrl: attachedImageUrl,
                                      price: _newProduct.price,
                                      avaliableSizes:
                                          _newProduct.avaliableSizes,
                                      isFavourite: _newProduct.isFavourite);
                                },
                                validator: (value) {
                                  /*value is data received from the form field.... it is a string type */
                                  if (value!.isEmpty) {
                                    return "Input a Name for the product";
                                  }
                                  return null;
                                }),
                            DropdownButtonFormField(
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value as String;
                                });
                              },
                              hint: const Text("please choose one"),
                              //value: _selectedCategory,
                              validator: (value) {
                                if (value == null) {
                                  return "Field can not be empty";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                setState(() {
                                  _selectedCategory = value as String;
                                });
                                _newProduct = ProductModel(
                                    id: _newProduct.id,
                                    title: _newProduct.title,
                                    quantity: _newProduct.quantity,
                                    description: _newProduct.description,
                                    imageUrl: attachedImageUrl,
                                    price: _newProduct.price,
                                    avaliableSizes: _newProduct.avaliableSizes,
                                    isFavourite: _newProduct.isFavourite,
                                    category: _selectedCategory);
                              },
                              items: categoryItems.map((String item) {
                                return DropdownMenuItem(
                                    onTap: () {},
                                    child: Text(item),
                                    value: item);
                              }).toList(),
                            ),
                            TextFormField(
                                initialValue: _initValue["price"],
                                decoration: const InputDecoration(
                                    labelText: "Enter price of product"),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                focusNode: _priceFocus,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_quantityFocus);
                                },
                                onSaved: (value) {
                                  /*value is data received from the form field.... it is a string type */
                                  _newProduct = ProductModel(
                                      id: _newProduct.id,
                                      title: _newProduct.title,
                                      quantity: _newProduct.quantity,
                                      description: _newProduct.description,
                                      imageUrl: attachedImageUrl,
                                      price: double.parse(value!),
                                      avaliableSizes:
                                          _newProduct.avaliableSizes,
                                      isFavourite: _newProduct.isFavourite,
                                      category: _newProduct.category);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Price can't be empty. Please enter a price";
                                  }
                                  if (double.parse(value) < 1) {
                                    return "Enter a valid price";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                initialValue: _initValue["quantity"],
                                decoration: const InputDecoration(
                                    labelText: "Enter quantity of product"),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                focusNode: _quantityFocus,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_descriptionFocus);
                                },
                                onSaved: (value) {
                                  /*value is data received from the form field.... it is a string type */
                                  _newProduct = ProductModel(
                                      avaliableSizes:
                                          _newProduct.avaliableSizes,
                                      isFavourite: _newProduct.isFavourite,
                                      id: _newProduct.id,
                                      title: _newProduct.title,
                                      quantity: int.parse(value!),
                                      description: _newProduct.description,
                                      imageUrl: attachedImageUrl,
                                      price: _newProduct.price,
                                      category: _newProduct.category);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Quantity field can't be empty";
                                  }
                                  if (int.parse(value) < 1) {
                                    return "Enter a valid quantity";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                initialValue: _initValue["description"],
                                decoration: const InputDecoration(
                                    labelText: "Enter product description"),
                                maxLines: 3,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.next,
                                focusNode: _descriptionFocus,
                                onSaved: (value) {
                                  /*value is data received from the form field.... it is a string type */
                                  _newProduct = ProductModel(
                                      category: _newProduct.category,
                                      id: _newProduct.id,
                                      title: _newProduct.title,
                                      quantity: _newProduct.quantity,
                                      description: value,
                                      imageUrl: attachedImageUrl,
                                      price: _newProduct.price);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter product description here";
                                  }
                                  if (value.length < 15) {
                                    return "Description is too short";
                                  }
                                  return null;
                                }),
                            // Row(
                            //     crossAxisAlignment: CrossAxisAlignment.end,
                            //     children: [
                            // Container(
                            //     decoration:
                            //         BoxDecoration(border: Border.all(width: 1)),
                            //     height: _deviceScreenSize.height * 0.1,
                            //     width: _deviceScreenSize.width * 0.2,
                            //     child: _imageController.text.isEmpty
                            //         ? const Center(
                            //             child: Text("Enter ImageUrl"))
                            //         : FittedBox(
                            //             child: Image.network(
                            //                 _imageController.text,
                            //                 fit: BoxFit.cover))),
                            // Expanded(
                            //   child: TextFormField(
                            //       decoration: const InputDecoration(
                            //           labelText: "Paste ImageUrl"),
                            //       keyboardType: TextInputType.url,
                            //       textInputAction: TextInputAction.done,
                            //       //controller controls the text being edited
                            //       controller: _imageController,
                            //       //neccessary so we can tell when the textfield loses focus
                            //       focusNode: _imageFocus,
                            //       onSaved: (value) {
                            //         /*value is data received from the form field.... it is a string type */
                            //         _newProduct = ProductModel(
                            //             category: _newProduct.category,
                            //             avaliableSizes:
                            //                 _newProduct.avaliableSizes,
                            //             isFavourite: _newProduct.isFavourite,
                            //             id: _newProduct.id,
                            //             title: _newProduct.title,
                            //             quantity: _newProduct.quantity,
                            //             description: _newProduct.description,
                            //             imageUrl: value,
                            //             price: _newProduct.price);
                            //       },
                            //       onFieldSubmitted: (_) {
                            //         _saveForm();
                            //       },
                            //       validator: (value) {
                            //         if (value!.isEmpty) {
                            //           return "please input image Url";
                            //         }
                            //         if (!value.endsWith(".png") &&
                            //             (!value.endsWith(".jpeg")) &&
                            //             (!value.endsWith(".jpg"))) {
                            //           return "please input valid image Url";
                            //         }
                            //         if (!value.startsWith("https") &&
                            //             !value.startsWith("http")) {
                            //           return "please input valid image Url";
                            //         }
                            //         return null;
                            //       }),
                            // )
                            //]),
                            ImageHolder(_imagePicker),
                            const SizedBox(height: 10),
                            TextButton(
                              child: Text("SUBMIT",
                                  style: TextStyle(color: theme.primaryColor),
                                  textAlign: TextAlign.end),
                              onPressed: () {
                                _saveForm();
                              },
                            )
                          ])),
                    ),
            ),
          ],
        ));
  }
}

// import 'package:flutter/material.dart';

// class AddItem extends StatelessWidget {
//   const AddItem({Key? key}) : super(key: key);
//   static const routeName = "/additem";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appbar: AppBar(title: const Text("Add Product")),
//         body: Center(child: Text("ADD screen")));
//   }
// }
