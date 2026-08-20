import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/category.dart';
import '../providers/product_providers.dart';

class CategoryManageDialog extends ConsumerStatefulWidget {
  const CategoryManageDialog({super.key});

  @override
  ConsumerState<CategoryManageDialog> createState() =>
      _CategoryManageDialogState();
}

class _CategoryManageDialogState extends ConsumerState<CategoryManageDialog> {
  final _nameController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final newCat = Category(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );

    final success = await ref
        .read(productControllerProvider.notifier)
        .createCategory(newCat);
    if (mounted) {
      if (success) {
        _nameController.clear();
        setState(() => _isAdding = false);
        AppSnackbar.showSuccess(
          context,
          'Kategori "$name" berhasil ditambahkan',
        );
      } else {
        AppSnackbar.showError(context, 'Gagal menambahkan kategori');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelola Kategori',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),

              // Form Tambah Kategori
              if (_isAdding) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Nama Kategori Baru',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      icon: const Icon(AppIcons.check, size: 20),
                      onPressed: _addCategory,
                    ),
                    IconButton(
                      icon: const Icon(AppIcons.close, size: 20),
                      onPressed: () => setState(() => _isAdding = false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ] else ...[
                OutlinedButton.icon(
                  icon: const Icon(AppIcons.add, size: 18),
                  label: const Text('Tambah Kategori'),
                  onPressed: () => setState(() => _isAdding = true),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // List Kategori
              Expanded(
                child: categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada kategori.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
