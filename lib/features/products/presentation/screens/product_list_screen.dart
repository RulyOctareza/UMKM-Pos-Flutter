import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/category_manage_dialog.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  // Default tampilan adalah List View (sesuai kebutuhan manajemen stok UMKM)
  bool _isGridView = false;

  Widget _buildProductThumbnail(BuildContext context, String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
          borderRadius: AppRadius.roundedSm,
        ),
        child: Center(
          child: Icon(
            AppIcons.products,
            size: 24,
            color: Theme.of(context).colorScheme.primary.withAlpha(160),
          ),
        ),
      );
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: AppRadius.roundedSm,
        child: CachedNetworkImage(
          imageUrl: imagePath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 52,
            height: 52,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 52,
            height: 52,
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
            child: Icon(
              AppIcons.products,
              size: 24,
              color: Theme.of(context).colorScheme.primary.withAlpha(160),
            ),
          ),
        ),
      );
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: AppRadius.roundedSm,
        child: Image.file(file, width: 52, height: 52, fit: BoxFit.cover),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Center(
        child: Icon(
          AppIcons.products,
          size: 24,
          color: Theme.of(context).colorScheme.primary.withAlpha(160),
        ),
      ),
    );
  }

  Widget _buildProductListTile(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isOutOfStock = product.isOutOfStock;
    final isLowStock = product.isLowStock && !isOutOfStock;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMd,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.roundedMd,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(initialProduct: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _buildProductThumbnail(context, product.imagePath),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withAlpha(30),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: const Text(
                              'Habis',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else if (isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(30),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              'Sisa ${product.stock} ${product.unit}',
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Stok: ${product.stock} ${product.unit}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                              fontSize: 12,
                            ),
                          ),
                        if (product.barcode != null &&
                            product.barcode!.isNotEmpty)
                          Text(
                            '• SKU: ${product.barcode}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(130),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.format(product.price),
                        style: AppTypography.priceStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (product.costPrice > 0)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Modal: ${CurrencyFormatter.formatCompact(product.costPrice)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withAlpha(130),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryIdProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'Tampilan Daftar' : 'Tampilan Grid',
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(AppIcons.filter),
            tooltip: 'Kelola Kategori',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CategoryManageDialog(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(AppIcons.add),
        label: const Text('Tambah Produk'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama produk...',
                prefixIcon: const Icon(AppIcons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: ref.watch(productSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close, size: 18),
                        onPressed: () => ref
                            .read(productSearchQueryProvider.notifier)
                            .state = '',
                      )
                    : null,
              ),
              onChanged: (val) =>
                  ref.read(productSearchQueryProvider.notifier).state = val,
            ),
          ),

          // Category Filter Chips
          categoriesAsync.when(
            loading: () => const SizedBox(height: 48),
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
                      onSelected: (_) => ref
                          .read(selectedCategoryIdProvider.notifier)
                          .state = null,
                    ),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xs),
                        child: FilterChip(
                          label: Text(cat.name),
                          selected: selectedCategory == cat.id,
                          onSelected: (selected) {
                            ref
                                .read(selectedCategoryIdProvider.notifier)
                                .state = selected ? cat.id : null;
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Product List / Grid View
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (products) {
                if (products.isEmpty) {
                  return EmptyStateWidget(
                    icon: AppIcons.products,
                    title: 'Belum Ada Produk',
                    description:
                        'Tambahkan produk pertama Anda untuk mulai berjualan.',
                    actionText: 'Tambah Produk',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductFormScreen(),
                        ),
                      );
                    },
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductFormScreen(initialProduct: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                // Default: List View
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductListTile(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
