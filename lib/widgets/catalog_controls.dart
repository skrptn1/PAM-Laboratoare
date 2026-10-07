import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/store_cubit.dart';

class CatalogControls extends StatefulWidget {
  const CatalogControls({super.key});
  @override
  State<CatalogControls> createState() => _CatalogControlsState();
}

class _CatalogControlsState extends State<CatalogControls> {
  late final TextEditingController _search = TextEditingController(
    text: context.read<StoreCubit>().state.query,
  );
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<StoreCubit, StoreState>(
    listenWhen: (a, b) => a.query != b.query,
    listener: (_, state) {
      if (_search.text != state.query) {
        _search.value = TextEditingValue(
          text: state.query,
          selection: TextSelection.collapsed(offset: state.query.length),
        );
      }
    },
    builder: (context, state) {
      final cubit = context.read<StoreCubit>();
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              key: const Key('catalog-search'),
              controller: _search,
              onChanged: cubit.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () => cubit.search(''),
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: state.category == null,
                    onSelected: (_) => cubit.filter(null),
                  ),
                ),
                for (final category in state.data?.categories ?? [])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: state.category == category.id,
                      onSelected: (_) => cubit.filter(category.id),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<ProductSort>(
                    isExpanded: true,
                    value: state.sort,
                    onChanged: (sort) {
                      if (sort != null) cubit.sortBy(sort);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ProductSort.original,
                        child: Text('Original order'),
                      ),
                      DropdownMenuItem(
                        value: ProductSort.priceAscending,
                        child: Text('Price: low to high'),
                      ),
                      DropdownMenuItem(
                        value: ProductSort.priceDescending,
                        child: Text('Price: high to low'),
                      ),
                      DropdownMenuItem(
                        value: ProductSort.name,
                        child: Text('Name: A-Z'),
                      ),
                      DropdownMenuItem(
                        value: ProductSort.rating,
                        child: Text('Highest rating'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Reset filters',
                  onPressed: cubit.resetFilters,
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
