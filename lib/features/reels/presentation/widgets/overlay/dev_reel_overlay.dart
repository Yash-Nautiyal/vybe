import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vybe/core/widgets/button/custom_action_button.dart';

import '../../bloc/reels_bloc.dart';
import '../../bloc/reels_event.dart';
import '../../bloc/reels_state.dart';

class DevReelOverlay extends StatelessWidget {
  const DevReelOverlay({super.key, this.pageController});

  final PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<ReelsBloc, ReelsState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomActionButton(
                    label: 'Reseed DB',
                    loadingLabel: 'Reseeding',
                    icon: Icons.refresh,
                    isLoading: state.isReseeding || state.isClearingCache,
                    onPressed: () {
                      context.read<ReelsBloc>().add(
                        const ReelsReseedRequested(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomActionButton(
                    label: 'Clear Cache',
                    loadingLabel: 'Clearing',
                    icon: Icons.delete_outline,
                    isLoading: state.isClearingCache || state.isReseeding,
                    onPressed: () {
                      final index =
                          pageController != null && pageController!.hasClients
                              ? (pageController!.page?.round() ?? 0)
                              : 0;
                      context.read<ReelsBloc>().add(
                        ReelsClearCacheRequested(restartIndex: index),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
