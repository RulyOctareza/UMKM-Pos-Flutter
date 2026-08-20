import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_icons.dart';

/// Stepper kuantitas +/- dengan AnimatedSwitcher slide transition sesuai DESIGN_SYSTEM.md §7 & §10
class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: AppRadius.roundedFull,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol Kurang
          IconButton(
            icon: Icon(
              value <= min ? AppIcons.delete : AppIcons.subtract,
              size: 18,
              color: value <= min
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          // Angka Kuantitas dengan Animasi Slide
          SizedBox(
            width: 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '$value',
                key: ValueKey<int>(value),
                textAlign: TextAlign.center,
                style: AppTypography.priceStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Tombol Tambah
          IconButton(
            icon: Icon(
              AppIcons.add,
              size: 18,
              color: value >= max
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
