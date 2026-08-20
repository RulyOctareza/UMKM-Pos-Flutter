import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_icons.dart';

/// Numpad kustom POS untuk input uang tunai cepat tanpa membuka keyboard sistem
class CustomNumpad extends StatelessWidget {
  final double totalAmount;
  final ValueChanged<double> onAmountChanged;
  final double currentAmount;

  const CustomNumpad({
    super.key,
    required this.totalAmount,
    required this.currentAmount,
    required this.onAmountChanged,
  });

  void _onDigitPressed(String digit) {
    final currentStr = currentAmount.toInt().toString();
    String newStr;
    if (currentAmount == 0) {
      newStr = digit;
    } else {
      newStr = currentStr + digit;
    }
    if (newStr.length <= 12) {
      onAmountChanged(double.tryParse(newStr) ?? 0.0);
    }
  }

  void _onBackspace() {
    final currentStr = currentAmount.toInt().toString();
    if (currentStr.length <= 1) {
      onAmountChanged(0.0);
    } else {
      final newStr = currentStr.substring(0, currentStr.length - 1);
      onAmountChanged(double.tryParse(newStr) ?? 0.0);
    }
  }

  void _onClear() {
    onAmountChanged(0.0);
  }

  Widget _buildNumpadButton({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
    IconData? icon,
    Color? bgColor,
    Color? fgColor,
  }) {
    final theme = Theme.of(context);
    final bg = bgColor ?? theme.colorScheme.surface;
    final fg = fgColor ?? theme.colorScheme.onSurface;

    return Material(
      color: bg,
      borderRadius: AppRadius.roundedMd,
      elevation: 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(60),
            ),
          ),
          child: icon != null
              ? Icon(icon, color: fg, size: 22)
              : Text(
                  text,
                  style: AppTypography.priceStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQuickNominalChip(
    BuildContext context,
    double amount,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentAmount == amount;

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      backgroundColor: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedFull),
      onPressed: () => onAmountChanged(amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Nominal Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickNominalChip(context, totalAmount, 'Uang Pas'),
              const SizedBox(width: AppSpacing.xs),
              _buildQuickNominalChip(context, 10000, '10.000'),
              const SizedBox(width: AppSpacing.xs),
              _buildQuickNominalChip(context, 20000, '20.000'),
              const SizedBox(width: AppSpacing.xs),
              _buildQuickNominalChip(context, 50000, '50.000'),
              const SizedBox(width: AppSpacing.xs),
              _buildQuickNominalChip(context, 100000, '100.000'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Grid Numpad
        Table(
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '1',
                    onTap: () => _onDigitPressed('1'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '2',
                    onTap: () => _onDigitPressed('2'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '3',
                    onTap: () => _onDigitPressed('3'),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '4',
                    onTap: () => _onDigitPressed('4'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '5',
                    onTap: () => _onDigitPressed('5'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '6',
                    onTap: () => _onDigitPressed('6'),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '7',
                    onTap: () => _onDigitPressed('7'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '8',
                    onTap: () => _onDigitPressed('8'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '9',
                    onTap: () => _onDigitPressed('9'),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: 'C',
                    onTap: _onClear,
                    fgColor: theme.colorScheme.error,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '0',
                    onTap: () => _onDigitPressed('0'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '',
                    icon: AppIcons.back,
                    onTap: _onBackspace,
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '00',
                    onTap: () => _onDigitPressed('00'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: '000',
                    onTap: () => _onDigitPressed('000'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _buildNumpadButton(
                    context: context,
                    text: 'Pas',
                    bgColor: theme.colorScheme.primaryContainer,
                    fgColor: theme.colorScheme.onPrimaryContainer,
                    onTap: () => onAmountChanged(totalAmount),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
