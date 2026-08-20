# PRD — UMKM POS (Flutter Mobile/Tablet App)

> Dokumen ini ditulis untuk dibaca dan dipahami oleh AI coding assistant (mis. Claude Code) maupun manusia. Setiap keputusan disertai alasan ("why"), bukan cuma "what", supaya AI yang membaca bisa membuat keputusan konsisten saat implementasi detail yang tidak dijabarkan eksplisit di sini.

## 1. Ringkasan Produk

**Nama kerja:** UMKM POS (Flutter Edition)
**Tipe:** Aplikasi kasir (Point of Sale) offline-first, mobile & tablet
**Tujuan:** Portofolio senior-level Flutter developer, sekaligus aplikasi yang benar-benar layak dipakai UMKM asli (toko kelontong, cafe, laundry, sparepart, dll — non-spesifik industri, generik untuk retail/jasa skala kecil).
**Platform:** Android & iOS, phone & tablet, portrait & landscape.
**Relasi dengan proyek lain:** Adik-kandung dari `UMKM POS` versi web (Next.js PWA). Backend (Supabase — Postgres, Auth, Storage) dirancang agar bisa dipakai bersama oleh kedua versi di masa depan, tapi versi Flutter ini **berdiri sendiri** dan tidak wajib menunggu integrasi backend selesai untuk dianggap "selesai" sebagai portofolio.

## 2. Target Pengguna & Persona

| Persona | Kebutuhan Utama | Implikasi Desain |
|---|---|---|
| Pemilik toko kelontong (40-an, awam teknologi) | Cepat input transaksi, tidak mau ribet | UI besar, minim langkah, numpad custom |
| Kasir cafe/warung (18-25 tahun, terbiasa HP) | Transaksi cepat saat ramai (rush hour) | Grid produk visual, animasi ringan tidak menghambat kecepatan |
| Pemilik yang cek laporan di rumah (pakai tablet) | Lihat ringkasan penjualan harian/mingguan | Layout landscape tablet dioptimalkan untuk dashboard |

## 3. Prinsip Produk (Parameter Kualitas — WAJIB dipegang di setiap keputusan desain/kode)

1. **Useful** — setiap fitur harus menyelesaikan masalah nyata UMKM, bukan fitur pamer. Kalau ragu, tanya: "apakah kasir toko kelontong akan pakai ini tiap hari?"
2. **Friendly to use** — maksimal 3 tap untuk transaksi paling umum (pilih produk → bayar → selesai). Tidak ada jargon teknis di UI ("sync", "cache", "endpoint" dilarang muncul di layar user).
3. **Good animation** — animasi harus **fungsional** (memberi feedback, mengarahkan perhatian), bukan dekoratif semata. Durasi 150–300ms untuk micro-interaction, tidak boleh menghalangi kecepatan kerja kasir.
4. **Simple** — MVP dulu, fitur kompleks (multi-cabang, multi-user role granular, laporan pajak) masuk backlog `v2`, bukan `v1`.
5. **Clean** — kode dan visual sama-sama harus clean: whitespace cukup, hierarki visual jelas, kode mengikuti Clean Architecture (lihat `ARCHITECTURE.md`).
6. **Responsive** — satu codebase untuk phone & tablet, portrait & landscape, tanpa breakpoint hack yang rapuh. Lihat `DESIGN_SYSTEM.md` §Responsive.

## 4. Scope

### 4.1 In-Scope (v1 — MVP Portofolio)

- **Autentikasi sederhana**: login toko (email/password via Supabase Auth), single-tenant per install (1 toko = 1 akun utama, boleh multi-kasir dengan PIN sederhana — bukan role-based access yang kompleks)
- **Manajemen produk**: CRUD produk (nama, harga, kategori, foto, stok, satuan)
- **Kasir / Transaksi**: pilih produk → keranjang → hitung total → metode bayar (tunai, dengan input kembalian otomatis; QRIS/non-tunai sebagai flag manual, tanpa integrasi payment gateway real di v1) → simpan transaksi → cetak/bagikan struk (PDF atau share text)
- **Riwayat transaksi**: list transaksi, detail per transaksi, filter tanggal
- **Dashboard ringkas**: total penjualan hari ini, jumlah transaksi, produk terlaris (grafik sederhana)
- **Manajemen stok dasar**: stok berkurang otomatis saat transaksi, notifikasi stok menipis
- **Mode offline-first**: semua fitur di atas berfungsi penuh tanpa internet, data tersimpan lokal (Drift/SQLite)
- **Sinkronisasi cloud**: sync manual/otomatis ke Supabase saat online (best-effort, bukan real-time critical)
- **Onboarding**: setup toko pertama kali (nama toko, logo, mata uang — default IDR)
- **Pengaturan**: profil toko, kelola kategori, backup/restore data lokal

### 4.2 Out-of-Scope (v1) — eksplisit didokumentasikan supaya AI tidak "membantu lebih" dan melebar

- Multi-cabang / multi-outlet
- Role-based access control granular (admin/kasir/manager dengan permission matrix)
- Integrasi payment gateway sungguhan (Midtrans, Xendit, dll)
- Cetak struk ke thermal printer fisik via Bluetooth (bisa jadi v2 — cukup export/share PDF di v1)
- Laporan pajak/akuntansi kompleks
- Multi-bahasa (v1 Bahasa Indonesia saja, arsitektur i18n disiapkan tapi tidak diisi penuh)
- Fitur AI/rekomendasi produk

## 5. User Flow Utama (harus mulus, ini yang dites paling ketat)

### Flow A — Transaksi Baru (paling sering dipakai)
1. Kasir buka app → langsung di halaman **Kasir** (halaman utama, bukan dashboard)
2. Tap produk di grid → masuk ke keranjang (badge cart animasi)
3. Ulangi untuk produk lain, atau tap produk yang sama untuk tambah qty
4. Tap tombol "Bayar" → muncul ringkasan total
5. Pilih metode bayar → jika tunai, input uang diterima → sistem hitung kembalian otomatis
6. Konfirmasi → transaksi tersimpan → opsi cetak/bagikan struk → kembali ke halaman Kasir (keranjang kosong)

### Flow B — Tambah Produk Baru
1. Dari halaman Produk → tombol tambah (FAB)
2. Isi form: nama, harga, kategori (dropdown/chip), foto (ambil kamera/galeri, opsional), stok awal
3. Simpan → produk langsung muncul di grid Kasir

### Flow C — Cek Laporan Harian
1. Dari Dashboard → lihat ringkasan hari ini
2. Tap "Lihat semua transaksi" → list dengan filter tanggal

## 6. Requirement Non-Fungsional

- **Performa**: grid produk harus tetap smooth (60fps) walau ada 200+ produk dengan gambar — gunakan lazy loading & image caching
- **Offline-first**: tidak boleh ada state di mana user "terkunci" karena tidak ada internet
- **Data safety**: transaksi tidak boleh hilang meski app crash di tengah proses (gunakan transaction lock di DB lokal)
- **Aksesibilitas**: target tap minimal 48x48dp, kontras warna minimal WCAG AA
- **Device support**: Android 8+ / iOS 13+, phone (~5.5"–6.9") dan tablet (~8"–12.9"), portrait & landscape keduanya harus punya layout yang dirancang sengaja (bukan cuma auto-stretch)

## 7. Metrik Keberhasilan (untuk konteks portofolio, bukan metrik bisnis riil)

- Demo video 60–90 detik menunjukkan flow A tanpa hambatan
- Code coverage testing > 70% untuk domain & data layer (lihat `TESTING.md`)
- README + docs cukup lengkap sehingga developer lain (atau AI) bisa onboarding dan paham keputusan arsitektur dalam < 10 menit baca

## 8. Roadmap Dokumen Terkait

- `ARCHITECTURE.md` — design pattern, folder structure, state management, offline sync strategy
- `DESIGN_SYSTEM.md` — design tokens, komponen, responsive rules, ikon, animasi, sumber gambar
- `TESTING.md` — strategi testing per layer
- `DEVELOPMENT_PROCESS.md` — log proses & keputusan (living document)
