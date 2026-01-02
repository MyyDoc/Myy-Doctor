import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../../data/user/story_model.dart';

part 'fetch_my_stories_state.dart';

class FetchMyStoriesCubit extends Cubit<FetchMyStoriesState> {
  FetchMyStoriesCubit() : super(FetchMyStoriesInitial());

  Future<void> fetchMyStories() async {
    emit(FetchMyStoriesLoading());

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const FetchMyStoriesError('User not logged in'));
        return;
      }

      final uid = user.uid;
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

        // Only show stories from last 24 hours
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