import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../../data/user/story_model.dart';

part 'fetch_my_stories_state.dart';

class FetchMyStoriesCubit extends Cubit<FetchMyStoriesState> {
  FetchMyStoriesCubit() : super(FetchMyStoriesInitial());

  @override
  void onChange(Change<FetchMyStoriesState> change) {
    super.onChange(change);
    print('Stories State Change: ${change.currentState} → ${change.nextState}');
  }

  Future<void> fetchMyStories({String? userId}) async {
    emit(FetchMyStoriesLoading());

    try {
      String uid;

      // If userId is passed and not empty, use it
      if (userId != null && userId.isNotEmpty) {
        uid = userId;
      }
      // Otherwise use current logged-in user
      else {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(const FetchMyStoriesError('User not logged in'));
          return;
        }
        uid = user.uid;
      }
      final storiesRef = FirebaseDatabase.instance.ref().child('stories').child(uid);

      final snapshot = await storiesRef.get();

      if (!snapshot.exists) {
        emit(const FetchMyStoriesSuccess(stories: []));
        return;
      }

      final Map data = snapshot.value as Map;
      final List<StoryModel> stories = [];

      final now = DateTime.now().millisecondsSinceEpoch;

      data.forEach((key, value) {
        final map = value as Map;
        final createdAt = (map['createdAt'] as int?) ?? 0;

        if (now - createdAt <= 24 * 60 * 60 * 1000) {
          stories.add(StoryModel(
            storyId: key,
            imageUrl: map['imageUrl'] as String,
            createdAt: createdAt,
          ));
        }
      });

      // Sort newest first
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(FetchMyStoriesSuccess(stories: stories));
    } catch (e) {
      emit(FetchMyStoriesError(e.toString()));
    }
  }
}