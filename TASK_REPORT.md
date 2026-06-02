# VYbe — Technical Skills Evaluation (Task Report)

**Project:** VYbe — Instagram/TikTok-style Reels app  
**Stack:** Flutter · Firebase Firestore · Mixkit CDN · Local video cache  
**Firebase project:** `instagram-127a8`

---

## 1. Task Overview

Build a simple Reels-style app where users scroll through short videos. The evaluation requirements were:

| # | Requirement | Status |
|---|-------------|--------|
| 1 | Fetch video data (URLs, descriptions, likes) from **Firestore** | ✅ Done |
| 2 | **Preload 3–4 videos** ahead for seamless playback | ✅ Done (preload count: 3) |
| 3 | **Cache videos** to avoid re-downloading the same file | ✅ Done (`flutter_cache_manager`) |
| 4 | **Auto-play and pause** based on scroll position | ✅ Done (`PageView` + `ReelsVideoManager`) |
| 5 | Show UI: **username**, **likes**, **caption** | ✅ Done (`ReelItem` overlay) |

---

## 2. Project Summary

**VYbe** is a vertical full-screen video feed. On launch it connects to Firebase, seeds sample data if needed, fetches reel metadata from Firestore, downloads MP4 files to local disk cache, and plays the visible reel while preloading the next ones.

### Key features

- Vertical swipe feed (`PageView`, axis: vertical)
- Firestore-backed metadata (no video bytes stored in Firebase)
- Disk caching so scrolling back does not re-download (see [Section 6](#6-video-caching--how-it-works-detailed))
- Controller pool with memory management (dispose distant controllers)
- App lifecycle handling (pause when backgrounded)
- Dev **Reseed DB** button to push updated seed data to Firestore

### Tech stack

| Layer | Technology |
|-------|------------|
| UI | Flutter, Material 3, custom theme |
| Backend | Cloud Firestore |
| Video playback | `video_player` |
| File cache | `flutter_cache_manager` |
| Media source | Mixkit CDN + Flutter sample MP4s (HTTPS URLs in Firestore) |

---

## 3. Database (Firestore)

Video **metadata** lives in Firestore. Actual MP4 files are hosted on external CDNs (Mixkit / Flutter docs). Firestore only stores the URL and display fields.

### Collections

```
Firestore
├── videos/                    ← reel catalog (18 documents)
│   ├── video_1
│   ├── video_2
│   └── … video_18
│
└── _meta/                     ← seed bookkeeping (dev only)
    └── seed
```

### Document schema (`videos/{id}`)

| Field | Type | Description |
|-------|------|-------------|
| `userId` | string | Author identifier |
| `username` | string | Display name on overlay |
| `userProfilePic` | string | Avatar URL |
| `videoUrl` | string | Direct HTTPS link to MP4 file |
| `thumbnailUrl` | string | Poster image while video loads |
| `description` | string | Caption text |
| `likes` | number | Like count |
| `comments` | number | Comment count |
| `createdAt` | timestamp | Server timestamp for feed ordering |

### Seed metadata (`_meta/seed`)

| Field | Type | Description |
|-------|------|-------------|
| `videosSeeded` | boolean | Whether seed has run |
| `seedVersion` | number | Bumped when seed data changes (current: **4**) |
| `seededAt` | timestamp | Last seed time |
| `videoCount` | number | Total seeded videos (18) |

### Seeding strategy

Implemented in `lib/seeder.dart`:

- **`seedVideosIfNeeded()`** — runs on app launch; skips if `_meta/seed` matches current `seedVersion`
- **`reseedVideos()`** — always overwrites all `video_1`…`video_18` docs (used by **Reseed DB** button)
- **`forceReseed()`** — deletes meta doc and re-runs version-gated seed

Videos use **fixed document IDs** (`video_1`, `video_2`, …) so re-seeding updates in place instead of creating duplicates.

### Why not Firebase Storage?

Firebase Storage was intentionally avoided for this evaluation:

- Firestore free tier is sufficient for small JSON documents
- Video bytes are served from **Mixkit CDN** (free, stable direct MP4 links)
- Avoids Storage egress costs during repeated testing
- Production would use **Firebase Storage** for user uploads; Firestore would still hold metadata + download URLs

### Sample video sources

| Source | Count | Notes |
|--------|-------|-------|
| Flutter docs (`bee.mp4`, `butterfly.mp4`) | 2 | Small, reliable test clips |
| Mixkit CDN (`assets.mixkit.co/...`) | 16 | Vertical 720p B-roll, royalty-free |

> **Note:** Mixkit clips are typically **audio-free** B-roll. The player supports audio (AAC via `video_player`); the sample files simply have no meaningful sound track. This does not affect the technical requirements.

### Firestore security rules (development)

For local seeding and reads during development, Firestore rules may need to allow read/write. Lock down rules before any production deployment.

---

## 4. Architecture (Clean Architecture)

Layers follow **dependency rule**: presentation → domain ← data. Domain has no Firebase, `video_player`, or cache imports.

```
main.dart
   │
   ├── Firebase.initializeApp()
   ├── DatabaseSeeder.seedVideosIfNeeded()
   └── ReelsPage (presentation)
           │
           ├── GetReels (domain use case)
           │       └── ReelsRepository (domain contract)
           │               └── ReelsRepositoryImpl (data)
           │                       └── ReelsRemoteDataSource → Firestore
           │
           ├── ReelsVideoManager (presentation)
           │       └── VideoCacheDataSource (data) → disk cache
           │
           └── PageView → ReelItem (Video entity + overlay)
```

### Folder structure

```
lib/features/reels/
├── reels_injection.dart              # wires data → domain (DI)
│
├── domain/                           # business rules, no Flutter/Firebase
│   ├── entities/video.dart           # pure Video entity
│   ├── repositories/reels_repository.dart
│   └── usecases/get_reels.dart
│
├── data/                             # external APIs & DTOs
│   ├── datasources/
│   │   ├── reels_remote_datasource.dart   # Firestore
│   │   └── video_cache_datasource.dart    # flutter_cache_manager
│   ├── models/video_model.dart            # Firestore → entity mapping
│   └── repositories/reels_repository_impl.dart
│
└── presentation/                     # UI only
    ├── pages/reels_page.dart
    ├── widgets/reel_item.dart
    └── services/reels_video_manager.dart  # playback orchestration
```

---

## 5. How Each Requirement Was Implemented

### 5.1 Fetch from Firestore

**Domain:** `GetReels` use case calls `ReelsRepository.getReels()`.  
**Data:** `ReelsRepositoryImpl` → `ReelsRemoteDataSourceImpl` queries Firestore; `VideoModel.fromFirestore` maps docs to entities.

```dart
_firestore.collection('videos').orderBy('createdAt', descending: true).get()
```

### 5.2 Preload 3 videos ahead

`ReelsVideoManager` initializes controllers for `currentIndex + 1`, `+2`, and `+3` in the background after the visible reel starts playing. Controllers far from the current index are disposed to limit memory use.

### 5.3 Cache videos

Video files are cached on **device disk** using the [`flutter_cache_manager`](https://pub.dev/packages/flutter_cache_manager) package, via `VideoCacheDataSource` in the data layer. See **[Section 6 — Video Caching (Detailed)](#6-video-caching--how-it-works-detailed)** for the full explanation, flow diagrams, and code walkthrough.

### 5.4 Auto-play / pause on scroll

- `PageView.onPageChanged` notifies `ReelsVideoManager`
- Previous reel: `pause()`
- Current reel: `play()`
- Preload ahead + dispose distant controllers
- `WidgetsBindingObserver` pauses all videos when the app goes to background

### 5.5 UI overlay

Each `ReelItem` shows:

- Full-screen video (or thumbnail + loader while initializing)
- Username + profile avatar
- Caption (`description`)
- Like and comment counts (formatted, e.g. 1.2K)
- Side action icons (like, comment, share — visual only)

---

## 6. Video Caching — How It Works (Detailed)

This section explains **requirement #3** (cache videos to avoid re-downloading) in a step-by-step way suitable for reviewers who may not be familiar with Flutter video apps.

### 6.1 What problem caching solves

Each reel’s `videoUrl` in Firestore points to a remote HTTPS MP4 (Mixkit CDN, etc.). Without caching:

- Every time the user opens or returns to a reel, the app would **download the full file again**
- Scrolling back up the feed would waste bandwidth and feel slow

With caching:

- The **first** time a URL is needed → download once and save on the phone
- **Later** times (same URL) → read the saved file from disk → **no network download**

Firestore only stores the URL string; the actual video bytes live on the CDN until the app caches them locally.

### 6.2 Library and wrapper

| Piece | Location | Role |
|-------|----------|------|
| **Package** | `flutter_cache_manager` (^3.4.1 in `pubspec.yaml`) | Downloads files, stores them on disk, returns a local `File` |
| **Default implementation** | `DefaultCacheManager()` | Built-in cache manager (no custom config in this project) |
| **Data layer** | `lib/features/reels/data/datasources/video_cache_datasource.dart` | `getVideoFile(url)` via `VideoCacheDataSource` |

The caching API lives in the **data layer** (`VideoCacheDataSourceImpl`):

```dart
class VideoCacheDataSourceImpl implements VideoCacheDataSource {
  Future<File> getVideoFile(String url) {
    return _cacheManager.getSingleFile(url);
  }
}
```

`getSingleFile(url)` is the core call. The package:

1. Treats the **full URL string** as the cache key  
2. If a valid cached file exists → returns it immediately  
3. If not → downloads the MP4, writes it to the device cache directory, then returns the `File`

### 6.3 End-to-end flow (first time vs cached)

```
┌─────────────────────────────────────────────────────────────────┐
│  Firestore document                                             │
│  videoUrl: "https://assets.mixkit.co/.../video.mp4"             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  ReelsVideoManager._ensureController(index)                     │
│  needs a player for this reel                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  VideoCacheDataSource.getVideoFile(videoUrl)                    │
│  → DefaultCacheManager().getSingleFile(url)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
     ┌─────────────────┐         ┌─────────────────┐
     │  CACHE MISS     │         │  CACHE HIT      │
     │  (first view)   │         │  (seen before)  │
     └────────┬────────┘         └────────┬────────┘
              │                           │
              ▼                           ▼
     Download MP4 from CDN        Read existing file
     Save to device storage       from disk (fast)
              │                           │
              └──────────────┬────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  Returns dart:io File (local path on device)                    │
└────────────────────────────┬────────────────────────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  VideoPlayerController.file(file)                               │
│  → initialize() → setLooping(true) → play()                     │
└─────────────────────────────────────────────────────────────────┘
```

**First time** you watch reel #5:

1. `getVideoFile` downloads the MP4 (network activity)  
2. File is stored under the app’s cache area managed by `flutter_cache_manager`  
3. `video_player` plays from that local path  

**Second time** you swipe back to reel #5:

1. `getVideoFile` finds the file on disk (cache hit)  
2. No download — player initializes from the same local `File`  
3. Playback starts much faster and uses no extra data for that file  

### 6.4 Where caching is called in code

Caching is **not** triggered from the UI layer directly. It happens inside `ReelsVideoManager` whenever a `VideoPlayerController` must be created:

```dart
Future<void> _ensureController(int index) async {
  if (_controllers.containsKey(index)) return;

  final video = _videos[index];
  final file = await _cacheDataSource.getVideoFile(video.videoUrl);  // ← cache step
  final controller = VideoPlayerController.file(file);            // ← play from disk

  await controller.initialize();
  await controller.setLooping(true);
  _controllers[index] = controller;
}
```

This runs for:

- The **currently visible** reel (on scroll or app start)  
- **Preloaded** reels (`index + 1`, `+2`, `+3`) — so the next swipes often already have files on disk before you arrive  

Preload and cache work together: preloading downloads and caches upcoming videos in the background; when you swipe, playback can start from an already-cached file.

### 6.5 Two layers: disk cache vs in-memory controllers

It helps to separate two different “caching” ideas used in the app:

| Layer | Technology | What is stored | When it is cleared |
|-------|------------|----------------|-------------------|
| **Disk cache** | `flutter_cache_manager` | MP4 files on device storage | Survives app restarts until evicted or `emptyCache()` |
| **Memory pool** | `Map<int, VideoPlayerController>` in `ReelsVideoManager` | Initialized video players for nearby indices | Controllers **disposed** when index is far from current; files **remain on disk** |

**Example:** You watch reels 0 → 1 → 2 → 3. The manager may dispose the controller for reel 0 to save RAM. If you scroll back to reel 0:

- The **controller** is recreated (small cost)  
- The **MP4 file** is still on disk (cache hit — no re-download)  

So disk caching satisfies the interview requirement; the controller pool is a separate memory optimization for smooth scrolling.

### 6.6 What is *not* cached the same way

Only **video MP4s** use `flutter_cache_manager`. These are loaded over the network on each build (no disk cache in this project):

| Asset | Field | How it loads |
|-------|-------|----------------|
| Thumbnail (while video loads) | `thumbnailUrl` | `Image.network` in `ReelItem` |
| Profile avatar | `userProfilePic` | `NetworkImage` in overlay |

A future improvement (listed in Section 9 — Future Improvements) would be `cached_network_image` for thumbnails and avatars. That is separate from reel video caching.

### 6.7 Clearing the cache (development)

When you tap **Reseed DB** on the reels screen, the app:

1. Rewrites Firestore seed documents (URLs/metadata may change)  
2. Calls `DefaultCacheManager().emptyCache()` to delete all locally cached MP4s  
3. Refetches the feed and rebuilds players  

This avoids playing an old cached file after seed URLs change. In production, cache invalidation would typically tie to URL changes or explicit version headers rather than a dev button.

### 6.8 Default cache behavior (no custom config)

This project uses `DefaultCacheManager()` with package defaults:

- **Cache key:** the video URL string  
- **Storage:** app-accessible cache directory on the device (platform-specific path managed by the package)  
- **Eviction:** the package applies default stale-time and size limits; old files may be removed automatically when the cache grows  

No custom TTL, max file count, or alternate `CacheManager` subclass was added — sufficient for the evaluation scope and easy to reason about in a task report.

### 6.9 Quick reference

| Question | Answer |
|----------|--------|
| What package? | `flutter_cache_manager` |
| What API? | `DefaultCacheManager().getSingleFile(videoUrl)` |
| Data entry point? | `VideoCacheDataSource.getVideoFile()` |
| Who calls it? | `ReelsVideoManager._ensureController()` |
| What gets cached? | Remote MP4 files (by URL) |
| What plays the file? | `video_player` via `VideoPlayerController.file()` |
| Scroll back — re-download? | No, if the file is still on disk |
| Reseed — cache cleared? | Yes, via `emptyCache()` |

---

## 7. Running the Project

### Prerequisites

- Flutter SDK (^3.7.2)
- Android Studio / Xcode for device or emulator
- Firebase project configured (`google-services.json` / `GoogleService-Info.plist`)
- Internet connection (Firestore + video CDN)

### Commands

```bash
flutter pub get
flutter run
```

Use a **full restart** (not hot reload) after adding native plugins like `video_player`.

### Reseeding the database

- Tap **Reseed DB** (top-right on the reels screen), or  
- Cold restart after bumping `seedVersion` in `lib/seeder.dart`

Reseed overwrites all 18 video documents and clears the local video cache.

---

## 8. Design Decisions & Trade-offs

| Decision | Rationale |
|----------|-----------|
| Mixkit CDN URLs in Firestore | Free, stable, vertical clips; no Firebase Storage cost |
| Metadata-only in Firestore | Matches real-world pattern (catalog vs media files) |
| `PageView` over `ListView` | One focused index → simpler autoplay logic |
| Fixed doc IDs + `seedVersion` | Idempotent seeding; easy dev reseed |
| Silent Mixkit B-roll | Acceptable for demo; audio not in task requirements |
| Clean architecture (domain / data / presentation) | Testable use cases; Firestore isolated in data layer |

---

## 9. Future Improvements

- Pagination (`startAfterDocument`) for feeds larger than 18 reels
- BLoC/Cubit for presentation state (domain/data layers already split)
- Remove dev **Reseed DB** button before production
- Mute / unmute toggle (Instagram-style UX)
- Firebase Storage for user-uploaded content
- Like / comment interactions wired to Firestore
- `cached_network_image` for avatar and thumbnail caching

---

## 10. Conclusion

VYbe fulfills the Round 1 evaluation requirements: Firestore-backed reel metadata, vertical scroll feed, local video caching (documented in detail in Section 6), preload-ahead buffering, scroll-driven autoplay/pause, and overlay UI for username, likes, and captions. The app demonstrates a practical short-video pipeline suitable for a Reels/TikTok-style product, with a clear path to production hardening via Firebase Storage, pagination, and clean architecture.
