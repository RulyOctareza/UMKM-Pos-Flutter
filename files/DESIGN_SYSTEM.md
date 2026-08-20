# DESIGN SYSTEM — UMKM POS

> Semua nilai di dokumen ini adalah **token tunggal sumber kebenaran**. Jangan hardcode warna/spacing/radius langsung di widget — selalu referensi lewat `app/theme/`.

## 1. Prinsip Visual

Selaras dengan §3 PRD: **simple, clean, friendly, useful**, dengan animasi fungsional. Visual harus terasa modern-minimal (bukan flat kosong, bukan skeuomorphic ramai) — mendekati bahasa desain Material 3 tapi dengan personality warna sendiri, bukan default ungu Material out-of-the-box (supaya tidak terlihat generik/template).

## 2. Color Tokens

Struktur warna mengikuti Material 3 color roles (supaya otomatis dapat dukungan dark mode & dynamic theming dari Flutter), dengan seed color kustom.

```dart
// app/theme/app_colors.dart
class AppColors {
  static const seed = Color(0xFF0D9488); // teal — asosiasi trust, uang, "hijau tapi tidak klise"
  // Semantic tokens (dipakai di seluruh app, JANGAN pakai Colors.red dsb langsung)
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger  = Color(0xFFDC2626);
  static const info    = Color(0xFF2563EB);
}
```

- Gunakan `ColorScheme.fromSeed(seedColor: AppColors.seed)` sebagai basis, lalu override role tertentu jika perlu kontras lebih di komponen kasir (tombol "Bayar" harus punya warna paling menonjol di layar).
- Kontras minimal WCAG AA (4.5:1 untuk teks normal, 3:1 untuk teks besar/ikon).
- Dark mode: didukung dari awal karena `ColorScheme.fromSeed` otomatis generate varian dark — tidak butuh effort tambahan besar, jadi tidak ada alasan skip.

## 3. Typography

- Font: **Plus Jakarta Sans** atau **Inter** via `google_fonts` package — lebih modern dan "friendly" dibanding Roboto default, tetap sangat legible di ukuran kecil (penting untuk struk/angka).
- Skala mengikuti Material 3 type scale (`displayLarge` s/d `labelSmall`), tapi 2 aturan khusus POS:
  - Angka harga/total di layar Kasir & struk pakai **tabular figures** (`FontFeature.tabularFigures()`) supaya digit sejajar rapi — penting untuk kolom angka.
  - Ukuran font dasar dinaikkan 1 step dari default Material di komponen yang dipakai kasir sambil berdiri/buru-buru (tombol besar, harga produk) — aksesibilitas dan kecepatan baca.

## 4. Spacing & Sizing

Gunakan skala 4pt (kelipatan 4), didefinisikan sebagai konstanta:

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

- Radius: `AppRadius.sm = 8`, `AppRadius.md = 12`, `AppRadius.lg = 16`, `AppRadius.full = 999` (pill button/chip)
- Target sentuh minimal **48x48dp** untuk semua elemen interaktif (checklist aksesibilitas dari PRD §6)

## 5. Elevation & Shadow

Pakai elevation Material 3 tokens (level 0–5), hindari shadow custom manual kecuali untuk kartu produk (elevation halus level 1, naik ke level 2 saat ditekan — feedback tactile).

## 6. Responsive Design — Aturan Wajib

Selaras dengan `ARCHITECTURE.md` §7. Aturan konkret di level widget:

1. **Dilarang** `SizedBox(width: 400)` hardcode untuk lebar konten utama. Gunakan `Expanded`/`Flexible` di dalam `Row`/`Column`, atau `ConstrainedBox` dengan `maxWidth` sebagai *batas atas* saja (bukan fixed).
2. Grid produk: `GridView.builder` dengan `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md)` — kolom otomatis menyesuaikan, tidak pernah hardcode `crossAxisCount`.
3. Orientasi:
   - **Portrait (phone/tablet)**: navigasi bawah (`NavigationBar`), konten 1 kolom utama, keranjang sebagai bottom sheet draggable.
   - **Landscape / expanded width**: navigasi kiri (`NavigationRail`), halaman Kasir jadi 2 panel (`Row` dengan `Expanded(flex: 2)` grid produk + `Expanded(flex: 1)` panel keranjang permanen, dipisah `VerticalDivider`).
4. Gunakan `OrientationBuilder` di halaman Kasir khususnya (halaman paling sering dipakai) untuk switch layout builder, sedangkan halaman lain (Produk, Riwayat, Pengaturan) cukup adaptif lewat breakpoint lebar biasa.
5. Test wajib di 4 kombinasi minimal: phone-portrait, phone-landscape, tablet-portrait, tablet-landscape (lihat `TESTING.md` §Golden Test).

## 7. Component Library (custom, di atas Material 3)

Semua komponen berikut dibuat sebagai shared widget di `core/widgets/`:

- `AppPrimaryButton` — tombol utama (mis. "Bayar"), full-width di compact, auto-width di expanded, dengan animasi scale-down halus saat ditekan (`AnimatedScale`, 100ms)
- `ProductCard` — kartu produk grid: gambar (rounded, `AppRadius.md`), nama, harga, indikator stok menipis (badge kecil warna `warning`)
- `QuantityStepper` — tombol +/- dengan animasi angka berubah (`AnimatedSwitcher` + slide transition)
- `CustomNumpad` — numpad besar custom untuk input uang tunai (bukan keyboard sistem — lebih cepat & tidak menutup layar penuh)
- `EmptyStateWidget` — ilustrasi + teks untuk state kosong (keranjang kosong, belum ada produk, dst) — ini tempat animasi/ilustrasi boleh lebih "hidup" karena tidak menghambat kecepatan kerja
- `SyncStatusBadge` — indikator offline/sync kecil, non-intrusive, di pojok app bar (titik warna: abu = offline, kuning berdenyut halus = syncing, hijau = tersync)
- `AppSnackbar` — snackbar konsisten untuk feedback aksi (termasuk pola undo transaksi dari PRD)

## 8. Icons — Custom Icon Package (bukan Icons.* Material default polos)

- Gunakan **`phosphor_flutter`** sebagai icon set utama. Alasan: Phosphor punya varian weight (thin/regular/bold/fill) yang konsisten dengan gaya "friendly-modern" yang ditarget, dan koleksinya jauh lebih lengkap untuk konteks retail (ikon kotak, struk, kalkulator, dompet, dll) dibanding Material Icons bawaan.
- Alternatif kedua yang boleh dipakai campuran untuk ikon navigasi utama: `lucide_icons` — lebih minimal/geometris, cocok untuk nav bar.
- Aturan: icon interaktif pakai weight `regular`/`bold`, icon status/dekoratif pakai `fill` untuk state aktif dan `regular` untuk inactive (pola umum bottom nav).
- Semua ikon dibungkus lewat `AppIcons` (`core/widgets/app_icons.dart`) supaya kalau ganti package suatu saat, cukup ubah satu file.

## 9. Images — Sumber Gambar Free

- Placeholder produk & ilustrasi empty-state: gunakan gambar bebas royalti dari **Unsplash** (`unsplash.com`) atau **Pexels** (`pexels.com`) — keduanya free untuk penggunaan komersial tanpa atribusi wajib (cek lisensi tiap file saat unduh untuk memastikan).
- Ilustrasi flat/spot illustration untuk onboarding & empty-state: **unDraw** (`undraw.co`) — gratis, bisa disesuaikan warnanya ke `AppColors.seed`, format SVG.
- Logo toko: diambil dari kamera/galeri user (bukan aset statis), disimpan lokal + Supabase Storage saat sync.
- Semua gambar remote di-load lewat `cached_network_image` dengan placeholder shimmer (bukan spinner polos) saat loading, dan fallback icon produk generik jika gagal load — jangan biarkan gambar rusak/broken-icon terlihat user.

## 10. Motion / Animation Guidelines

Sesuai prinsip PRD §3.3 (animasi fungsional, bukan dekoratif):

| Interaksi | Animasi | Durasi | Curve |
|---|---|---|---|
| Tap produk → masuk keranjang | Hero-like fly-to-cart / scale badge cart | 300ms | `easeOutCubic` |
| Tombol ditekan | Scale 0.96 | 100ms | `easeOut` |
| Ubah quantity | Angka slide/fade transition | 200ms | `easeInOut` |
| Transaksi sukses | Checkmark animasi (mis. via `lottie` ringan atau custom `AnimatedIcon`) | 500ms sekali, tidak looping | `easeOutBack` |
| Pindah tab/halaman | Shared axis transition (`animations` package) | 250ms | default M3 |
| List transaksi muncul | Staggered fade+slide per item saat scroll masuk pertama kali | 200ms per item, delay 30ms antar item | `easeOut` |
| Sync status berubah | Cross-fade badge warna | 200ms | `easeInOut` |

**Larangan:** animasi > 400ms di jalur transaksi utama (kasir tidak boleh menunggu animasi untuk lanjut kerja). Animasi dekoratif panjang hanya boleh di halaman non-critical (onboarding, empty state).

## 11. Dark Mode

Didukung penuh (lihat §2). Toggle di Pengaturan, default mengikuti system theme.

## 12. Accessibility Checklist

- Kontras AA minimum di semua teks
- `Semantics` label untuk tombol icon-only (mis. tombol hapus item keranjang)
- Target sentuh 48x48dp
- Mendukung font scaling sistem (`MediaQuery.textScalerOf`) tanpa layout pecah — ini juga alasan kenapa layout harus `Flexible`/`Expanded`, bukan fixed height/width
