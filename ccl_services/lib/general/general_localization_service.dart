part of '../ccl_services.dart';

/// Framework-agnostic counterpart to [LocalizationService].
///
/// [LocalizationService] stays as-is for existing Stacked apps (pulls
/// [SecureStorageService] from [StackedLocator], uses `ListenableServiceMixin`).
/// This class is a separate, additive type for non-Stacked consumers (GetX,
/// Provider, plain Flutter, ...): dependencies are passed via the
/// constructor instead of a service locator, and changes are broadcast
/// through the standard [ChangeNotifier] API that any state management
/// approach can listen to.
class GeneralLocalizationService extends ChangeNotifier {
  /// Logging tag for this service.
  // ignore: constant_identifier_names
  static const String TAG = 'GeneralLocalizationService';

  /// The secure storage service used to persist the locale.
  final SecureStorageService _secureStorageService;

  /// The fallback locale to use if no locale is saved in secure storage.
  final Locale? _fallbackLocale;

  /// The list of supported locales.
  final List<Locale>? _supportedLocales;

  /// The current locale.
  late Locale _locale;

  /// Creates a new `GeneralLocalizationService`.
  ///
  /// The [secureStorageService] is used to persist the selected locale.
  /// The [fallbackLocale] is used if no locale is saved in secure storage.
  /// The [supportedLocales] is a list of locales that the app supports.
  GeneralLocalizationService({
    required SecureStorageService secureStorageService,
    Locale? fallbackLocale,
    List<Locale>? supportedLocales,
  })  : _secureStorageService = secureStorageService,
        _fallbackLocale = fallbackLocale,
        _supportedLocales = supportedLocales;

  /// Initializes the service by loading the locale from secure storage.
  ///
  /// Call this once after construction and before reading [locale].
  Future<void> init() async {
    _locale = await _getLocale();
  }

  /// The current locale.
  Locale get locale => _locale;

  /// Updates the current locale and persists it to secure storage.
  Future<void> setLocale(Locale locale) async {
    await _secureStorageService.locale.set(locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  /// Gets the locale from secure storage or returns a fallback locale.
  Future<Locale> _getLocale() async {
    final savedLocale = await _secureStorageService.locale.read();

    if (savedLocale.isNotNullOrEmpty) {
      return Locale(savedLocale!);
    }

    if (_fallbackLocale != null) {
      return _fallbackLocale;
    }

    if (_supportedLocales.isListNotEmptyOrNull) {
      return _supportedLocales!.first;
    }

    return Locale(Intl.getCurrentLocale());
  }
}
