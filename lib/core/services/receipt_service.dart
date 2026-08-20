import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/auth/domain/entities/store.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class ReceiptService {
  ReceiptService._();

  /// Menghasilkan dokumen PDF struk format thermal (80mm)
  static Future<Uint8List> generateReceiptPdf({
    required TransactionEntity transaction,
    Store? store,
  }) async {
    final pdf = pw.Document();

    final storeName = store?.name ?? 'UMKM POS';
    final storeAddress = store?.address ?? '';
    final storePhone = store?.phone ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header Toko
              pw.Text(
                storeName,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (storeAddress.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  storeAddress,
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              if (storePhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Telp: $storePhone',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Info Transaksi
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No. Struk:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    transaction.invoiceNumber,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Waktu:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    DateFormatter.formatDateTime(transaction.createdAt),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Daftar Item
              pw.SizedBox(height: 4),
              ...transaction.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.priceAtSale)}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Ringkasan Pembayaran
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(transaction.totalAmount),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Metode Bayar:',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    transaction.paymentMethod.label,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (transaction.paymentMethod.value == 'cash') ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Tunai Diterima:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(transaction.cashReceived),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Kembalian:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(transaction.changeAmount),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),

              // Footer Struk
              pw.Text(
                'Terima Kasih Atas Kunjungan Anda!',
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Barang yang dibeli tidak dapat ditukar',
                style: const pw.TextStyle(
                  fontSize: 6,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Membagikan struk via WhatsApp atau Share Sheet
  static Future<void> shareReceipt({
    required TransactionEntity transaction,
    Store? store,
  }) async {
    final pdfBytes = await generateReceiptPdf(
      transaction: transaction,
      store: store,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'struk-${transaction.invoiceNumber.replaceAll('/', '-')}.pdf',
    );
  }

  /// Membagikan teks ringkasan transaksi via WhatsApp/SMS
  static Future<void> shareReceiptText({
    required TransactionEntity transaction,
    Store? store,
  }) async {
    final storeName = store?.name ?? 'UMKM POS';
    final buffer = StringBuffer();
    buffer.writeln('🧾 *STRUK PEMBELIAN — $storeName*');
    if (store?.phone != null && store!.phone!.isNotEmpty) {
      buffer.writeln('Telp: ${store.phone}');
    }
    buffer.writeln('No: ${transaction.invoiceNumber}');
    buffer.writeln(
      'Waktu: ${DateFormatter.formatDateTime(transaction.createdAt)}',
    );
    buffer.writeln('--------------------------------');

    for (final item in transaction.items) {
      buffer.writeln(item.productName);
      buffer.writeln(
        '${item.quantity} x ${CurrencyFormatter.format(item.priceAtSale)} = ${CurrencyFormatter.format(item.subtotal)}',
      );
    }

    buffer.writeln('--------------------------------');
    buffer.writeln(
      '*TOTAL: ${CurrencyFormatter.format(transaction.totalAmount)}*',
    );
    buffer.writeln('Metode: ${transaction.paymentMethod.label}');
    if (transaction.paymentMethod.value == 'cash') {
      buffer.writeln(
        'Bayar: ${CurrencyFormatter.format(transaction.cashReceived)}',
      );
      buffer.writeln(
        'Kembali: ${CurrencyFormatter.format(transaction.changeAmount)}',
      );
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Terima kasih telah berbelanja!');

    await Share.share(
      buffer.toString(),
      subject: 'Struk Transaksi ${transaction.invoiceNumber}',
    );
  }
}
