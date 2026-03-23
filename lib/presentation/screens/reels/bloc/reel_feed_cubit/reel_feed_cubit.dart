import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/user/reels_model.dart';

part 'reel_feed_state.dart';

class ReelFeedCubit extends Cubit<ReelFeedState> {
  ReelFeedCubit() : super(ReelFeedInitial());

  final DatabaseReference _db =
      FirebaseDatabase.instance.ref('reelsFeed');

  final int _pageSize = 5;

  bool _isFetching = false;
  bool _hasMore = true;

  String? _lastKey; // ✅ go back to key-based cursor

  final List<ReelItems> _reels = [];

  static const int _maxCache = 30;

  /// ================== INITIAL ==================
  Future<void> fetchInitial() async {
    if (_isFetching) return;

    _isFetching = true;
    _hasMore = true;
    _lastKey = null;

    emit(ReelFeedLoading());

    try {
      final snapshot = await _db
          .limitToLast(_pageSize)
          .get();

      _parseSnapshot(snapshot, clear: true);
    } catch (e) {
      print("❌ INITIAL ERROR: $e");
      emit(ReelFeedError('Failed to load reels'));
    } finally {
      _isFetching = false;
    }
  }

  /// ================== FETCH MORE ==================
  Future<void> fetchMore() async {
    if (_isFetching || !_hasMore || _lastKey == null) return;

    _isFetching = true;

    try {
      final snapshot = await _db
          .endAt(_lastKey)
          .limitToLast(_pageSize + 1)
          .get();

      _parseSnapshot(snapshot);
    } catch (e) {
      print("❌ FETCH MORE ERROR: $e");
      emit(ReelFeedError('Failed to load more reels'));
    } finally {
      _isFetching = false;
    }
  }

  /// ================== PARSE ==================
  void _parseSnapshot(
    DataSnapshot snapshot, {
    bool clear = false,
  }) {
    if (!snapshot.exists || snapshot.value == null) {
      _hasMore = false;
      emit(ReelFeedLoaded(List.from(_reels)));
      return;
    }

    final raw = snapshot.value;

    if (raw is! Map) {
      _hasMore = false;
      emit(ReelFeedLoaded(List.from(_reels)));
      return;
    }

    final entries = raw.entries
        .map((e) => MapEntry(e.key.toString(), e.value))
        .toList();

    /// 🔥 SORT by key (stable + fast)
    entries.sort((a, b) => a.key.compareTo(b.key));

    /// 🔥 REMOVE DUPLICATE
    if (_lastKey != null) {
      entries.removeWhere((e) => e.key == _lastKey);
    }

    if (entries.isEmpty) {
      _hasMore = false;
      emit(ReelFeedLoaded(List.from(_reels)));
      return;
    }

    final List<ReelItems> fetched = [];

    for (final entry in entries) {
      try {
        final Map<String, dynamic> normalized = {};

        (entry.value as Map).forEach((k, v) {
          normalized[k.toString()] = v;
        });

        final reel = ReelItems.fromMap(normalized);

        if (reel.videoUrl.isNotEmpty) {
          fetched.add(reel);
        }
      } catch (e) {
        print("❌ PARSE ERROR: $e");
      }
    }

    if (fetched.isEmpty) {
      emit(ReelFeedLoaded(List.from(_reels)));
      return;
    }

    /// 🔥 update cursor (oldest key)
    _lastKey = entries.first.key;

    if (clear) _reels.clear();

    /// newest first
    _reels.addAll(fetched.reversed);

    /// 🔥 MEMORY CONTROL
    if (_reels.length > _maxCache) {
      _reels.removeRange(0, _reels.length - _maxCache);
    }

    emit(ReelFeedLoaded(List.from(_reels)));
  }
}