part of '../widgets.dart';

/// Framework-agnostic counterpart to [BackgroundProgress].
///
/// [BackgroundProgress] stays as-is for existing Stacked apps (couples to
/// `ViewModelWidget<T extends BaseViewModel>`). This widget is a separate,
/// additive type for non-Stacked consumers (GetX, Provider, plain Flutter,
/// ...): it takes any [Listenable] (a `ChangeNotifier`, a
/// `ValueNotifier<bool>`, ...) and rebuilds whenever it notifies, reading
/// busy state through [isBusy].
///
/// * `listenable`: notifies this widget to rebuild.
/// * `isBusy`: returns the current busy state, read on every rebuild.
/// * `child`: The widget to be displayed behind the progress indicator.
/// * `message`: An optional message to display below the progress indicator.
/// * `blurBackground`: Whether to blur the background while the progress indicator is shown.
class GeneralBackgroundProgress extends StatelessWidget {
  /// Notifies this widget to rebuild.
  final Listenable listenable;

  /// Returns the current busy state, read on every rebuild.
  final bool Function() isBusy;

  /// The widget to be displayed behind the progress indicator.
  final Widget child;

  /// An optional message to display below the progress indicator.
  final String? message;

  /// Whether to blur the background while the progress indicator is shown.
  final bool blurBackground;

  const GeneralBackgroundProgress({
    super.key,
    required this.listenable,
    required this.isBusy,
    required this.child,
    this.blurBackground = true,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final busy = isBusy();

        final progressWidget = Container(
          decoration: BoxDecoration(
              color: context.colors.primaryContainer.withOpacity(0.5)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(strokeWidth: 3.0),
                if (message.isNotNullOrEmpty) ...[
                  verticalSpaceLight,
                  Text(
                    message!,
                    style: context.styleTitleMedium?.copyWith(
                      color: context.colors.onPrimaryContainer,
                      shadows: [
                        BoxShadow(
                          color: context.colors.primaryContainer,
                          spreadRadius: 5.0,
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 2000),
          child: Stack(
            children: [
              child,
              if (busy)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: busy ? 1 : 0,
                    duration: const Duration(milliseconds: 2000),
                    child: blurBackground
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: progressWidget,
                          )
                        : progressWidget,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
