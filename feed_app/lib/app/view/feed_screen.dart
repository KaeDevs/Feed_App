import 'package:feed_app/app/provider/feed_provider.dart';
import 'package:feed_app/app/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    Future.microtask(() {
      ref.read(feedProvider.notifier).fetchPosts();
    }
    );
    
    scrollController.addListener(() {
      scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200
          ? ref.read(feedProvider.notifier).fetchPosts()
          : null;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    return RepaintBoundary(
      
      child: Scaffold(
        appBar: AppBar(title: const Text("Feed Screen")),
        body: (feed.posts.isEmpty && feed.isLoading)
      ? Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: ref.read(feedProvider.notifier).refresh,
          child: ListView.builder(
            controller: scrollController,
            itemCount: feed.posts.length + 1,
            itemBuilder: (context, index) {
              if (index == feed.posts.length) {
                return feed.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink();
              }
              final post = feed.posts[index];
              return PostCard(post: post);
            },
          ),
        )),
    );
  }
}
