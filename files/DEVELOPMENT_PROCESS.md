# DEVELOPMENT PROCESS — Log Proses & Keputusan

> Living document. Setiap keputusan besar (bukan detail implementasi kecil) dicatat di sini dengan format konsisten, supaya siapa pun (termasuk AI yang lanjut mengerjakan) paham **kenapa** sesuatu dipilih, bukan cuma **apa**. Ini juga jadi bahan mentah untuk artikel/case-study portofolio nantinya.

## Cara Pakai Dokumen Ini

Setiap entri baru ditambahkan di bagian **paling atas** (reverse chronological), format:

```
## [YYYY-MM-DD] Judul Keputusan
**Konteks:** masalah/situasi apa yang memicu keputusan ini
**Opsi yang dipertimbangkan:** list singkat
**Keputusan:** apa yang dipilih
**Alasan:** kenapa
**Trade-off yang diterima:** apa yang dikorbankan/risiko yang disadari
```

---

## [Fase Perencanaan] Keputusan Fondasi Proyek

**Konteks:** Proyek ini dibuat sebagai portofolio untuk naik level dari Flutter developer (~1 tahun pengalaman) ke level senior, sekaligus versi Flutter dari proyek `UMKM POS` yang sebelumnya hanya ada versi Next.js PWA.

**Opsi yang dipertimbangkan untuk state management:** Riverpod vs GetX vs Bloc vs Provider polos.
**Keputusan:** Riverpod (dengan code generation).
**Alasan:** Detail lengkap di `ARCHITECTURE.md` §3. Ringkas: compile-safety, testability tanpa `BuildContext`, dan relevansi industri saat ini untuk role senior.
**Trade-off yang diterima:** Learning curve lebih tinggi dibanding GetX bagi yang belum terbiasa; boilerplate code-gen butuh `build_runner` yang menambah waktu build saat development.

**Opsi yang dipertimbangkan untuk local database:** Drift vs Hive vs Isar vs sqflite polos.
**Keputusan:** Drift.
**Alasan:** Detail di `ARCHITECTURE.md` §4. Ringkas: butuh query relasional untuk laporan/dashboard, type-safety, reactive streams yang align dengan Riverpod.
**Trade-off yang diterima:** Setup awal (schema, code-gen) lebih berat dibanding Hive yang langsung pakai; tapi terbayar saat fitur laporan/agregasi bertambah kompleks.

**Opsi yang dipertimbangkan untuk arsitektur folder:** Layer-first vs Feature-first, MVVM vs Clean Architecture.
**Keputusan:** Feature-first + Clean Architecture 3 layer.
**Alasan:** Detail di `ARCHITECTURE.md` §1. Skalabilitas navigasi kode & testability domain layer murni.
**Trade-off yang diterima:** Lebih banyak file/folder untuk fitur sederhana dibanding pendekatan langsung — disengaja demi konsistensi jangka panjang, bukan optimal untuk proyek sekali-pakai kecil.

**Opsi yang dipertimbangkan untuk desain visual:** ikut Material 3 default vs custom seed color & typography.
**Keputusan:** Material 3 sebagai fondasi (color roles, type scale, elevation), tapi seed color kustom (teal) + font kustom (Plus Jakarta Sans/Inter) + icon set kustom (Phosphor).
**Alasan:** Material 3 default terlalu mudah dikenali sebagai "belum dikustomisasi" — untuk portofolio, personality visual penting supaya tidak terlihat template generik, tapi tetap dapat manfaat sistem Material 3 (dark mode gratis, aksesibilitas terstruktur) tanpa membangun design system dari nol.
**Trade-off yang diterima:** Sedikit effort ekstra dibanding pure default, tapi dianggap sepadan untuk nilai portofolio.

**Opsi yang dipertimbangkan untuk responsive layout:** package adaptive pihak ketiga (`responsive_framework`, dll) vs native Flutter (`LayoutBuilder`, `MediaQuery`, `Flex`/`Expanded`).
**Keputusan:** Native Flutter tools sepenuhnya, tanpa package adaptive pihak ketiga.
**Alasan:** Ini justru requirement eksplisit portofolio — menunjukkan pemahaman fundamental Flutter layout system (`Flexible`, `Expanded`, `Flex`, breakpoint manual) alih-alih bergantung pada package yang menyembunyikan detail. Untuk level senior, pemahaman dasar ini lebih bernilai daripada kecepatan development semata.
**Trade-off yang diterima:** Lebih banyak kode manual untuk menangani breakpoint dibanding pakai package siap pakai.

---

## Template Entri Selanjutnya (hapus placeholder ini saat mulai isi)

## [YYYY-MM-DD] Judul
**Konteks:**
**Opsi yang dipertimbangkan:**
**Keputusan:**
**Alasan:**
**Trade-off yang diterima:**

---

## Catatan Backlog untuk v2 (bukan keputusan, cuma parkir ide)

- Role-based access control granular
- Integrasi payment gateway sungguhan (Midtrans/Xendit)
- Cetak struk thermal printer Bluetooth
- Multi-cabang/outlet
- Resolusi konflik sync yang lebih canggih dari last-write-wins (mis. merge field-level) jika multi-device jadi kebutuhan nyata
