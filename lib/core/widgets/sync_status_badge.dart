import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum SyncStatus { synced, syncing, offline }

/// Indikator offline/sync non-intrusive di pojok AppBar sesuai DESIGN_SYSTEM.md §7
class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onTap;

  const SyncStatusBadge({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color dotColor;
    String label;
    switch (status) {
      case SyncStatus.synced:
        dotColor = AppColors.success;
        label = 'Tersinkron';
        break;
      case SyncStatus.syncing:
        dotColor = AppColors.warning;
        label = 'Menyinkronkan...';
        break;
      case SyncStatus.offline:
        dotColor = theme.colorScheme.outline;
        label = 'Mode Offline';
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedFull,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
          borderRadius: AppRadius.roundedFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
