import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/category_manage_dialog.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? initialProduct;

  const ProductFormScreen({super.key, this.initialProduct});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _unitController;
  late final TextEditingController _barcodeController;

  String? _selectedCategoryId;
  String? _imagePath;
  bool _isLoading = false;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toInt().toString() : '');
    _costPriceController = TextEditingController(text: p != null && p.costPrice > 0 ? p.costPrice.toInt().toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '0');
    _minStockController = TextEditingController(text: p != null ? p.minStockAlert.toString() : '5');
    _unitController = TextEditingController(text: p?.unit ?? 'pcs');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _selectedCategoryId = p?.categoryId;
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(AppIcons.camera),
                  title: const Text('Ambil Foto dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.image),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_imagePath != null)
                  ListTile(
                    leading: const Icon(AppIcons.delete, color: Colors.red),
                    title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _imagePath = null);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final product = Product(
      id: widget.initialProduct?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      costPrice: double.tryParse(_costPriceController.text.trim()) ?? 0.0,
      categoryId: _selectedCategoryId,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      minStockAlert: int.tryParse(_minStockController.text.trim()) ?? 5,
      unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      imagePath: _imagePath,
      createdAt: widget.initialProduct?.createdAt ?? now,
      updatedAt: now,
    );

    final controller = ref.read(productControllerProvider.notifier);
    final success = _isEditing
        ? await controller.updateProduct(product)
        : await controller.createProduct(product);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppSnackbar.showSuccess(
          context,
          _isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
        );
        context.pop();
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan produk');
      }
    }
  }

  Future<void> _delete() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus produk "${widget.initialProduct!.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final success = await ref.read(productControllerProvider.notifier).deleteProduct(widget.initialProduct!.id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          AppSnackbar.showSuccess(context, 'Produk berhasil dihapus');
          context.pop();
        } else {
          AppSnackbar.showError(context, 'Gagal menghapus produk');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk Baru'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(AppIcons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: AppRadius.roundedMd,
                                border: Border.all(color: theme.colorScheme.outlineVariant),
                              ),
                              child: _imagePath != null
                                  ? ClipRRect(
                                      borderRadius: AppRadius.roundedMd,
                                      child: Image.file(
                                        File(_imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(AppIcons.camera, size: 32, color: theme.colorScheme.primary),
                                        const SizedBox(height: 4),
                                        Text('Pilih Foto', style: theme.textTheme.labelSmall),
                                      ],
                                    ),
                            ),
                          ),
                          if (_imagePath != null)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => setState(() => _imagePath = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(AppIcons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk *',
                        hintText: 'Contoh: Es Kopi Susu / Beras 5kg',
                      ),
                      validator: (val) => AppValidator.required(val, 'Nama produk'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: categoriesAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const Text('Gagal memuat kategori'),
                            data: (categories) {
                              return DropdownButtonFormField<String?>(
                                initialValue: _selectedCategoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Kategori (Opsional)',
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('Tanpa Kategori')),
                                  ...categories.map(
                                    (cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)),
                                  ),
                                ],
                                onChanged: (val) => setState(() => _selectedCategoryId = val),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton.filledTonal(
                          icon: const Icon(AppIcons.add),
                          tooltip: 'Tambah Kategori',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const CategoryManageDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga Jual (Rp) *',
                              prefixText: 'Rp ',
                            ),
                            validator: (val) => AppValidator.positiveNumber(val, 'Harga jual'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _costPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga Modal (Rp)',
                              prefixText: 'Rp ',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Stok *',
                            ),
                            validator: (val) => AppValidator.nonNegativeNumber(val, 'Stok'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _minStockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Batas Stok Tipis',
                              hintText: '5',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Satuan',
                              hintText: 'pcs/kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode / SKU (Opsional)',
                        prefixIcon: Icon(AppIcons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppPrimaryButton(
                      text: _isEditing ? 'Simpan Perubahan' : 'Simpan Produk',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
