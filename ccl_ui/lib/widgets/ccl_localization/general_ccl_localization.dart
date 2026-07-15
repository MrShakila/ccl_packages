part of '../widgets.dart';

/// Framework-agnostic counterpart to [CCLLocalization].
///
/// [CCLLocalization] stays as-is for existing Stacked apps (builds
/// [CCLLocalizationModel] via `StackedView`). This widget is a separate,
/// additive type for non-Stacked consumers (GetX, Provider, plain Flutter,
/// ...): it listens directly to a [GeneralLocalizationService] (a plain
/// `ChangeNotifier`) and rebuilds `CCLLocalizationProvider` with the
/// updated locale whenever it changes.
class GeneralCCLLocalization extends StatefulWidget {
  /// The child widget to localize.
  final Widget child;

  /// The service to read the current locale from and listen to for changes.
  final GeneralLocalizationService localizationService;

  const GeneralCCLLocalization({
    super.key,
    required this.child,
    required this.localizationService,
  });

  @override
  State<GeneralCCLLocalization> createState() =>
      _GeneralCCLLocalizationState();
}

class _GeneralCCLLocalizationState extends State<GeneralCCLLocalization> {
  @override
  void initState() {
    super.initState();
    widget.localizationService.addListener(_onLocaleChanged);
  }

  @override
  void didUpdateWidget(covariant GeneralCCLLocalization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localizationService != widget.localizationService) {
      oldWidget.localizationService.removeListener(_onLocaleChanged);
      widget.localizationService.addListener(_onLocaleChanged);
    }
  }

  @override
  void dispose() {
    widget.localizationService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return CCLLocalizationProvider(
      locale: widget.localizationService.locale,
      child: widget.child,
    );
  }
}
