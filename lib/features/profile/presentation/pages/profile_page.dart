import 'package:flutter/material.dart';
import 'package:vybe/core/widgets/loader/custom_loader.dart';
import 'package:vybe/features/profile/data/profile_content_loader.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';

import '../widgets/header/profile_header.dart';
import '../widgets/tab/profile_tab_body.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.onBack,
    required this.onVideoSelected,
    required this.videosProvider,
  });

  final VoidCallback? onBack;
  final ValueChanged<Video> onVideoSelected;
  final List<Video> Function() videosProvider;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  ProfileContent? _content;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    if (!mounted) return;
    setState(() {
      _loading = _content == null;
      _error = null;
    });

    try {
      final loader = ProfileContentLoader();
      final content = await loader.load(widget.videosProvider());
      if (!mounted) return;
      setState(() {
        _content = content;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load profile';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CustomLoader(size: 56, gap: 8, borderRadius: 14),
        ),
      );
    }

    if (_error != null || _content == null) {
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error ?? 'Something went wrong',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: reload, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final content = _content!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                ProfileHeader(
                  profile: content.profile,
                  onBack: widget.onBack,
                ),
              ],
          body: ProfileTabBody(
            content: content,
            onVideoSelected: widget.onVideoSelected,
          ),
        ),
      ),
    );
  }
}
