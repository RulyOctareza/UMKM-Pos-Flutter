import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/database/data_seeder.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/store.dart';
import '../providers/auth_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final newStore = Store(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      pin: _pinController.text.trim().isEmpty
          ? null
          : _pinController.text.trim(),
      currency: 'IDR',
      createdAt: now,
      updatedAt: now,
    );

    final success = await ref
        .read(storeProfileNotifierProvider.notifier)
        .saveStore(newStore);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Toko berhasil disiapkan!');
        context.go('/pos');
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan profil toko');
      }
    }
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);
    await DataSeeder.seedDemoData(db);

    if (mounted) {
      setState(() => _isLoading = false);
      AppSnackbar.showSuccess(context, 'Data demo UMKM berhasil dimuat!');
      context.go('/pos');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(
                            120,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.store,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Selamat Datang di UMKM POS',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Atur nama dan detail toko Anda untuk mulai mencatat transaksi',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(160),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Toko *',
                        hintText: 'Contoh: Toko Berkah Jaya / Kopi Senja',
                        prefixIcon: Icon(AppIcons.store),
                      ),
                      validator: (val) =>
                          AppValidator.required(val, 'Nama toko'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp / Telp (Opsional)',
                        hintText: 'Contoh: 081234567890',
                        prefixIcon: Icon(AppIcons.phone),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Toko (Opsional)',
                        hintText: 'Alamat yang akan tercetak di struk',
                        prefixIcon: Icon(AppIcons.location),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'PIN Kunci Kasir (Opsional)',
                        hintText: '4–6 digit angka untuk proteksi',
                        prefixIcon: Icon(AppIcons.lock),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppPrimaryButton(
                      text: 'Mulai Sekarang',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.bolt, color: Colors.teal),
                      label: const Text('⚡ Coba Demo Instan (Data Contoh UMKM)'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.teal),
                      ),
                      onPressed: _isLoading ? null : _loadDemoData,
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
