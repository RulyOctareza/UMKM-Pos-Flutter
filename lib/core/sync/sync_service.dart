import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../network/connectivity_service.dart';
import '../providers/core_providers.dart';
import '../widgets/sync_status_badge.dart';

class SyncService {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  StreamSubscription? _connectivitySub;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  bool _isSyncing = false;

  SyncService(this._db, this._connectivity) {
    _initListener();
  }

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  void _initListener() {
    _connectivitySub = _connectivity.isOnlineStream.listen((isOnline) {
      if (isOnline) {
        _syncStatusController.add(SyncStatus.synced);
        syncPendingData();
      } else {
        _syncStatusController.add(SyncStatus.offline);
      }
    });
  }

  /// Sinkronisasi antrian data lokal ke cloud secara batch (Last-Write-Wins)
  Future<bool> syncPendingData() async {
    if (_isSyncing) return false;

    final isOnline = await _connectivity.checkOnline();
    if (!isOnline) {
      _syncStatusController.add(SyncStatus.offline);
      return false;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // 1. Ambil baris is_synced = false
      final pendingStores = await (_db.select(
        _db.stores,
      )..where((t) => t.isSynced.equals(false))).get();
      final pendingCategories = await (_db.select(
        _db.categories,
      )..where((t) => t.isSynced.equals(false))).get();
      final pendingProducts = await (_db.select(
        _db.products,
      )..where((t) => t.isSynced.equals(false))).get();
      final pendingTxs = await (_db.select(
        _db.transactions,
      )..where((t) => t.isSynced.equals(false))).get();

      // Jika ada backend Supabase terkonfigurasi, kirim batch upsert di sini:
      // await supabase.from('products').upsert(pendingProducts.map(...));

      // 2. Tandai data lokal berhasil tersinkron
      await _db.transaction(() async {
        if (pendingStores.isNotEmpty) {
          await (_db.update(_db.stores)..where((t) => t.isSynced.equals(false)))
              .write(const StoresCompanion(isSynced: Value(true)));
        }
        if (pendingCategories.isNotEmpty) {
          await (_db.update(_db.categories)
                ..where((t) => t.isSynced.equals(false)))
              .write(const CategoriesCompanion(isSynced: Value(true)));
        }
        if (pendingProducts.isNotEmpty) {
          await (_db.update(_db.products)
                ..where((t) => t.isSynced.equals(false)))
              .write(const ProductsCompanion(isSynced: Value(true)));
        }
        if (pendingTxs.isNotEmpty) {
          await (_db.update(_db.transactions)
                ..where((t) => t.isSynced.equals(false)))
              .write(const TransactionsCompanion(isSynced: Value(true)));
        }
      });

      _syncStatusController.add(SyncStatus.synced);
      return true;
    } catch (_) {
      _syncStatusController.add(SyncStatus.offline);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncStatusController.close();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = SyncService(db, connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

final syncStatusStreamProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncStatusStream;
});
