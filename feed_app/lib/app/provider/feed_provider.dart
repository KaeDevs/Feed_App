import 'package:feed_app/app/model/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool hasMore;
  final int page;

  FeedState({
    required this.posts,
    required this.isLoading,
    required this.hasMore,
    required this.page,
  });

  factory FeedState.initial() {
    return FeedState(posts: [], hasMore: true, isLoading: false, page: 0);
  }

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class FeedNotifier extends Notifier<FeedState> {
  @override
  FeedState build() {
    return FeedState.initial();
  }

  Future<void> fetchPosts() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    int start = state.page * 10;
    int end = start + 9;
    try {
      final newPosts = await supabase.from('posts').select().range(start, end);
      state = state.copyWith(
        isLoading: false,
        hasMore: newPosts.length == 10,
        page: state.page + 1,
        posts: [...state.posts, ...newPosts.map((post) => Post.fromJson(post))],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return;
    }
  }

  Future<void> refresh() async {
    state = FeedState.initial();
    await fetchPosts();
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(
  () => FeedNotifier(),
);
