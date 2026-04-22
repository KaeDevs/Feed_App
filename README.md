Hello!!

I built the Feed using Flutter for UI, Riverpod for state, and Supabase for backend data and RPC calls as mentioned.

State Management
I used Riverpod NotifierProvider for the main feed state. It handles loading posts, refreshing. I used NotifierProvider's family for per-post like states. I needed family because each post needs isolated state, so one post like change does not affect other posts.

I wrapped every PostCard in a RepaintBoundary.

I used CachedNetworkImage with memCacheWidth set to 300 on thumbnails stuff.

When I tap like, I mutate Riverpod state first so the UI updates right away. Then I fire the Supabase RPC in the background. If that RPC fails, I revert the UI state and show a SnackBar. I also added debounce logic, so UI still updates on every tap but the RPC is sent only 800ms after the last tap to stop database desyncing from spam clicks.

To run the App~
    Clone the repo.
    Run flutter pub get.
    Add your Supabase URL and anon key to the config file.
    Run the Python seeding script.
    Run flutter run.
