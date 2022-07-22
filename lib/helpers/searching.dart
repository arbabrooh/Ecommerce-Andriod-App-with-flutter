import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/product_gridview.dart';

class ProductSearch extends SearchDelegate<ProductModel?> {
  final bool isFavourite;
  ProductSearch(this.isFavourite);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<ProductModel>? result =
        Provider.of<ProductProvider>(context, listen: false)
            .searchResult(query);
    if (result != null) {
      return ProductGridView(isFavourite, result);
    }
    return ProductGridView(isFavourite);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final result = Provider.of<ProductProvider>(context, listen: false)
        .searchResult(query);
    if (result != null) {
      return ListView.builder(
        itemCount: result.length,
        itemBuilder: (ctx, idx) {
          return ListTile(
              title: Text(result[idx].title!),
              onTap: () {
                query = result[idx].title!;
              });
        },
      );
    }
    return const Center(child: Text("No suggestion"));
  }
}
