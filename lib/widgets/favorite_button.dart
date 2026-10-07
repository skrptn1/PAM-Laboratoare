import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/store_cubit.dart';
import '../theme.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  const FavoriteButton({super.key, required this.productId});
  @override
  Widget build(BuildContext context) =>
      BlocSelector<StoreCubit, StoreState, bool>(
        selector: (state) => state.favorites.contains(productId),
        builder: (context, favorite) => IconButton.filledTonal(
          tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.red,
          ),
          iconSize: 20,
          onPressed: () => context.read<StoreCubit>().toggleFavorite(productId),
          icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
        ),
      );
}
