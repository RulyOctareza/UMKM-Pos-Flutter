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

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartNotifierProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Keranjang (${cart.totalQuantity} item)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const Divider(),

          Expanded(
            child: cart.isEmpty
                ? const EmptyStateWidget(
                    icon: AppIcons.pos,
                    title: 'Keranjang Kosong',
                    description: 'Silakan tambahkan produk ke keranjang.',
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
              Text(
                'Total Belanja',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
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
            text: 'Bayar (${CurrencyFormatter.format(totalAmount)})',
            icon: AppIcons.cash,
            onPressed: cart.isEmpty
                ? null
                : () {
                    Navigator.pop(context);
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
