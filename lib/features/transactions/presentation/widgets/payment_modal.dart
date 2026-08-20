import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_numpad.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';
import '../screens/payment_success_screen.dart';

class PaymentModal extends ConsumerStatefulWidget {
  const PaymentModal({super.key});

  @override
  ConsumerState<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends ConsumerState<PaymentModal> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  double _cashReceived = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final total = ref.read(cartTotalAmountProvider);
    _cashReceived = total;
  }

  Future<void> _processPayment() async {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) return;

    if (_selectedMethod == PaymentMethod.cash &&
        _cashReceived < cart.totalAmount) {
      AppSnackbar.showError(context, 'Uang tunai kurang dari total belanja');
      return;
    }

    setState(() => _isLoading = true);

    final result = await ref
        .read(checkoutControllerProvider.notifier)
        .processCheckout(
          paymentMethod: _selectedMethod,
          cashReceived: _cashReceived,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        onSuccess: (tx) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(transaction: tx),
            ),
          );
        },
        onError: (f) {
          AppSnackbar.showError(context, f.message);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAmount = ref.watch(cartTotalAmountProvider);
    final changeAmount = _cashReceived >= totalAmount
        ? (_cashReceived - totalAmount)
        : 0.0;
    final isCashShort =
        _selectedMethod == PaymentMethod.cash && _cashReceived < totalAmount;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pembayaran',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(90),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Belanja',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(totalAmount),
                        style: AppTypography.priceStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              SegmentedButton<PaymentMethod>(
                segments: const [
                  ButtonSegment(
                    value: PaymentMethod.cash,
                    label: Text('Tunai'),
                    icon: Icon(AppIcons.cash),
                  ),
                  ButtonSegment(
                    value: PaymentMethod.qris,
                    label: Text('QRIS'),
                    icon: Icon(AppIcons.qris),
                  ),
                  ButtonSegment(
                    value: PaymentMethod.transfer,
                    label: Text('Transfer'),
                    icon: Icon(Icons.account_balance_outlined),
                  ),
                ],
                selected: {_selectedMethod},
                onSelectionChanged: (newSelection) {
                  setState(() => _selectedMethod = newSelection.first);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              if (_selectedMethod == PaymentMethod.cash) ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isCashShort
                                ? AppColors.danger
                                : theme.colorScheme.outlineVariant,
                          ),
                          borderRadius: AppRadius.roundedMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uang Diterima',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  150,
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(_cashReceived),
                                style: AppTypography.priceStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isCashShort
                                      ? AppColors.danger
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(20),
                          borderRadius: AppRadius.roundedMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kembalian',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(changeAmount),
                                style: AppTypography.priceStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                CustomNumpad(
                  totalAmount: totalAmount,
                  currentAmount: _cashReceived,
                  onAmountChanged: (amt) => setState(() => _cashReceived = amt),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                      80,
                    ),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedMethod == PaymentMethod.qris
                            ? AppIcons.qris
                            : Icons.account_balance_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _selectedMethod == PaymentMethod.qris
                            ? 'Tunjukkan QRIS Toko ke Pelanggan'
                            : 'Konfirmasi Transfer Bank Telah Masuk',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Pastikan pembayaran telah berhasil diterima sebelum menyelesaikan transaksi.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              AppPrimaryButton(
                text:
                    'Selesaikan Pembayaran (${CurrencyFormatter.format(totalAmount)})',
                icon: AppIcons.check,
                isLoading: _isLoading,
                onPressed: isCashShort ? null : _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
