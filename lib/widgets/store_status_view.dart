import 'package:flutter/material.dart';

import '../state/store_cubit.dart';

class StoreStatusView extends StatelessWidget {
  final StoreStatus status;
  final String? message;
  final VoidCallback? onRetry;
  const StoreStatusView({
    super.key,
    required this.status,
    this.message,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    if (status == StoreStatus.loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products...'),
          ],
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status == StoreStatus.error
                  ? Icons.error_outline
                  : Icons.search_off,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message ??
                  (status == StoreStatus.error
                      ? 'We could not load the store.'
                      : 'No products found.'),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(
                  status == StoreStatus.error ? 'Try again' : 'Reset filters',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
