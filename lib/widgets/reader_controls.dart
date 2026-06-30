part of 'package:kevdex/main.dart';

class _ReaderProgressHud extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double progress;
  final VoidCallback onBack;
  final VoidCallback onComfort;
  final VoidCallback? onGallery;

  const _ReaderProgressHud({
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.onBack,
    required this.onComfort,
    this.onGallery,
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
          if (onGallery != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton(
                tooltip: 'Gallery',
                icon: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onGallery,
              ),
            ),
          ],
          const SizedBox(width: 4),
          SizedBox(
            width: 42,
            height: 42,
            child: IconButton(
              tooltip: 'Reader comfort',
              icon: const Icon(
                Icons.tune_rounded,
                color: _primaryAccent,
                size: 21,
              ),
              onPressed: onComfort,
            ),
          ),
        ],
      ),
    );
  }
}
