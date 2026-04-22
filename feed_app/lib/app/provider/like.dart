import 'dart:async';

import 'package:feed_app/app/model/post.dart';
import 'package:feed_app/core/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LikeState {
  
  final bool isLiked;
  final int likes;

  LikeState({required this.likes, required this.isLiked});

  LikeState copyWith({int? likes, bool? isLiked}) {
    return LikeState(
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class LikeNotifier extends Notifier<LikeState> {
  LikeNotifier(this.post);
  final Post post;
  static const userId = 'user_123';
  static const debounceDelay = Duration(milliseconds: 800);

  Timer? debounceTimer;
  LikeState? serverState;
  bool isSyncing = false;
  bool hasPendingSync = false;

  @override
  LikeState build() {
    serverState = LikeState(likes: post.likeCount, isLiked: post.isLiked);
    ref.onDispose(() {
      debounceTimer?.cancel();
    });
    if (!post.isLiked) {
      loadInitialLike();
    }
    return serverState!;
  }

  Future<void> toggleLike({required void Function() onError}) async {
    final nextLiked = !state.isLiked;
    final nextLikes = state.likes + (nextLiked ? 1 : -1);
    state = state.copyWith(
      isLiked: nextLiked,
      likes: nextLikes < 0 ? 0 : nextLikes,
    );

    debounceTimer?.cancel();
    debounceTimer = Timer(debounceDelay, () {
      syncLike(onError: onError);
    });
  }

  Future<void> loadInitialLike() async {
    try {
      final result = await supabase
          .from('likes')
          .select('post_id')
          .eq('post_id', post.id)
          .eq('user_id', userId)
          .maybeSingle();
      if (result == null || state.isLiked) {
        return;
      }
      final hydrated = state.copyWith(isLiked: true);
      state = hydrated;

      serverState = hydrated;
    }
    catch (e) 
    {
      return;
    }
  }

  Future<void> syncLike({required void Function() onError}) async {
    if (isSyncing) {
      hasPendingSync = true;
      return;
    }
    while (true) {
      final lastServerState = serverState;
      if(lastServerState == null) {
         return;
      }

      final desiredLiked = state.isLiked;
      if(desiredLiked == lastServerState.isLiked) {
        hasPendingSync = false;
        return;
      }

      isSyncing = true;
      try{
        final nextLiked = !lastServerState.isLiked;
        final nextLikes = lastServerState.likes + (nextLiked ? 1 : -1);

        await toggleLikeOnServer();
        serverState = LikeState(
          isLiked: nextLiked,
          likes: nextLikes < 0 ? 0 : nextLikes,
        );

        final freshCount = await fetchLikeCount();
        if (freshCount != null) {
          serverState = serverState!.copyWith(likes: freshCount);
          state = state.copyWith(likes: freshCount);
        }
      }
      catch (e){
        state = lastServerState;
        serverState = lastServerState;
        hasPendingSync = false;
        onError();
        return;
      }finally {
        isSyncing = false;
      }

      if(!hasPendingSync && state.isLiked == serverState!.isLiked) {
        return;
      }
      hasPendingSync = false;
    }
  }

  Future<void> toggleLikeOnServer() async {
    await supabase.rpc(
      'toggle_like',
      params: {'p_post_id': post.id, 'p_user_id': userId},
    );
  }

  Future<int?> fetchLikeCount() async {
    try {
      final result = await supabase
          .from('posts')
          .select('like_count')
          .eq('id', post.id)
          .single();
      final raw = result['like_count'];
      if(raw is int) {
        return raw;
      }
      if(raw is num) {
        return raw.toInt();
      }
      return null;
    } catch(ee) {
      return null;
    }
  }
}

final likeProvider = NotifierProvider.family<LikeNotifier, LikeState, Post>(
  (arg) => LikeNotifier(arg),
);
