import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed_app/app/provider/like.dart';
import 'package:feed_app/app/view/post_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/post.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeProvider(post));
    return RepaintBoundary(
      child: Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.white.withValues(alpha: 1), Colors.white],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 30,
              spreadRadius: 10,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailsScreen(post: post),
                  ),
                ),
                child: Hero(
                  tag: "post${post.id}",
                  transitionOnUserGestures: true,
                  child: CachedNetworkImage(
                
                    // height: double.infinity,
                    width: double.infinity,
                    imageUrl: post.mediaThumbUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 300,

                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white.withValues(alpha: 1),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20,30,0,20),

                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final snackbarMsg = ScaffoldMessenger.of(context);
                            await ref
                                .read(likeProvider(post).notifier)
                                .toggleLike(
                                  onError: () {
                                   snackbarMsg.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Failed to update your like. Try again!",
                                        ),
                                      ),
                                    );
                                  },
                                );
                          },
                          child: Icon(
                            likeState.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: likeState.isLiked ? Colors.red : Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          likeState.likes.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
