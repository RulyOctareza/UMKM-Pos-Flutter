import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../transactions/presentation/widgets/payment_modal.dart';
import '../providers/cart_providers.dart';
import 'cart_item_tile.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartNotifierProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(AppIcons.pos, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Keranjang Belanja',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (cart.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(
                    AppIcons.delete,
                    size: 16,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Kosongkan',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  onPressed: () =>
                      ref.read(cartNotifierProvider.notifier).clear(),
                ),
            ],
          ),
          const Divider(),

          Expanded(
            child: cart.isEmpty
                ? const EmptyStateWidget(
                    icon: AppIcons.pos,
                    title: 'Keranjang Kosong',
                    description: 'Pilih produk dari menu di sebelah kiri.',
                  )
                : ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemTile(
                        item: item,
                        onQuantityChanged: (newQty) {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .updateQuantity(item.product.id, newQty);
                        },
                      );
                    },
                  ),
          ),

          const Divider(),
          const SizedBox(height: AppSpacing.xs),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total (${cart.totalQuantity} item)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.format(totalAmount),
                  style: AppTypography.priceStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AppPrimaryButton(
            text: 'Bayar Sekarang',
            icon: AppIcons.cash,
            onPressed: cart.isEmpty
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      builder: (_) => const PaymentModal(),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
