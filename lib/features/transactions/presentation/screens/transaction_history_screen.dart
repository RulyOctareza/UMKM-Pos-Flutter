import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_detail_modal.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter(0);
    });
  }

  void _applyFilter(int index) {
    setState(() => _selectedFilterIndex = index);
    final now = DateTime.now();

    if (index == 0) {
      final today = DateTime(now.year, now.month, now.day);
      ref.read(transactionStartDateProvider.notifier).state = today;
      ref.read(transactionEndDateProvider.notifier).state = today;
    } else if (index == 1) {
      ref.read(transactionStartDateProvider.notifier).state = now.subtract(
        const Duration(days: 7),
      );
      ref.read(transactionEndDateProvider.notifier).state = now;
    } else if (index == 2) {
      ref.read(transactionStartDateProvider.notifier).state = DateTime(
        now.year,
        now.month,
        1,
      );
      ref.read(transactionEndDateProvider.notifier).state = now;
    } else {
      ref.read(transactionStartDateProvider.notifier).state = null;
      ref.read(transactionEndDateProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final searchQuery = ref.watch(transactionSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Hari Ini'),
                  selected: _selectedFilterIndex == 0,
                  onSelected: (_) => _applyFilter(0),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('7 Hari Terakhir'),
                  selected: _selectedFilterIndex == 1,
                  onSelected: (_) => _applyFilter(1),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('Bulan Ini'),
                  selected: _selectedFilterIndex == 2,
                  onSelected: (_) => _applyFilter(2),
                ),
                const SizedBox(width: AppSpacing.xs),
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _selectedFilterIndex == 3,
                  onSelected: (_) => _applyFilter(3),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nomor invoice (INV/...)...',
                prefixIcon: const Icon(AppIcons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close, size: 18),
                        onPressed: () =>
                            ref.read(transactionSearchProvider.notifier).state =
                                '',
                      )
                    : null,
              ),
              onChanged: (val) =>
                  ref.read(transactionSearchProvider.notifier).state = val,
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (txList) {
                final filtered = searchQuery.isEmpty
                    ? txList
                    : txList
                          .where(
                            (t) => t.invoiceNumber.toLowerCase().contains(
                              searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: AppIcons.history,
                    title: 'Tidak Ada Transaksi',
                    description:
                        'Belum ada data transaksi pada periode yang dipilih.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    final isCash = tx.paymentMethod == PaymentMethod.cash;

                    return Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(60),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isCash
                              ? AppColors.success.withAlpha(30)
                              : theme.colorScheme.primaryContainer,
                          child: Icon(
                            isCash ? AppIcons.cash : AppIcons.qris,
                            color: isCash
                                ? AppColors.success
                                : theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.invoiceNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormatter.formatFriendly(tx.createdAt)} • ${tx.items.length} item',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                CurrencyFormatter.format(tx.totalAmount),
                                style: AppTypography.priceStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            Text(
                              tx.paymentMethod.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  140,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => TransactionDetailModal.show(context, tx),
                      ),
                    );
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
