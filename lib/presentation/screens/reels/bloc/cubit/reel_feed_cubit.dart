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
  String? _lastKey;

  final List<ReelItems> _reels = [];

  /// INITIAL LOAD
  Future<void> fetchInitial() async {
    if (_isFetching) return;
    _isFetching = true;
    _hasMore = true;

    emit(ReelFeedLoading());

    try {
      final snapshot = await _db
          .limitToLast(_pageSize)
          .get();

      _parseSnapshot(snapshot, clear: true);
    } catch (_) {
      emit(ReelFeedError('Failed to load reels'));
    } finally {
      _isFetching = false;
    }
  }

  /// FETCH MORE
  Future<void> fetchMore() async {
    if (_isFetching || !_hasMore || _lastKey == null) return;
    _isFetching = true;

    try {
      final snapshot = await _db
          .endAt(_lastKey)
          .limitToLast(_pageSize + 1) // +1 overlap
          .get();

      _parseSnapshot(snapshot);
    } catch (_) {
      emit(ReelFeedError('Failed to load more reels'));
    } finally {
      _isFetching = false;
    }
  }

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

    final entries = (raw as Map)
        .entries
        .map((e) => MapEntry(e.key.toString(), e.value))
        .toList();

    // Keys are naturally ordered oldest → newest
    entries.sort((a, b) => a.key.compareTo(b.key));

    // Remove overlap (already loaded lastKey)
    if (_lastKey != null && entries.isNotEmpty) {
      entries.removeWhere((e) => e.key == _lastKey);
    }

    if (entries.isEmpty) {
      _hasMore = false;
      emit(ReelFeedLoaded(List.from(_reels)));
      return;
    }

    final List<ReelItems> fetched = [];

    for (final entry in entries) {
      if (entry.value is Map) {
        try {
          final Map<String, dynamic> normalized = {};
          (entry.value as Map).forEach((k, v) {
            normalized[k.toString()] = v;
          });

          fetched.add(ReelItems.fromMap(normalized));
        } catch (_) {}
      }
    }

    // 🔑 UPDATE CURSOR TO OLDEST LOADED
    _lastKey = entries.first.key;

    if (clear) _reels.clear();
    _reels.addAll(fetched.reversed); // newest on top

    emit(ReelFeedLoaded(List.from(_reels)));
  }
}
