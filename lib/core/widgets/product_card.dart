import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../features/products/domain/entities/product.dart';
import '../utils/currency_formatter.dart';
import 'app_icons.dart';

/// Kartu produk untuk grid kasir & katalog produk sesuai DESIGN_SYSTEM.md §7
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDecrement;
  final int? quantityInCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDecrement,
    this.quantityInCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  Widget _buildProductImage(BuildContext context) {
    final imagePath = widget.product.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
        child: Center(
          child: Icon(
            AppIcons.products,
            size: 36,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
        ),
      );
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
          child: Icon(
            AppIcons.products,
            size: 36,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
        ),
      );
    }

    // Local file image
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
      child: Center(
        child: Icon(
          AppIcons.products,
          size: 36,
          color: Theme.of(context).colorScheme.primary.withAlpha(150),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = widget.product.isOutOfStock;
    final isLowStock = widget.product.isLowStock && !isOutOfStock;
    final isInCart =
        widget.quantityInCart != null && widget.quantityInCart! > 0;

    return Listener(
      onPointerDown: (_) {
        if (widget.onTap != null && !isOutOfStock) {
          setState(() => _isPressed = true);
        }
      },
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: isOutOfStock ? null : widget.onTap,
          borderRadius: AppRadius.roundedMd,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: _isPressed ? 2 : 1,
            color: isOutOfStock
                ? theme.colorScheme.surface.withAlpha(160)
                : theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: isInCart
                  ? BorderSide(color: theme.colorScheme.primary, width: 2)
                  : BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(60),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk + Badge Status + Tombol Minus & Qty
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.md),
                        ),
                        child: _buildProductImage(context),
                      ),

                      // Tombol Minus (-) Ekstra Besar & Sangat Mudah Ditekan di Pojok Kiri Atas
                      if (isInCart && widget.onDecrement != null)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Material(
                            color: AppColors.danger,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              onTap: widget.onDecrement,
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Badge Jumlah (Qty) Ekstra Jelas di Pojok Kanan Atas
                      if (isInCart)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: AppRadius.roundedFull,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(60),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${widget.quantityInCart}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Badge Stok Habis / Menipis
                      if (isOutOfStock)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.md),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Text(
                                'Habis',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      else if (isLowStock)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: AppRadius.roundedSm,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: Text(
                              'Sisa ${widget.product.stock}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info Produk (Nama & Harga)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormatter.format(widget.product.price),
                          style: AppTypography.priceStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
