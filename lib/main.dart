import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color _appBackground = Color(0xFF101016);
const Color _surfaceColor = Color(0xFF1A1A22);
const Color _fieldColor = Color(0xFF20202A);
const Color _primaryAccent = Color(0xFF9BE7C9);
const Color _secondaryAccent = Color(0xFFFFB86B);
const Color _mutedText = Color(0xFFB7B6C6);

void main() {
  runApp(const DriveReaderApp());
}

class DriveImage {
  final String thumbnailUrl;
  final String fullUrl;

  const DriveImage({required this.thumbnailUrl, required this.fullUrl});
}

class DriveReaderApp extends StatelessWidget {
  const DriveReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KevDex',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _appBackground,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: _primaryAccent,
              brightness: Brightness.dark,
            ).copyWith(
              primary: _primaryAccent,
              secondary: _secondaryAccent,
              surface: _surfaceColor,
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _fieldColor,
          hintStyle: const TextStyle(color: Color(0xFF8E8C99)),
          prefixIconColor: _mutedText,
          suffixIconColor: _mutedText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF393745)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF393745)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primaryAccent, width: 1.4),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController linkController = TextEditingController();
  bool isOpening = false;

  @override
  void dispose() {
    linkController.dispose();
    super.dispose();
  }

  Future<void> _openReader() async {
    if (isOpening) {
      return;
    }

    final link = linkController.text.trim();

    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a story link first.')),
      );
      return;
    }

    final folderId = extractDriveFolderId(link);

    List<DriveImage> images = [];

    setState(() {
      isOpening = true;
    });

    try {
      if (folderId != null) {
        images = await fetchDriveFolderImages(folderId);
      }
    } finally {
      if (mounted) {
        setState(() {
          isOpening = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReaderPage(link: link, images: images, initialIndex: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _KevDexHeader(),
                  const SizedBox(height: 28),
                  TextField(
                    controller: linkController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'https://drive.google.com/...',
                      prefixIcon: const Icon(Icons.link_rounded),
                      suffixIcon: IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: linkController.clear,
                      ),
                    ),
                    onSubmitted: (_) => _openReader(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: isOpening ? null : _openReader,
                      icon: isOpening
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF121217),
                              ),
                            )
                          : const Icon(Icons.menu_book_rounded),
                      label: Text(
                        isOpening ? 'Gathering pages...' : 'Open Reader',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryAccent,
                        foregroundColor: const Color(0xFF121217),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'By Kevin and Dora-chan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KevDexHeader extends StatelessWidget {
  const _KevDexHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2F2D39)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 48,
            color: _primaryAccent,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'KevDex',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36,
            height: 1,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Read Anywhere.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _secondaryAccent,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Google Drive / Manga Reader',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _mutedText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ReaderPage extends StatefulWidget {
  final String link;
  final List<DriveImage> images;
  final int initialIndex;

  const ReaderPage({
    super.key,
    required this.link,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late final PageController pageController;
  late int currentPageIndex;
  bool showControls = true;
  int _hideControlsToken = 0;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleControlsHide();
    });
  }

  @override
  void dispose() {
    _hideControlsToken++;
    pageController.dispose();
    super.dispose();
  }

  List<DriveImage> _resolveReaderImages(bool isFolder, String? singleImageUrl) {
    if (isFolder || widget.images.isNotEmpty) {
      return widget.images;
    }

    if (singleImageUrl == null) {
      return const <DriveImage>[];
    }

    return [DriveImage(thumbnailUrl: singleImageUrl, fullUrl: singleImageUrl)];
  }

  void _scheduleControlsHide() {
    final token = ++_hideControlsToken;

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || token != _hideControlsToken || !showControls) {
        return;
      }

      setState(() {
        showControls = false;
      });
    });
  }

  void _showControlsTemporarily() {
    if (!showControls) {
      setState(() {
        showControls = true;
      });
    }

    _scheduleControlsHide();
  }

  void _toggleReaderControls() {
    if (showControls) {
      _hideControlsToken++;
      setState(() {
        showControls = false;
      });
      return;
    }

    _showControlsTemporarily();
  }

  void _goToPreviousPage() {
    if (currentPageIndex <= 0) {
      return;
    }

    _showControlsTemporarily();
    pageController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _goToNextPage(int pageCount) {
    if (currentPageIndex >= pageCount - 1) {
      return;
    }

    _showControlsTemporarily();
    pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFolder = isDriveFolderLink(widget.link);
    final singleImageUrl = convertDriveLinkToImageUrl(widget.link);
    final folderImages = widget.images;
    final readerImages = _resolveReaderImages(isFolder, singleImageUrl);
    final pageCount = readerImages.length;
    final progress = pageCount == 0 ? 0.0 : (currentPageIndex + 1) / pageCount;

    void preloadImage(String url) {
      precacheImage(NetworkImage(url), context);
    }

    void preloadAround(int index) {
      if (index > 0) {
        preloadImage(readerImages[index - 1].fullUrl);
      }

      if (index < readerImages.length - 1) {
        preloadImage(readerImages[index + 1].fullUrl);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: isFolder
                ? _GalleryGrid(folderImages: folderImages)
                : readerImages.isEmpty
                ? const _ReaderMessageState(
                    icon: Icons.broken_image_rounded,
                    title: 'This page could not be opened.',
                    message: 'Check the link or try again.',
                  )
                : PageView.builder(
                    controller: pageController,
                    onPageChanged: (pageIndex) {
                      setState(() {
                        currentPageIndex = pageIndex;
                      });

                      if (showControls) {
                        _scheduleControlsHide();
                      }
                    },
                    itemCount: readerImages.length,
                    itemBuilder: (context, pageIndex) {
                      preloadAround(pageIndex);

                      final currentImage = readerImages[pageIndex];
                      return GestureDetector(
                        onTap: _toggleReaderControls,
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 5,
                          child: CachedNetworkImage(
                            imageUrl: currentImage.fullUrl,
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) =>
                                const _MangaLoadingState(),
                            errorWidget: (context, url, error) {
                              return const _ReaderMessageState(
                                icon: Icons.broken_image_rounded,
                                title: 'This page could not be opened.',
                                message: 'Check the link or try again.',
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (!isFolder && showControls && readerImages.length > 1)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white70,
                      size: 42,
                    ),
                    onPressed: currentPageIndex > 0 ? _goToPreviousPage : null,
                  ),
                ),
              ),
            ),
          if (!isFolder && showControls && readerImages.length > 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                      size: 42,
                    ),
                    onPressed: currentPageIndex < pageCount - 1
                        ? () => _goToNextPage(pageCount)
                        : null,
                  ),
                ),
              ),
            ),
          if (!isFolder && showControls && readerImages.isNotEmpty)
            Positioned(
              top: 40,
              left: 12,
              right: 12,
              child: _ReaderProgressHud(
                currentPage: currentPageIndex + 1,
                totalPages: pageCount,
                progress: progress,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
          if (isFolder || readerImages.isEmpty)
            Positioned(
              top: 40,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReaderProgressHud extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double progress;
  final VoidCallback onBack;

  const _ReaderProgressHud({
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xDD101016),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2F2D39)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Page $currentPage / $totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: progress.clamp(0.0, 1.0).toDouble(),
                    backgroundColor: const Color(0xFF2C2A35),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final List<DriveImage> folderImages;

  const _GalleryGrid({required this.folderImages});

  @override
  Widget build(BuildContext context) {
    if (folderImages.isEmpty) {
      return const _ReaderMessageState(
        icon: Icons.auto_stories_rounded,
        title: 'No pages found in this folder.',
        message: 'Try another Google Drive folder.',
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(16),
      children: List.generate(folderImages.length, (index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReaderPage(
                  link: folderImages[index].fullUrl,
                  images: folderImages,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.grey[900],
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    folderImages[index].thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Page ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MangaLoadingState extends StatelessWidget {
  const _MangaLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded, color: _primaryAccent, size: 42),
          SizedBox(height: 14),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: _primaryAccent,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Loading page...',
            style: TextStyle(
              color: _mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ReaderMessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 58),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedText, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

bool isDriveFolderLink(String link) {
  return link.contains('/drive/folders/');
}

String? extractDriveFolderId(String link) {
  final regExp = RegExp(r'/folders/([^/?]+)');
  final match = regExp.firstMatch(link);

  if (match == null) {
    return null;
  }

  return match.group(1);
}

Future<List<DriveImage>> fetchDriveFolderImages(String folderId) async {
  final response = await http.get(
    Uri.parse(
      'https://www.googleapis.com/drive/v3/files?q=%27$folderId%27+in+parents&fields=files(id,name,mimeType,thumbnailLink)&orderBy=name&key=AIzaSyAHIpqx856jNpz9nrD7BBwakLkTY89cHnc',
    ),
  );

  if (response.statusCode != 200) {
    return [];
  }

  final data = jsonDecode(response.body);
  final files = data['files'] as List;

  return files
      .where((file) => file['mimeType'].toString().startsWith('image/'))
      .map<DriveImage>((file) {
        final thumbnail = file['thumbnailLink'] as String?;
        final id = file['id'];

        final fullUrl = 'https://drive.google.com/uc?export=view&id=$id';

        final thumbnailUrl = thumbnail != null && thumbnail.isNotEmpty
            ? thumbnail.replaceAll(RegExp(r'=s\d+'), '=s400')
            : fullUrl;

        return DriveImage(thumbnailUrl: thumbnailUrl, fullUrl: fullUrl);
      })
      .toList();
}

String? convertDriveLinkToImageUrl(String link) {
  if (link.startsWith('http') && link.contains('uc?export=view&id=')) {
    return link;
  }

  if (link.startsWith('http') && !link.contains('drive.google.com')) {
    return link;
  }

  final regExp = RegExp(r'/d/([^/]+)');
  final match = regExp.firstMatch(link);

  if (match == null) {
    return null;
  }

  final fileId = match.group(1);

  if (fileId == null || fileId.isEmpty) {
    return null;
  }

  return 'https://drive.google.com/uc?export=view&id=$fileId';
}
