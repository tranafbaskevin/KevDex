part of 'package:kevdex/main.dart';

const Color _appBackground = Color(0xFF101016);
const Color _surfaceColor = Color(0xFF1A1A22);
const Color _fieldColor = Color(0xFF20202A);
const Color _glassSurfaceColor = Color(0xE61A1A22);
const Color _primaryAccent = Color(0xFF9BE7C9);
const Color _secondaryAccent = Color(0xFFFFB86B);
const Color _mutedText = Color(0xFFB7B6C6);
const String _defaultBackgroundAsset =
    'assets/images/kevdex_anime_library_bg.png';
const String _hallwayBackgroundAsset =
    'assets/images/kevdex_bg_manga_hallway.png';
const String _eyeBackgroundAsset = 'assets/images/kevdex_bg_manga_eye.png';
const String _shadowBackgroundAsset =
    'assets/images/kevdex_bg_manga_shadow.png';

Color _backgroundOverlay(double opacity) {
  final alpha = (opacity.clamp(0.0, 1.0) * 255).round();
  return _appBackground.withAlpha(alpha);
}

const UiBackground defaultUiBackground = UiBackground.asset(
  title: 'KevDex Library',
  path: _defaultBackgroundAsset,
);

const List<UiBackground> _presetUiBackgrounds = [
  defaultUiBackground,
  UiBackground.asset(title: 'Hallway', path: _hallwayBackgroundAsset),
  UiBackground.asset(title: 'Midnight Eye', path: _eyeBackgroundAsset),
  UiBackground.asset(title: 'Shadow Reader', path: _shadowBackgroundAsset),
];

enum ReaderFitMode {
  fitWidth(
    label: 'Width',
    icon: Icons.fit_screen_rounded,
    fit: BoxFit.fitWidth,
  ),
  fullPage(label: 'Page', icon: Icons.crop_free_rounded, fit: BoxFit.contain);

  final String label;
  final IconData icon;
  final BoxFit fit;

  const ReaderFitMode({
    required this.label,
    required this.icon,
    required this.fit,
  });
}

class ReaderComfortSettings {
  final ReaderFitMode fitMode;
  final double shade;

  const ReaderComfortSettings({required this.fitMode, required this.shade});

  ReaderComfortSettings copyWith({ReaderFitMode? fitMode, double? shade}) {
    return ReaderComfortSettings(
      fitMode: fitMode ?? this.fitMode,
      shade: shade ?? this.shade,
    );
  }

  Map<String, Object?> toJson() {
    return {'fitMode': fitMode.name, 'shade': shade};
  }

  static ReaderComfortSettings? fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }

    final fitModeName = value['fitMode'];
    final shadeValue = value['shade'];

    if (fitModeName is! String || shadeValue is! num) {
      return null;
    }

    ReaderFitMode? fitMode;
    for (final mode in ReaderFitMode.values) {
      if (mode.name == fitModeName) {
        fitMode = mode;
        break;
      }
    }

    if (fitMode == null) {
      return null;
    }

    return ReaderComfortSettings(
      fitMode: fitMode,
      shade: shadeValue.toDouble().clamp(0.0, 0.55),
    );
  }
}

const ReaderComfortSettings defaultReaderComfortSettings =
    ReaderComfortSettings(fitMode: ReaderFitMode.fitWidth, shade: 0);
const PrivateSourceSettings defaultPrivateSourceSettings =
    PrivateSourceSettings(enabled: false);
const int _maxLibraryItems = 10;
