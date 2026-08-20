# TESTING — Strategi Pengujian

> Testing bukan checkbox tambahan — ini bagian dari bukti "senior-level" di portofolio: kemampuan memastikan kode benar secara sistematis, bukan cuma "jalan di device saya".

## 1. Piramida Testing yang Dipakai

```
        ▲  Integration/E2E (sedikit, mahal, tapi kritikal)
       ╱ ╲
      ╱   ╲  Widget Test (sedang, per komponen & screen)
     ╱─────╲
    ╱       ╲ Unit Test (banyak, murah, cepat — domain & data)
   ╱─────────╲
```

Rasio target: ~60% unit, ~30% widget, ~10% integration.

## 2. Unit Testing — Domain & Data Layer

**Target coverage: > 80%** untuk `domain/usecases`, `domain/entities` (jika ada logic di entity), dan `data/repositories`.

Yang diuji:
- Setiap `UseCase` (mis. `CreateTransactionUseCase`) — happy path + edge case (stok tidak cukup, harga negatif, keranjang kosong tidak boleh checkout)
- `Repository` implementation — mocking data source (`mocktail`), pastikan mapping DTO ↔ Entity benar, pastikan error dari data source ter-mapping ke `Failure` yang tepat
- Util murni: `CurrencyFormatter`, `DateFormatter`, validator form produk

**Contoh struktur test:**
```dart
group('CreateTransactionUseCase', () {
  test('berhasil membuat transaksi dan mengurangi stok', () async { ... });
  test('gagal jika stok produk tidak mencukupi', () async { ... });
  test('gagal jika keranjang kosong', () async { ... });
  test('menghitung kembalian dengan benar untuk pembayaran tunai', () async { ... });
});
```

**Tools:** `flutter_test`, `mocktail` (bukan `mockito` — mocktail tidak butuh code generation, lebih ringan untuk proyek skala ini), `fake_async` untuk kasus yang melibatkan `Timer`/debounce (mis. auto-sync interval).

## 3. Widget Testing — Presentation Layer

**Target coverage: menutup semua screen utama** (Kasir, Detail Produk, Checkout, Riwayat Transaksi, Dashboard).

Yang diuji per screen:
- Render awal benar sesuai state (loading/empty/data/error) — manfaatkan `AsyncValue` dari Riverpod yang punya 3 state jelas
- Interaksi dasar: tap tombol memicu callback/provider action yang benar (verifikasi lewat `ProviderContainer` override, bukan hit network/DB asli)
- Form validasi: input invalid menampilkan error message yang benar (mis. harga produk tidak boleh 0 atau negatif)

**Pola Riverpod testing:**
```dart
testWidgets('menampilkan pesan stok habis saat produk stok 0', (tester) async {
  final container = ProviderContainer(overrides: [
    productListProvider.overrideWith(() => FakeProductListNotifier(stockZero: true)),
  ]);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const MyApp()));
  expect(find.text('Stok Habis'), findsOneWidget);
});
```

## 4. Golden Testing — Responsive Layout

Ini bagian **wajib** karena requirement responsive (phone/tablet, portrait/landscape) adalah klaim utama produk ini — harus dibuktikan otomatis, bukan cuma dicek manual sesekali.

- Gunakan `golden_toolkit` untuk generate screenshot per kombinasi device:
  - `phone_portrait` (390×844 — setara iPhone 13-ish)
  - `phone_landscape` (844×390)
  - `tablet_portrait` (834×1194 — setara iPad)
  - `tablet_landscape` (1194×834)
- Screen wajib golden test: Kasir (paling kritikal karena punya 2 layout berbeda antara compact & expanded), Dashboard, Detail Produk
- Golden test dijalankan di CI, diff otomatis flag jika ada perubahan visual tak disengaja

## 5. Integration Testing (E2E)

**Target: 2–3 flow kritikal saja** (bukan semua flow — integration test mahal untuk maintain), pakai `integration_test` package resmi Flutter:

1. **Flow transaksi penuh**: buka app → pilih produk → checkout tunai → verifikasi transaksi tersimpan di DB lokal → verifikasi stok berkurang
2. **Flow offline → online sync**: matikan mock connectivity → buat transaksi → nyalakan kembali → verifikasi `SyncService` mengirim data & `is_synced` berubah jadi `true`
3. **Flow tambah produk baru**: dari form sampai muncul di grid Kasir

## 6. Testing untuk Sync Logic (kritikal, sering jadi sumber bug tersembunyi)

Karena offline-first + sync adalah bagian paling rawan, dibuatkan test khusus:
- Simulasikan konflik `updated_at` (dua perubahan pada baris yang sama) → pastikan strategi last-write-wins berjalan sesuai `ARCHITECTURE.md` §5
- Simulasikan network gagal di tengah sync → pastikan tidak ada data hilang/duplikat, retry berjalan idempotent

## 7. Manual Testing Checklist (sebelum setiap "rilis" portofolio)

- [ ] Jalan mulus di phone kecil (contoh: emulator 5.5")
- [ ] Jalan mulus di tablet besar (emulator 12.9")
- [ ] Rotasi portrait ↔ landscape di tengah transaksi tidak menghilangkan state keranjang
- [ ] Dark mode tidak ada kontras teks yang hilang/tidak terbaca
- [ ] Mode pesawat (offline penuh) — semua flow inti tetap jalan
- [ ] Font scaling sistem dinaikkan ke maksimal — layout tidak pecah/overflow

## 8. CI Setup (rekomendasi, opsional tapi bagus untuk portofolio)

GitHub Actions dengan job:
1. `flutter analyze` (lint wajib clean, nol warning)
2. `flutter test --coverage` (unit + widget) → upload ke Codecov, badge di README
3. `flutter test --tags=golden` terpisah (golden test lebih lambat)
4. (Opsional) build APK debug sebagai artifact tiap push ke `main`

Punya CI hijau + badge coverage di README adalah sinyal kuat "senior-level engineering practice" untuk siapapun yang review portofolio.
