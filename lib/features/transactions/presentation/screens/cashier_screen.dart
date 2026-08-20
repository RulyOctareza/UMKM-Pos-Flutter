import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/sync_status_badge.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/widgets/cart_bottom_sheet.dart';
import '../../../cart/presentation/widgets/cart_panel.dart';
import '../../../products/presentation/providers/product_providers.dart';

class CashierScreen extends ConsumerWidget {
  const CashierScreen({super.key});

  Widget _buildProductCatalog(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryIdProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final cart = ref.watch(cartNotifierProvider);

    return Column(
      children: [
        // Search Bar Produk
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk kasir...',
              prefixIcon: const Icon(AppIcons.search),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: ref.watch(productSearchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: const Icon(AppIcons.close, size: 18),
                      onPressed: () =>
                          ref.read(productSearchQueryProvider.notifier).state =
                              '',
                    )
                  : null,
            ),
            onChanged: (val) =>
                ref.read(productSearchQueryProvider.notifier).state = val,
          ),
        ),

        // Category Filter Chips
        categoriesAsync.when(
          loading: () => const SizedBox(height: 44),
          error: (_, __) => const SizedBox.shrink(),
          data: (categories) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Semua'),
                    selected: selectedCategory == null,
                    onSelected: (_) =>
                        ref.read(selectedCategoryIdProvider.notifier).state =
                            null,
                  ),
                  ...categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat.id,
                        onSelected: (selected) {
                          ref.read(selectedCategoryIdProvider.notifier).state =
                              selected ? cat.id : null;
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),

        // Grid Produk Kasir
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (products) {
              if (products.isEmpty) {
                return const EmptyStateWidget(
                  icon: AppIcons.products,
                  title: 'Produk Tidak Ditemukan',
                  description:
                      'Tambahkan produk di menu Produk terlebih dahulu.',
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final cartItem = cart.items
                      .where((i) => i.product.id == product.id)
                      .firstOrNull;

                  return ProductCard(
                    product: product,
                    quantityInCart: cartItem?.quantity,
                    onTap: () {
                      ref
                          .read(cartNotifierProvider.notifier)
                          .addProduct(product);
                    },
                    onDecrement: cartItem != null
                        ? () {
                            ref
                                .read(cartNotifierProvider.notifier)
                                .decrement(product.id);
                          }
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isExpandedLayout = screenWidth >= 840;
    final cart = ref.watch(cartNotifierProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);
    final storeName =
        ref.watch(storeProfileStreamProvider).value?.name ?? 'UMKM POS';

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: SyncStatusBadge(status: SyncStatus.synced),
          ),
        ],
      ),
      body: isExpandedLayout
          ? Row(
              children: [
                // Panel Kiri: Grid Produk (flex: 2)
                Expanded(flex: 2, child: _buildProductCatalog(context, ref)),
                const VerticalDivider(width: 1),
                // Panel Kanan: Keranjang Kasir Permanen (flex: 1)
                const Expanded(flex: 1, child: CartPanel()),
              ],
            )
          : Stack(
              children: [
                // Single Column Product Grid
                _buildProductCatalog(context, ref),

                // Floating Cart Bar
                if (cart.isNotEmpty)
                  Positioned(
                    bottom: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Material(
                      elevation: 6,
                      borderRadius: AppRadius.roundedMd,
                      color: theme.colorScheme.primary,
                      child: InkWell(
                        onTap: () => CartBottomSheet.show(context),
                        borderRadius: AppRadius.roundedMd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimary.withAlpha(
                                    40,
                                  ),
                                  borderRadius: AppRadius.roundedFull,
                                ),
                                child: Text(
                                  '${cart.totalQuantity} item',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    CurrencyFormatter.format(totalAmount),
                                    style: AppTypography.priceStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Lihat Keranjang',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
