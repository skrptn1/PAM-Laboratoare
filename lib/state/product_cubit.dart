import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product.dart';

class ProductSelection {
  final String? colorId, size;
  const ProductSelection({this.colorId, this.size});
}

class ProductCubit extends Cubit<ProductSelection> {
  final Product product;
  ProductCubit(this.product)
    : super(
        ProductSelection(
          colorId:
              product.colorOptions.any((c) => c.id == product.selectedColor)
              ? product.selectedColor
              : product.colorOptions.firstOrNull?.id,
          size:
              product.sizes.contains(product.selectedSize) &&
                  product.sizeAvailable(product.selectedSize!)
              ? product.selectedSize
              : product.sizes.where(product.sizeAvailable).firstOrNull,
        ),
      );
  void selectColor(String id) {
    if (product.colorOptions.any((c) => c.id == id)) {
      emit(ProductSelection(colorId: id, size: state.size));
    }
  }

  void selectSize(String size) {
    if (product.sizes.contains(size) && product.sizeAvailable(size)) {
      emit(ProductSelection(colorId: state.colorId, size: size));
    }
  }
}
