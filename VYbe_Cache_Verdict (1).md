# VYbe — Cache System: Final Implementation Brief

**For:** Code Editor (Implementation Instructions)  
**Stack:** Flutter · Firebase Firestore · Custom CacheManager  
**Constraint:** Mixkit static MP4 CDN (no HLS/DASH — 0% or 100% download, no in-between)

---

## The One Real Problem

Mixkit serves flat MP4 files. The player cannot start until the full file is on disk.  
This is a CDN constraint. No amount of Flutter code fixes it.  
Every other problem below IS fixable tonight.

**Free alternative CDN considered and rejected:**
- Cloudflare Stream — paid
- Mux — paid
- Bunny.net — paid
- Self-hosted HLS (FFmpeg + Firebase Hosting) — free but requires transcoding every video manually, not viable for a 5-day task
- **Verdict: Roll with Mixkit. Own the constraint explicitly in the report.**

---

## Amended Methodology (What Changed From Original Plan)

### Amendment 1 — Initial Load is Sequential, NOT Parallel

**Old thinking (wrong):**
```dart
// Launch: load all 3 at once
await Future.wait([
  _ensureController(0),
  _ensureController(1),
  _ensureController(2),
]);
```

**Why it's wrong:** All 3 downloads compete for the same bandwidth pipe.  
Video 0 — the one the user is actually watching — gets 1/3 of available bandwidth.  
On 4G this causes the first video to buffer. That is the worst possible first impression.

**Correct approach:**
```dart
// Launch: current video gets 100% bandwidth first
await _ensureController(0);       // WAIT for this — user is watching it

// Only after video 0 is playing, start the rest
_ensureController(1);             // fire and forget
_warmCache(2);                    // disk only, no controller
_warmCache(3);                    // disk only, no controller
```

---

### Amendment 2 — Future.wait is for Scroll ONLY, Not Init

`Future.wait` is correct when scrolling mid-feed (user is already watching something, bandwidth is free).  
It is wrong at app launch (bandwidth must go 100% to video 0 first).

**On scroll to index N (correct):**
```dart
await Future.wait([
  _ensureController(N - 1),   // back-swipe ready
  _ensureController(N),       // current
  _ensureController(N + 1),   // forward-swipe ready
]);
_warmCache(N + 2);            // disk only
_warmCache(N + 3);            // disk only
```

---

### Amendment 3 — Warm Cache vs Controller is Non-Negotiable

Two completely different operations. Never confuse them:

| Operation | What it does | Decoder used | RAM cost | When to use |
|---|---|---|---|---|
| `_ensureController(index)` | Download + init VideoPlayerController | YES | High | Current ± 1 only |
| `_warmCache(index)` | Download to disk only, no player | NO | Near zero | +2, +3 ahead |

Android mid-range devices have ~4 hardware decoder slots total.  
3 simultaneous `controller.initialize()` calls = decoder contention = jank on current video.  
Maximum 2 controllers initializing at any point in time.

---

### Amendment 4 — Custom CacheManager Replaces DefaultCacheManager

```dart
class VideoCacheManager extends CacheManager {
  static const key = 'vybeVideoCache';

  static final VideoCacheManager _instance = VideoCacheManager._();
  factory VideoCacheManager() => _instance;

  VideoCacheManager._() : super(Config(
    key,
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 50,        // hard cap ~750MB at 15MB/video
    repo: JsonCacheInfoRepository(databaseName: key),
    fileService: HttpFileService(),
  ));
}
```

Replace every `DefaultCacheManager()` reference with `VideoCacheManager()`.

---

### Amendment 5 — didReceiveMemoryWarning

Already have `WidgetsBindingObserver` for background handling. Add this:

```dart
@override
void didReceiveMemoryWarning() {
  _controllers.keys
    .where((i) => (i - _currentIndex).abs() > 1)
    .toList()
    .forEach((i) {
      _controllers[i]?.dispose();
      _controllers.remove(i);
    });
}
```

---

### Amendment 6 — Thumbnail Mask (No Black Frame Flash)

```dart
Stack(
  children: [
    VideoPlayer(_controller),
    AnimatedOpacity(
      opacity: _isInitialized ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: CachedNetworkImage(
        imageUrl: widget.video.thumbnailUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    ),
  ],
)

// Listener in initState:
_controller.addListener(() {
  if (_controller.value.isInitialized && !_isInitialized) {
    setState(() => _isInitialized = true);
  }
});
```

---

### Amendment 7 — cached_network_image for Thumbnails and Avatars

Add to pubspec.yaml:
```yaml
cached_network_image: ^3.3.1
```

Replace all `Image.network()` and `NetworkImage()` in ReelItem with `CachedNetworkImage()`.

---

## Final Data Flow (Complete, Authoritative)

```
APP LAUNCH
──────────
Firestore
    ↓
Fetch all video metadata (URL, thumbnail, likes, username)
    ↓
await _ensureController(0)          ← 100% bandwidth to video 0
    ↓
Video 0 file downloads → VideoCacheManager saves to disk
    ↓
VideoPlayerController.file(localFile) → initialize() → play()
    ↓
Thumbnail mask fades out on firstFrameRendered (80ms transition)
    ↓
[Video 0 is playing]
    ↓
fire-and-forget: _ensureController(1)
fire-and-forget: _warmCache(2)
fire-and-forget: _warmCache(3)


USER ON VIDEO N (steady state)
──────────────────────────────
Active controllers:    [N-1 PAUSED] [N PLAYING] [N+1 PAUSED]
Files on disk:         [N-2] [N-1] [N] [N+1] [N+2] [N+3]  ← up to 6 files cached
Controllers disposed:  everything outside N±1


USER SWIPES TO N+1
──────────────────
1. PageView fires onPageChanged(N+1)
2. _controllers[N].pause()
3. _controllers[N+1].play()           ← already initialized, instant
4. Thumbnail mask already gone (was preloaded)
5. Future.wait([
     _ensureController(N),            ← keep (back-swipe)
     _ensureController(N+1),          ← already exists, no-op
     _ensureController(N+2),          ← new controller
   ])
6. _warmCache(N+3)                    ← disk only
7. _warmCache(N+4)                    ← disk only
8. dispose controllers outside [N, N+2]
   → _controllers[N-1].dispose()      ← RAM freed
   → disk file for N-1 stays          ← no re-download if user scrolls back


USER SCROLLS BACK TO N
──────────────────────
1. _controllers[N] still exists (was kept in window)
2. play() immediately — zero wait
3. No network request — file already on disk


USER SCROLLS BACK FURTHER TO N-1
──────────────────────────────────
1. _controllers[N-1] was disposed — must recreate
2. VideoCacheManager: file already on disk → CACHE HIT
3. VideoPlayerController.file(cachedFile) → initialize() → ~50ms
4. Thumbnail mask covers the 50ms gap
5. Plays from disk — no network


LOW MEMORY EVENT
────────────────
didReceiveMemoryWarning fires
    ↓
Dispose all controllers except current ± 1
    ↓
Files remain on disk (cache untouched)
    ↓
Recreate from disk when needed


CACHE EVICTION (automatic, background)
────────────────────────────────────────
VideoCacheManager LRU policy:
- Max 50 files on disk
- 7-day staleness
- Oldest accessed file removed first when cap hit
- Currently active window files naturally stay (recently accessed)
```

---

## Cache Behavior: What the User Never Sees

| Scenario | Network hit? | Wait time |
|---|---|---|
| First time watching video N | Yes — full MP4 download | Depends on file size + connection |
| Swipe to N+1 (preloaded) | No | ~0ms — already initialized |
| Swipe back to N (in window) | No | 0ms — controller still alive |
| Swipe back to N-1 (disposed, cached) | No | ~50ms — rebuild controller from disk |
| Swipe back to N-10 (old, still on disk) | No | ~50ms — rebuild from disk |
| Swipe to a video evicted from disk | Yes — re-download | Full download again |

---

## What to Tell the Interviewer About Mixkit

> *"Mixkit serves static MP4 files without HLS manifest support, so the player must receive the complete file before playback begins — there's no chunked transfer or partial caching possible at the app layer. In production this would be replaced with a CDN like Cloudflare Stream or Mux that outputs HLS, giving the player 2-second segments, adaptive bitrate, and true stream-while-download. The rest of the architecture — sliding window, custom eviction, warm-cache separation — remains identical. The CDN is the only swap."*

---

## Files to Change (Code Editor Instructions)

| File | Change |
|---|---|
| `lib/features/reels/services/video_cache_service.dart` | Replace `DefaultCacheManager()` with `VideoCacheManager()` (new class in same file) |
| `lib/features/reels/services/reels_video_manager.dart` | Sequential init on launch; `Future.wait` on scroll; add `_warmCache()`; add `didReceiveMemoryWarning` |
| `lib/features/reels/presentation/widgets/reel_item.dart` | Add thumbnail mask Stack + AnimatedOpacity; replace `Image.network` with `CachedNetworkImage` |
| `pubspec.yaml` | Add `cached_network_image: ^3.3.1` |

**Do not touch:** Firestore repository, seeder, models, architecture structure — all fine as-is.

