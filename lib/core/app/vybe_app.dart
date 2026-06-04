import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vybe/core/network/app_network.dart';
import 'package:vybe/core/network/network_info.dart';
import 'package:vybe/core/theme/app_theme.dart';
import 'package:vybe/core/widgets/connectivity/app_connectivity_overlay.dart';
import 'package:vybe/core/widgets/connectivity/offline_launch_view.dart';
import 'package:vybe/core/widgets/connectivity/app_connectivity_bar.dart';
import 'package:vybe/core/widgets/loader/custom_loader.dart';
import 'package:vybe/features/reels/presentation/pages/reels_page.dart';

enum _AppLaunchState { loading, offline, ready }

class VybeApp extends StatefulWidget {
  const VybeApp({super.key, this.networkInfo});

  final NetworkInfo? networkInfo;

  @override
  State<VybeApp> createState() => _VybeAppState();
}

class _VybeAppState extends State<VybeApp> {
  static const _reconnectedDismissDelay = Duration(seconds: 2);

  late final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _reconnectedTimer;

  _AppLaunchState _launchState = _AppLaunchState.loading;
  ThemeData _theme = AppTheme.fallbackDarkTheme;
  ConnectivityBarMode _barMode = ConnectivityBarMode.hidden;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _networkInfo = widget.networkInfo ?? AppNetwork.instance;
    GoogleFonts.config.allowRuntimeFetching = false;
    _bootstrap();
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  Future<void> _bootstrap() async {
    final connected = await _networkInfo.isConnected;
    if (!mounted) return;

    if (!connected) {
      setState(() {
        _launchState = _AppLaunchState.offline;
        _barMode = ConnectivityBarMode.offline;
        _wasOffline = true;
        _theme = AppTheme.fallbackDarkTheme;
      });
      return;
    }

    await _loadThemeAndEnterApp();
  }

  Future<void> _loadThemeAndEnterApp() async {
    if (!mounted) return;

    setState(() => _launchState = _AppLaunchState.loading);

    final theme = await AppTheme.loadDarkTheme();
    if (!mounted) return;

    setState(() {
      _theme = theme;
      _launchState = _AppLaunchState.ready;
    });
  }

  void _onConnectivityChanged(bool connected) {
    _reconnectedTimer?.cancel();

    if (!connected) {
      setState(() {
        _wasOffline = true;
        _barMode = ConnectivityBarMode.offline;
        if (_launchState != _AppLaunchState.ready) {
          _launchState = _AppLaunchState.offline;
        }
      });
      return;
    }

    if (_wasOffline) {
      _wasOffline = false;
      setState(() => _barMode = ConnectivityBarMode.reconnected);
      _reconnectedTimer = Timer(_reconnectedDismissDelay, () {
        if (!mounted) return;
        setState(() => _barMode = ConnectivityBarMode.hidden);
      });

      if (_launchState == _AppLaunchState.offline) {
        _loadThemeAndEnterApp();
      }
      return;
    }

    setState(() => _barMode = ConnectivityBarMode.hidden);
  }

  Widget _buildHome() {
    return switch (_launchState) {
      _AppLaunchState.loading => const Scaffold(
        body: Center(child: CustomLoader(size: 80, gap: 10, borderRadius: 18)),
      ),
      _AppLaunchState.offline => OfflineLaunchView(onRetry: _bootstrap),
      _AppLaunchState.ready => const ReelsPage(),
    };
  }

  @override
  void dispose() {
    _reconnectedTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYbe',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      builder:
          (context, child) => AppConnectivityOverlay(
            barMode: _barMode,
            child: child ?? const SizedBox.shrink(),
          ),
      home: _buildHome(),
    );
  }
}
