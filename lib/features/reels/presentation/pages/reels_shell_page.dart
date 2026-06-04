import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/core/theme/app_theme.dart';
import 'package:vybe/features/profile/presentation/pages/profile_page.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_bloc.dart';
import 'package:vybe/features/reels/presentation/bloc/reels_event.dart';
import 'package:vybe/features/reels/presentation/pages/reels_page.dart';
import 'package:vybe/features/reels/domain/entities/video.dart';
import 'package:vybe/features/reels/reels_injection.dart';

/// Horizontal shell: reels (index 0, dark) ← swipe left → profile (index 1, light).
class ReelsShellPage extends StatefulWidget {
  const ReelsShellPage({super.key});

  @override
  State<ReelsShellPage> createState() => _ReelsShellPageState();
}

class _ReelsShellPageState extends State<ReelsShellPage> {
  final PageController _shellController = PageController();
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  late final ReelsBloc _reelsBloc = ReelsInjection.createReelsBloc();
  int _reelIndex = 0;
  int _currentPage = 0;
  bool _reelsPausedForProfile = false;

  ThemeData _darkTheme = AppTheme.fallbackDarkTheme;
  ThemeData _lightTheme = AppTheme.fallbackLightTheme;

  @override
  void initState() {
    super.initState();
    _shellController.addListener(_syncReelsPlaybackWithShellPosition);
    _reelsBloc.add(const ReelsLoadRequested());
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    final results = await Future.wait([
      AppTheme.loadDarkTheme(),
      AppTheme.loadLightTheme(),
    ]);
    if (!mounted) return;
    setState(() {
      _darkTheme = results[0];
      _lightTheme = results[1];
    });
  }

  @override
  void dispose() {
    _shellController.removeListener(_syncReelsPlaybackWithShellPosition);
    _shellController.dispose();
    _reelsBloc.close();
    super.dispose();
  }

  SystemUiOverlayStyle get _statusBarStyle {
    if (_currentPage == 0) {
      return SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      );
    }
    return SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    );
  }

  Future<void> _goToReels() async {
    if (!_shellController.hasClients) return;
    await _shellController.animateToPage(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _openProfileVideo(Video video) {
    final selectedIndex = _reelsBloc.state.videos.indexWhere(
      (candidate) => candidate.id == video.id,
    );
    if (selectedIndex != -1) {
      _reelIndex = selectedIndex;
    }

    unawaited(
      _goToReels().then((_) {
        if (!mounted || _reelsBloc.isClosed) return;
        _reelsBloc.add(ReelsVideoSelected(video.id));
      }),
    );
  }

  void _syncReelsPlaybackWithShellPosition() {
    final page = _shellController.page ?? 0;
    final shouldPause = page > 0.02;

    if (shouldPause && !_reelsPausedForProfile) {
      _reelsPausedForProfile = true;
      _reelsBloc.add(const ReelsPlaybackPaused());
      return;
    }

    if (!shouldPause && _reelsPausedForProfile) {
      _reelsPausedForProfile = false;
      _reelsBloc.add(ReelsPlaybackResumed(index: _reelIndex));
    }
  }

  void _onShellPageChanged(int index) {
    setState(() => _currentPage = index);

    if (index == 1) {
      _profileKey.currentState?.reload();
      if (!_reelsPausedForProfile) {
        _reelsPausedForProfile = true;
        _reelsBloc.add(const ReelsPlaybackPaused());
      }
      return;
    }

    if (_reelsPausedForProfile) {
      _reelsPausedForProfile = false;
      _reelsBloc.add(ReelsPlaybackResumed(index: _reelIndex));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _statusBarStyle,
      child: BlocProvider.value(
        value: _reelsBloc,
        child: PageView(
          controller: _shellController,
          scrollDirection: Axis.horizontal,
          allowImplicitScrolling: true,
          onPageChanged: _onShellPageChanged,
          children: [
            Theme(
              data: _darkTheme,
              child: ReelsPage(
                reelsBloc: _reelsBloc,
                onReelIndexChanged: (index) => _reelIndex = index,
              ),
            ),
            Theme(
              data: _lightTheme,
              child: ProfilePage(
                key: _profileKey,
                onBack: _goToReels,
                onVideoSelected: _openProfileVideo,
                videosProvider: () => _reelsBloc.state.videos,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
