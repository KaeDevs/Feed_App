import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed_app/app/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final Post post;
  PostDetailsScreen({required this.post});
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreen();
}

class _PostDetailsScreen extends ConsumerState<PostDetailsScreen> {
  bool loadImg = false;

  @override
  void initState() {
    super.initState();
    // Wait for Hero animation to finish (~300ms) before loading mobile image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) fetchMobileImage();
      });
    });
  }

  Future<void> fetchMobileImage() async {
    await precacheImage(
      CachedNetworkImageProvider(widget.post.mediaMobileUrl),
      context,
    );
    if (mounted) {
      setState(() {
        loadImg = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Post Details"),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final uri = Uri.parse(widget.post.mediaRawUrl);
                await launchUrl(uri);
              },
              child: const Text(
                "Download",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Hero(
        tag: "post${widget.post.id}",
        // flightShuttleBuilder keeps the thumbnail visible during
        // both the push AND pop flights, preventing the scale glitch
        flightShuttleBuilder: (_, animation, direction, fromCtx, toCtx) {
          return CachedNetworkImage(
            imageUrl: widget.post.mediaThumbUrl,
            fit: BoxFit.fitWidth,
            memCacheWidth: 300,
          );
        },
        child: Stack(
          children: [
            // Thumbnail — always rendered so Hero has something to grab
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.post.mediaThumbUrl,
                fit: BoxFit.fitWidth,
                memCacheWidth: 300,
              ),
            ),
            // Mobile image fades in on top after Hero lands
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: loadImg ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: CachedNetworkImage(
                  imageUrl: widget.post.mediaMobileUrl,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
