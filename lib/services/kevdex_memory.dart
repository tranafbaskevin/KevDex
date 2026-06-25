part of 'package:kevdex/main.dart';

final ValueNotifier<ReadingProgress?> readingProgressNotifier =
    ValueNotifier<ReadingProgress?>(null);

final ValueNotifier<List<LibraryItem>> libraryNotifier =
    ValueNotifier<List<LibraryItem>>(const <LibraryItem>[]);

final ValueNotifier<UiBackground> uiBackgroundNotifier =
    ValueNotifier<UiBackground>(defaultUiBackground);

final ValueNotifier<ReaderComfortSettings> readerComfortNotifier =
    ValueNotifier<ReaderComfortSettings>(defaultReaderComfortSettings);

final ValueNotifier<PrivateSourceSettings> privateSourceSettingsNotifier =
    ValueNotifier<PrivateSourceSettings>(defaultPrivateSourceSettings);

class KevDexMemory {
  static const String _lastLinkKey = 'kevdex.lastLink';
  static const String _lastDriveLinkKey = 'kevdex.lastDriveLink';
  static const String _lastMangaDexLinkKey = 'kevdex.lastMangaDexLink';
  static const String _lastNHentaiLinkKey = 'kevdex.lastNHentaiLink';
  static const String _lastHitomiLinkKey = 'kevdex.lastHitomiLink';
  static const String _lastHentai2ReadLinkKey = 'kevdex.lastHentai2ReadLink';
  static const String _readerProgressKey = 'kevdex.readerProgress';
  static const String _libraryKey = 'kevdex.library';
  static const String _uiBackgroundKey = 'kevdex.uiBackground';
  static const String _readerComfortKey = 'kevdex.readerComfort';
  static const String _privateSourceSettingsKey =
      'kevdex.privateSourceSettings';
  static const String _customBackgroundFileName = 'kevdex_custom_background';

  static SharedPreferences? _preferences;
  static String? lastLink;
  static String? lastDriveLink;
  static String? lastMangaDexLink;
  static String? lastNHentaiLink;
  static String? lastHitomiLink;
  static String? lastHentai2ReadLink;

  const KevDexMemory._();

  static Future<void> load() async {
    final preferences = await _loadPreferences();
    lastLink = preferences.getString(_lastLinkKey);
    lastDriveLink = preferences.getString(_lastDriveLinkKey);
    lastMangaDexLink = preferences.getString(_lastMangaDexLinkKey);
    lastNHentaiLink = preferences.getString(_lastNHentaiLinkKey);
    lastHitomiLink = preferences.getString(_lastHitomiLinkKey);
    lastHentai2ReadLink = preferences.getString(_lastHentai2ReadLinkKey);
    _restoreReadingProgress(preferences);
    _restoreLibrary(preferences);
    _restoreUiBackground(preferences);
    _restoreReaderComfort(preferences);
    _restorePrivateSourceSettings(preferences);
  }

  static Future<void> saveLastLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastLinkKey);
      lastLink = null;
      return;
    }

    lastLink = cleanedLink;
    await preferences.setString(_lastLinkKey, cleanedLink);
  }

  static Future<void> saveLastDriveLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastDriveLinkKey);
      lastDriveLink = null;
      return;
    }

    lastDriveLink = cleanedLink;
    await preferences.setString(_lastDriveLinkKey, cleanedLink);
  }

  static Future<void> saveLastMangaDexLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastMangaDexLinkKey);
      lastMangaDexLink = null;
      return;
    }

    lastMangaDexLink = cleanedLink;
    await preferences.setString(_lastMangaDexLinkKey, cleanedLink);
  }

  static Future<void> saveLastNHentaiLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastNHentaiLinkKey);
      lastNHentaiLink = null;
      return;
    }

    lastNHentaiLink = cleanedLink;
    await preferences.setString(_lastNHentaiLinkKey, cleanedLink);
  }

  static Future<void> saveLastHitomiLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastHitomiLinkKey);
      lastHitomiLink = null;
      return;
    }

    lastHitomiLink = cleanedLink;
    await preferences.setString(_lastHitomiLinkKey, cleanedLink);
  }

  static Future<void> saveLastHentai2ReadLink(String link) async {
    final cleanedLink = link.trim();
    final preferences = await _loadPreferences();

    if (cleanedLink.isEmpty) {
      await preferences.remove(_lastHentai2ReadLinkKey);
      lastHentai2ReadLink = null;
      return;
    }

    lastHentai2ReadLink = cleanedLink;
    await preferences.setString(_lastHentai2ReadLinkKey, cleanedLink);
  }

  static Future<void> saveReadingProgress(ReadingProgress progress) async {
    final preferences = await _loadPreferences();
    await preferences.setString(_readerProgressKey, jsonEncode(progress));
    await upsertLibraryItem(LibraryItem.fromProgress(progress));
  }

  static Future<void> upsertLibraryItem(LibraryItem item) async {
    final preferences = await _loadPreferences();
    final nextItems = <LibraryItem>[
      item,
      ...libraryNotifier.value.where(
        (currentItem) => currentItem.sourceLink != item.sourceLink,
      ),
    ];

    libraryNotifier.value = List<LibraryItem>.unmodifiable(
      nextItems.take(_maxLibraryItems).toList(growable: false),
    );
    await preferences.setString(_libraryKey, jsonEncode(libraryNotifier.value));
  }

  static Future<void> removeLibraryItem(String sourceLink) async {
    final preferences = await _loadPreferences();
    libraryNotifier.value = List<LibraryItem>.unmodifiable(
      libraryNotifier.value
          .where((item) => item.sourceLink != sourceLink)
          .toList(growable: false),
    );
    await preferences.setString(_libraryKey, jsonEncode(libraryNotifier.value));
  }

  static Future<void> saveUiBackground(UiBackground background) async {
    final preferences = await _loadPreferences();
    await preferences.setString(_uiBackgroundKey, jsonEncode(background));
  }

  static Future<void> saveReaderComfort(ReaderComfortSettings settings) async {
    final preferences = await _loadPreferences();
    await preferences.setString(_readerComfortKey, jsonEncode(settings));
  }

  static Future<void> savePrivateSourceSettings(
    PrivateSourceSettings settings,
  ) async {
    final preferences = await _loadPreferences();
    privateSourceSettingsNotifier.value = settings;

    if (!settings.enabled) {
      await preferences.remove(_privateSourceSettingsKey);
      return;
    }

    await preferences.setString(
      _privateSourceSettingsKey,
      jsonEncode(settings),
    );
  }

  static Future<void> clearPrivateHistory() async {
    final preferences = await _loadPreferences();
    final cachedUrls = _cachedImageUrls(privateOnly: true);
    final progress = readingProgressNotifier.value;

    if (progress != null && progress.isPrivateSource) {
      readingProgressNotifier.value = null;
      await preferences.remove(_readerProgressKey);
    }

    final publicItems = libraryNotifier.value
        .where((item) => !item.isPrivateSource)
        .toList(growable: false);

    libraryNotifier.value = List<LibraryItem>.unmodifiable(publicItems);
    await preferences.setString(_libraryKey, jsonEncode(libraryNotifier.value));

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await _evictCachedImages(cachedUrls);
  }

  static Future<void> clearAppCache() async {
    final preferences = await _loadPreferences();
    final cachedUrls = _cachedImageUrls();

    await Future.wait([
      preferences.remove(_lastLinkKey),
      preferences.remove(_lastDriveLinkKey),
      preferences.remove(_lastMangaDexLinkKey),
      preferences.remove(_lastNHentaiLinkKey),
      preferences.remove(_lastHitomiLinkKey),
      preferences.remove(_lastHentai2ReadLinkKey),
      preferences.remove(_readerProgressKey),
      preferences.remove(_libraryKey),
      preferences.remove(_uiBackgroundKey),
      preferences.remove(_readerComfortKey),
      preferences.remove(_privateSourceSettingsKey),
    ]);

    lastLink = null;
    lastDriveLink = null;
    lastMangaDexLink = null;
    lastNHentaiLink = null;
    lastHitomiLink = null;
    lastHentai2ReadLink = null;
    readingProgressNotifier.value = null;
    libraryNotifier.value = const <LibraryItem>[];
    uiBackgroundNotifier.value = defaultUiBackground;
    readerComfortNotifier.value = defaultReaderComfortSettings;
    privateSourceSettingsNotifier.value = defaultPrivateSourceSettings;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    await _evictCachedImages(cachedUrls);
    await _deleteCustomBackgrounds();
  }

  static Future<UiBackground> saveCustomUiBackground(XFile image) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final backgroundDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}kevdex_backgrounds',
    );
    await backgroundDirectory.create(recursive: true);

    final extension = _fileExtension(image.name).isEmpty
        ? _fileExtension(image.path)
        : _fileExtension(image.name);
    final targetPath =
        '${backgroundDirectory.path}${Platform.pathSeparator}'
        '$_customBackgroundFileName${extension.isEmpty ? '.jpg' : extension}';
    final copiedImage = await File(image.path).copy(targetPath);
    final background = UiBackground.file(
      title: 'My Image',
      path: copiedImage.path,
    );

    await saveUiBackground(background);
    return background;
  }

  static Set<String> _cachedImageUrls({bool privateOnly = false}) {
    final urls = <String>{};

    void addImage(DriveImage image) {
      urls.add(image.thumbnailUrl);
      urls.add(image.fullUrl);
    }

    void addProgress(ReadingProgress progress) {
      for (final image in progress.images) {
        addImage(image);
      }

      final thumbnailUrl = progress.thumbnailUrl;
      if (thumbnailUrl != null) {
        urls.add(thumbnailUrl);
      }
    }

    final progress = readingProgressNotifier.value;
    if (progress != null && (!privateOnly || progress.isPrivateSource)) {
      addProgress(progress);
    }

    for (final item in libraryNotifier.value) {
      if (privateOnly && !item.isPrivateSource) {
        continue;
      }

      for (final image in item.images) {
        addImage(image);
      }

      final thumbnailUrl = item.thumbnailUrl;
      if (thumbnailUrl != null) {
        urls.add(thumbnailUrl);
      }
    }

    urls.removeWhere((url) => url.trim().isEmpty);
    return urls;
  }

  static Future<void> _evictCachedImages(Set<String> urls) async {
    await Future.wait(
      urls.map((url) async {
        try {
          await CachedNetworkImage.evictFromCache(url);
        } catch (_) {}
      }),
    );
  }

  static Future<void> _deleteCustomBackgrounds() async {
    try {
      final appDirectory = await getApplicationDocumentsDirectory();
      final backgroundDirectory = Directory(
        '${appDirectory.path}${Platform.pathSeparator}kevdex_backgrounds',
      );

      if (await backgroundDirectory.exists()) {
        await backgroundDirectory.delete(recursive: true);
      }
    } catch (_) {}
  }

  static Future<SharedPreferences> _loadPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  static void _restoreReadingProgress(SharedPreferences preferences) {
    final rawProgress = preferences.getString(_readerProgressKey);

    if (rawProgress == null) {
      return;
    }

    try {
      final progress = ReadingProgress.fromJson(jsonDecode(rawProgress));

      if (progress != null) {
        readingProgressNotifier.value = progress;
      }
    } on FormatException {
      preferences.remove(_readerProgressKey);
    }
  }

  static void _restoreLibrary(SharedPreferences preferences) {
    final rawLibrary = preferences.getString(_libraryKey);

    if (rawLibrary == null) {
      return;
    }

    try {
      final decodedLibrary = jsonDecode(rawLibrary);

      if (decodedLibrary is! List) {
        return;
      }

      final items = decodedLibrary
          .map(LibraryItem.fromJson)
          .whereType<LibraryItem>()
          .toList(growable: false);

      if (items.isNotEmpty) {
        libraryNotifier.value = List<LibraryItem>.unmodifiable(items);
      }
    } on FormatException {
      preferences.remove(_libraryKey);
    }
  }

  static void _restoreUiBackground(SharedPreferences preferences) {
    final rawBackground = preferences.getString(_uiBackgroundKey);

    if (rawBackground == null) {
      return;
    }

    try {
      final background = UiBackground.fromJson(jsonDecode(rawBackground));

      if (background == null) {
        return;
      }

      if (!background.isAsset && !File(background.path).existsSync()) {
        return;
      }

      uiBackgroundNotifier.value = background;
    } on FormatException {
      preferences.remove(_uiBackgroundKey);
    }
  }

  static void _restoreReaderComfort(SharedPreferences preferences) {
    final rawSettings = preferences.getString(_readerComfortKey);

    if (rawSettings == null) {
      return;
    }

    try {
      final settings = ReaderComfortSettings.fromJson(jsonDecode(rawSettings));

      if (settings != null) {
        readerComfortNotifier.value = settings;
      }
    } on FormatException {
      preferences.remove(_readerComfortKey);
    }
  }

  static void _restorePrivateSourceSettings(SharedPreferences preferences) {
    final rawSettings = preferences.getString(_privateSourceSettingsKey);

    if (rawSettings == null) {
      return;
    }

    try {
      final settings = PrivateSourceSettings.fromJson(jsonDecode(rawSettings));

      if (settings != null) {
        privateSourceSettingsNotifier.value = settings;
      }
    } on FormatException {
      preferences.remove(_privateSourceSettingsKey);
    }
  }

  static String _fileExtension(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final fileName = normalizedPath.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex < 0 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex).toLowerCase();
  }
}
