# ARCHITECTURE — Design Pattern & Struktur Teknis

> Ditujukan untuk AI coding assistant yang akan mengimplementasikan kode. Ikuti pola ini secara konsisten di setiap fitur baru — jangan menyimpang tanpa alasan kuat yang didokumentasikan di `DEVELOPMENT_PROCESS.md`.

## 1. Pattern Utama: Clean Architecture + Feature-First

Kita pakai **Clean Architecture** (3 layer: presentation, domain, data) dikombinasikan dengan **feature-first folder structure** (bukan layer-first di root). Alasan:

- Layer-first murni (`lib/models`, `lib/screens`, `lib/services` semua di root) cepat berantakan begitu fitur bertambah — sulit tahu file mana milik fitur mana.
- Feature-first + Clean Architecture di dalam tiap fitur memberi **navigasi kode yang jelas** (semua tentang "transaksi" ada di satu folder) sekaligus **testability tinggi** (domain layer tidak tahu soal Flutter/UI sama sekali, gampang di-unit-test).

### Kenapa bukan MVC/MVVM polos?
MVC/MVVM sering mencampur business logic dengan state management framework tertentu, sehingga sulit ganti state management atau data source tanpa menulis ulang logic. Clean Architecture memisahkan **aturan bisnis (domain)** dari **detail teknis (data, presentation)** — domain layer murni Dart, tidak import Flutter maupun Riverpod.

## 2. Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, routing root
│   ├── router.dart              # go_router configuration
│   └── theme/                   # lihat DESIGN_SYSTEM.md
├── core/
│   ├── constants/
│   ├── errors/                  # Failure classes, exceptions
│   ├── utils/                   # formatters (currency, date), validators
│   ├── network/                 # connectivity checker
│   └── widgets/                 # shared widgets lintas fitur (buttons, dialogs)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/     # remote (Supabase) & local (secure storage)
│   │   │   ├── models/          # DTO, extends/maps ke entity
│   │   │   └── repositories/    # implementasi repository
│   │   ├── domain/
│   │   │   ├── entities/        # pure Dart class, tidak ada anotasi
│   │   │   ├── repositories/    # abstract class (interface)
│   │   │   └── usecases/        # 1 class = 1 aksi bisnis (LoginUseCase, dst)
│   │   └── presentation/
│   │       ├── providers/       # Riverpod providers/notifiers
│   │       ├── screens/
│   │       └── widgets/
│   ├── products/                # struktur sama seperti auth
│   ├── cart/
│   ├── transactions/
│   ├── dashboard/
│   ├── inventory/
│   └── settings/
└── l10n/                        # disiapkan untuk i18n masa depan (out-of-scope v1, tapi struktur ada)
```

**Aturan ketat:**
- `domain/` tidak boleh import package Flutter (`material.dart`), Riverpod, atau Drift. Domain adalah Dart murni.
- `presentation/` tidak boleh langsung memanggil `data/` — harus lewat `domain/usecases` via provider.
- Setiap fitur punya `domain/repositories/xxx_repository.dart` (abstract) yang diimplementasikan di `data/repositories/xxx_repository_impl.dart`. Ini memungkinkan swap data source (mis. ganti Drift ke Isar) tanpa menyentuh domain/presentation.

## 3. State Management: Riverpod (bukan GetX/Bloc/Provider polos)

**Kenapa Riverpod:**
- Compile-safe (tidak ada `context.read` yang crash runtime karena provider tidak ditemukan)
- Testable tanpa `BuildContext` — cocok untuk unit test domain-adjacent logic
- `AsyncNotifier`/`AsyncValue` menangani loading/error/data state dengan rapi, pas untuk pola offline-first (loading dari lokal dulu, lalu update saat sync selesai)
- Riverpod adalah state management paling relevan untuk role senior Flutter saat ini — menunjukkan familiaritas dengan tooling modern, dibanding GetX yang dianggap kurang scalable untuk tim besar

**Pola pemakaian:**
- `Notifier`/`AsyncNotifier` untuk state yang berubah (keranjang, form produk)
- `Provider`/`FutureProvider` untuk data read-only turunan (total harga keranjang dihitung dari state cart)
- Gunakan `riverpod_generator` (`@riverpod` annotation) untuk konsistensi dan mengurangi boilerplate

## 4. Local Database: Drift (bukan Hive/Isar)

**Kenapa Drift, bukan Hive:**
- POS butuh **query relasional** (join transaksi dengan item transaksi dengan produk, filter by tanggal, agregasi untuk dashboard). Hive adalah key-value store — bisa dipaksakan tapi query kompleks jadi manual dan rawan bug.
- Drift dibangun di atas SQLite (battle-tested untuk data transaksional), punya **type-safety** penuh (compile-time check untuk query), dan mendukung **migration** terstruktur — penting karena skema produk/transaksi akan berkembang.
- Drift mendukung **reactive streams** (`watch()` query) yang align sempurna dengan Riverpod `StreamProvider` — begitu data lokal berubah, UI otomatis update.

**Kenapa bukan Isar** (alternatif NoSQL lokal yang juga populer): Isar lebih cepat untuk read-heavy tanpa relasi kompleks, tapi POS punya kebutuhan relasi & agregasi (laporan, join) yang lebih natural di model relasional. Drift juga lebih mudah di-mapping 1:1 ke skema Postgres di Supabase saat sinkronisasi, karena sama-sama SQL.

### Skema inti (ringkas)
- `products` (id, name, price, category_id, stock, image_path, unit, created_at, updated_at, is_synced)
- `categories` (id, name)
- `transactions` (id, total, payment_method, cash_received, change, created_at, is_synced)
- `transaction_items` (id, transaction_id, product_id, qty, price_at_sale)
- `stores` (id, name, logo_path, currency) — single row untuk v1

Kolom `is_synced` (boolean) + `updated_at` di setiap tabel yang perlu sync adalah pola standar **offline-first sync**: baris dengan `is_synced = false` adalah antrian yang perlu dikirim ke Supabase saat online.

## 5. Strategi Sync (Offline-First)

Pola: **local-first, sync-when-possible**, bukan **online-first-with-cache**.

1. Semua write (tambah produk, transaksi baru) langsung ke Drift lokal → UI update instan (tidak menunggu network)
2. Baris baru/berubah ditandai `is_synced = false`
3. `SyncService` (di `core/`, dipanggil dari background via `connectivity_plus` listener + retry saat app resume) mengirim baris yang belum sync ke Supabase
4. Konflik: strategi **last-write-wins berbasis `updated_at`** untuk v1 (cukup untuk single-tenant, single-device-primary; konflik multi-device jadi catatan `v2` di `DEVELOPMENT_PROCESS.md`, tidak perlu diselesaikan sekarang)
5. Sync gagal → retry silent, tidak mengganggu UI, tapi ada indikator kecil non-intrusif (lihat `DESIGN_SYSTEM.md` §Offline Indicator)

## 6. Navigasi: go_router

- Deklaratif, mendukung deep-link, dan memudahkan **adaptive layout** (lihat §7) karena bisa cek ukuran layar di level `ShellRoute` untuk menentukan apakah pakai `NavigationBar` (phone) atau `NavigationRail` (tablet landscape).

## 7. Adaptive/Responsive Layout Strategy

Lihat detail visual di `DESIGN_SYSTEM.md`. Dari sisi arsitektur kode:

- Gunakan `LayoutBuilder` / `MediaQuery.sizeOf(context)` di level screen untuk menentukan breakpoint, **bukan** package device-detection pihak ketiga yang berat — cukup native Flutter.
- Breakpoint dasar (disepakati, dipakai konsisten di seluruh app):
  - `compact` (< 600dp lebar) — phone portrait
  - `medium` (600–839dp) — phone landscape / tablet kecil portrait
  - `expanded` (≥ 840dp) — tablet landscape / tablet besar
- Widget layout wajib pakai `Flex`, `Row`+`Expanded`/`Flexible`, `Wrap`, atau `GridView` dengan `SliverGridDelegateWithMaxCrossAxisExtent` (bukan `crossAxisCount` fixed) supaya grid produk otomatis menyesuaikan jumlah kolom berdasarkan lebar layar, bukan hardcode per breakpoint.
- Halaman Kasir: `compact` → grid produk full-width dengan cart sebagai bottom sheet; `expanded` → grid produk di kiri (`Expanded(flex: 2)`) + panel keranjang permanen di kanan (`Expanded(flex: 1)`), side-by-side dalam satu `Row`.

## 8. Dependency Injection

Riverpod sendiri berfungsi sebagai DI container (provider = dependency). Tidak perlu `get_it` terpisah kecuali untuk service yang harus diakses di luar widget tree (mis. background sync isolate) — jika dibutuhkan, dokumentasikan alasannya saat itu terjadi.

## 9. Error Handling

- `core/errors/failure.dart`: sealed class `Failure` (`NetworkFailure`, `CacheFailure`, `ValidationFailure`, dst)
- Repository selalu return `Either<Failure, T>` (pakai package `fpdart` atau `dartz`) atau `Result<T>` custom — pilih salah satu di awal implementasi dan konsisten. Rekomendasi: `Result<T>` custom sealed class agar tidak menambah dependency besar hanya untuk Either.
- UI tidak pernah menampilkan raw exception message ke user — selalu mapping ke pesan ramah Bahasa Indonesia.

## 10. Package Inti yang Dipakai (dan alasannya singkat)

| Package | Fungsi | Kenapa |
|---|---|---|
| `flutter_riverpod` + `riverpod_generator` | State management | Lihat §3 |
| `drift` + `sqlite3_flutter_libs` | Local DB | Lihat §4 |
| `go_router` | Navigasi | Deklaratif, adaptive-friendly |
| `supabase_flutter` | Backend (auth, sync, storage) | Selaras dengan versi web, satu backend |
| `connectivity_plus` | Deteksi online/offline | Trigger sync |
| `cached_network_image` | Gambar produk dari URL dengan cache | Performa grid produk |
| `phosphor_flutter` atau `lucide_icons` | Icon set custom (bukan cuma Material default) | Lihat `DESIGN_SYSTEM.md` §Icons |
| `intl` | Format mata uang & tanggal Indonesia | Wajib untuk POS lokal |
| `mocktail` | Mocking untuk testing | Lihat `TESTING.md` |
