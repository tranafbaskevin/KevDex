part of 'package:kevdex/main.dart';

bool isDriveFolderLink(String link) {
  return link.contains('/drive/folders/');
}

bool isMangaDexChapterLink(String link) {
  return extractMangaDexChapterId(link) != null;
}

StorySourceType detectStorySource(String link) {
  if (extractHentai2ReadTarget(link) != null) {
    return StorySourceType.hentai2ReadChapter;
  }

  if (extractNHentaiGalleryId(link) != null) {
    return StorySourceType.nHentaiGallery;
  }

  if (extractHitomiGalleryId(link) != null) {
    return StorySourceType.hitomiGallery;
  }

  if (extractMangaDexChapterId(link) != null) {
    return StorySourceType.mangaDexChapter;
  }

  if (extractDriveFolderId(link) != null) {
    return StorySourceType.driveFolder;
  }

  return StorySourceType.singlePage;
}

bool _matchesRequestedPrivateSource(
  StorySourceType requestedSourceType,
  String link,
) {
  return switch (requestedSourceType) {
    StorySourceType.hentai2ReadChapter =>
      extractHentai2ReadTarget(link) != null,
    StorySourceType.nHentaiGallery => extractNHentaiGalleryId(link) != null,
    StorySourceType.hitomiGallery => extractHitomiGalleryId(link) != null,
    StorySourceType.driveFolder ||
    StorySourceType.mangaDexChapter ||
    StorySourceType.singlePage => true,
  };
}

bool _sourceNeedsFetchedPages(StorySourceType sourceType) {
  return switch (sourceType) {
    StorySourceType.driveFolder ||
    StorySourceType.mangaDexChapter ||
    StorySourceType.hentai2ReadChapter ||
    StorySourceType.nHentaiGallery ||
    StorySourceType.hitomiGallery => true,
    StorySourceType.singlePage => false,
  };
}

String? extractDriveFolderId(String link) {
  final regExp = RegExp(r'/folders/([^/?]+)');
  final match = regExp.firstMatch(link);

  if (match == null) {
    return null;
  }

  return match.group(1);
}

String? extractMangaDexChapterId(String link) {
  const uuidPattern =
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
  final chapterPathMatch = RegExp(
    '/chapter/($uuidPattern)',
    caseSensitive: false,
  ).firstMatch(link);

  if (chapterPathMatch != null) {
    return chapterPathMatch.group(1);
  }

  final directIdMatch = RegExp(
    '^$uuidPattern\$',
    caseSensitive: false,
  ).firstMatch(link.trim());

  return directIdMatch?.group(0);
}

String? extractHentai2ReadTarget(String link) {
  final uri = _hentai2ReadUri(link);

  if (uri == null) {
    return null;
  }

  final segments = uri.pathSegments
      .where((segment) => segment.trim().isNotEmpty)
      .toList(growable: false);

  if (segments.isEmpty) {
    return null;
  }

  final slug = segments.first.trim();
  if (slug == 'hentai-list' || slug == 'search' || slug == 'tag') {
    return null;
  }

  if (segments.length >= 2 && RegExp(r'^\d+$').hasMatch(segments[1])) {
    return '$slug/${segments[1]}';
  }

  return slug;
}

String? extractHentai2ReadStorySlug(String link) {
  final target = extractHentai2ReadTarget(link);

  if (target == null) {
    return null;
  }

  return target.split('/').first;
}

String _hentai2ReadStoryLink(String slug) {
  return 'https://hentai2read.com/$slug/';
}

String _hentai2ReadChapterLink(String slug, String chapterId) {
  return 'https://hentai2read.com/$slug/$chapterId/';
}

Uri? _hentai2ReadUri(String link) {
  final cleanedLink = link.trim();

  if (cleanedLink.isEmpty) {
    return null;
  }

  final directMatch = RegExp(
    r'^(?:hentai2read|h2r):([a-zA-Z0-9_-]+)(?:/(\d+))?$',
  ).firstMatch(cleanedLink);

  if (directMatch != null) {
    final slug = directMatch.group(1)!;
    final chapterId = directMatch.group(2);
    return Uri.https(
      'hentai2read.com',
      chapterId == null ? '/$slug/' : '/$slug/$chapterId/',
    );
  }

  final normalized = cleanedLink.contains('://')
      ? cleanedLink
      : 'https://$cleanedLink';
  final uri = Uri.tryParse(normalized);
  final host = uri?.host.toLowerCase() ?? '';

  if (uri == null || !host.contains('hentai2read.com')) {
    return null;
  }

  return uri;
}
