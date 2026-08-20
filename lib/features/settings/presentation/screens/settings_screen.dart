import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/theme_provider.dart';
import '../../../../core/database/data_seeder.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/app_icons.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/onboarding_screen.dart';
import '../../../products/presentation/widgets/category_manage_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _seedDemoData(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Muat Data Contoh UMKM?'),
        content: const Text(
          'Aplikasi akan diisi dengan data contoh Coffee Shop & Bakery (Profil Toko, Kategori, 8 Produk dengan status stok, dan 2 Riwayat Transaksi Penjualan).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Muat Data Demo'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await DataSeeder.seedDemoData(db);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Data demo UMKM berhasil dimuat!');
      }
    }
  }

  Future<void> _resetAllData(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset & Hapus Semua Data?'),
        content: const Text(
          'Seluruh produk, kategori, riwayat transaksi, dan profil toko lokal akan dihapus bersih.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final db = ref.read(databaseProvider);
      await DataSeeder.clearAllData(db);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Database lokal berhasil dikosongkan.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final store = ref.watch(storeProfileStreamProvider).value;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Section: Profil Toko
          Text(
            'Toko',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      AppIcons.store,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    store?.name ?? 'Belum Diatur',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    store?.address ?? 'Tap untuk mengatur alamat & profil toko',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(AppIcons.filter),
                  title: const Text('Kelola Kategori Produk'),
                  subtitle: const Text(
                    'Tambah dan hapus kategori katalog',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CategoryManageDialog(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section: Tampilan & Preferensi
          Text(
            'Preferensi',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('Mode Gelap (Dark Mode)'),
                  subtitle: const Text(
                    'Ubah tampilan layar menjadi gelap',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(
                          isDark ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section: Data & Backup
          Text(
            'Data & Database',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(AppIcons.sync),
                  title: const Text('Status Database'),
                  subtitle: const Text(
                    'Tersimpan lokal di perangkat (Drift / SQLite)',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_for_offline_outlined, color: Colors.teal),
                  title: const Text('Muat Data Demo UMKM', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                    'Isi contoh menu coffee shop, stok & riwayat transaksi',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                  onTap: () => _seedDemoData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  title: const Text('Reset Semua Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text(
                    'Hapus bersih seluruh data database lokal',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.red),
                  onTap: () => _resetAllData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section: Info Aplikasi
          Text(
            'Tentang Aplikasi',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedMd,
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('UMKM POS (Flutter Edition)'),
                  subtitle: Text(
                    'Versi 1.0.0 • Clean Architecture + Drift + Riverpod',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Lisensi Open Source'),
                  subtitle: Text('MIT License', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
