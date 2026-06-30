# KevDex main.dart Refactor Map

## Purpose

This document tracks the cleanup/refactor progress of `lib/main.dart`.

The goal is to keep KevDex stable while slowly moving code out of the large `main.dart` file into smaller, easier-to-maintain files.

Rules for this refactor phase:

- Do not change UI unless the task specifically requires it.
- Do not change app logic unless the task specifically requires it.
- Do not add new manga sources during cleanup.
- Do not touch iOS/TestFlight work during this phase.
- Keep each refactor small and test after every step.
- Run `flutter analyze lib test`, `flutter test`, and `flutter build apk --release` after every refactor step.

---

## Current Refactor Status

### v2.5.2 - Branding & Version Cleanup

Completed:

- Cleaned KevDex branding.
- Updated `pubspec.yaml`.
- Updated README repository links.
- Updated iOS display name.
- Updated test imports after package rename.
- Kept Android `applicationId` unchanged so APK updates still work normally.

Result:

- App metadata is cleaner.
- Project branding is more consistent.
- Prepared the project for long-term cleanup and future iOS/TestFlight work.

---

### v2.6.0 - Refactor Story Models

Created:

```txt
lib/models/story_models.dart
```

Extracted:

- Source definitions.
- Manga/story metadata models.
- Preview models.
- `DriveImage`.
- Fetch result models.

Notes:

- Used `part of 'package:kevdex/main.dart';` for safer first-step extraction.
- No UI changes.
- No logic changes.
- No source changes.

---

### v2.6.1 - Refactor Constants and Link Helpers

Created:

```txt
lib/utils/app_constants.dart
lib/utils/link_helpers.dart
```

Extracted into `app_constants.dart`:

- App colors.
- Background asset paths.
- Default reader settings.

Extracted into `link_helpers.dart`:

- Google Drive link detection.
- MangaDex link detection.
- Hentai2Read link detection.
- Link ID extraction helpers.

Notes:

- No UI changes.
- No logic changes.
- No source changes.
- MangaPlus/external chapter handling was not changed.

---

### v2.6.2 - Refactor Storage and Reader Settings

Created:

```txt
lib/services/kevdex_memory.dart
```

Extracted:

- Reader progress storage.
- Library storage.
- UI background storage.
- Reader comfort settings.
- Private source settings.
- `SharedPreferences` keys.
- `KevDexMemory`.

Notes:

- No UI changes.
- No logic changes.
- No source changes.
- iOS/TestFlight was not touched.

---

### v2.6.3 - Refactor Small UI Widgets

Created:

```txt
lib/widgets/reader_gallery_widgets.dart
```

Extracted:

- Gallery/reader-related small widgets.
- `_GalleryGrid`.
- `_GalleryPageCard`.
- Other small gallery UI pieces.

Notes:

- Used `part of 'package:kevdex/main.dart';` to reduce risk.
- Did not split large screens yet.
- No feature changes.

---

## Current Project Structure

```txt
lib/
  main.dart

  models/
    story_models.dart

  services/
    kevdex_memory.dart

  utils/
    app_constants.dart
    link_helpers.dart

  widgets/
    reader_gallery_widgets.dart
```

This is the current safe foundation for future refactoring.

---

## Still Inside main.dart

The following areas may still be inside `main.dart` and should be mapped carefully before extraction.

### App Core

Likely still inside:

- `main()`
- `runApp()`
- Root app widget
- Theme setup
- Main route/navigation setup

Recommended action:

- Keep this inside `main.dart` for now.
- Later, move root app structure into something like `lib/app/kevdex_app.dart`.

---

### Home / Source Hub UI

Likely still inside:

- Main home screen.
- Source selector UI.
- Google Drive input panel.
- MangaDex input panel.
- Source switching logic.
- Background picker / UI customization entry points.

Recommended action:

- Do not extract the full Home screen yet.
- First extract small widgets only:
  - source buttons
  - source header
  - input card
  - background action button
  - small reusable panels

Possible future file:

```txt
lib/widgets/source_hub_widgets.dart
```

---

### MangaDex Home / Search UI

Likely still inside:

- MangaDex Home screen.
- MangaDex search bar.
- Manga list/grid.
- Manga result cards.
- Load-more/infinite scroll.
- Manga details navigation.

Recommended action:

- Do not extract the full MangaDex Home logic yet.
- First extract display-only widgets:
  - manga result card
  - manga cover widget
  - manga info row
  - loading/empty/error state widgets

Possible future files:

```txt
lib/widgets/mangadex_widgets.dart
lib/screens/mangadex_home_screen.dart
```

---

### Manga Details Screen

Likely still inside:

- Manga cover display.
- Description section.
- Chapter list.
- Chapter item cards.
- Read more/description expansion.
- Open in MangaDex website link.

Recommended action:

- Extract small widgets first:
  - chapter list item
  - manga description box
  - manga header card

Possible future file:

```txt
lib/widgets/manga_detail_widgets.dart
```

---

### Reader Screen

Likely still inside:

- Reader page.
- Page controller.
- Swipe/arrow navigation.
- Page counter.
- Cache interaction.
- Preload logic.
- Reader settings overlay.

Recommended action:

- Do not extract the full ReaderPage yet.
- Reader is high-risk because it touches page state, cache, image loading, and navigation.
- Extract only small visual widgets first:
  - reader top bar
  - page counter display
  - arrow buttons
  - loading/error display

Possible future files:

```txt
lib/widgets/reader_controls.dart
lib/screens/reader_screen.dart
```

---

### Google Drive Flow

Likely still inside:

- Google Drive link input.
- Folder ID extraction usage.
- Drive image fetching flow.
- Drive folder/gallery display.
- Drive image conversion.

Recommended action:

- Do not refactor large fetch logic until services are clearly mapped.
- Later, move fetch/network logic into:

```txt
lib/services/google_drive_service.dart
```

---

### MangaDex API Flow

Likely still inside:

- MangaDex API calls.
- Chapter fetching.
- At-home server fetching.
- Cover URL handling.
- Manga search result parsing.
- Manga details parsing.

Recommended action:

- Do not move this until after UI widgets are smaller.
- Later, move into:

```txt
lib/services/mangadex_service.dart
```

---

### Cache / Image Loading

Likely still inside:

- Cached image loading.
- Preload logic.
- Clear cache action.
- Reader cache behavior.

Recommended action:

- Treat as medium/high risk.
- Do not move until reader widgets and services are better separated.

Possible future file:

```txt
lib/services/cache_service.dart
```

---

## Known Limitations

### MangaDex External / MangaPlus Chapters

Current behavior:

- Some MangaDex entries, such as Naruto or other official publisher chapters, may not return readable pages inside KevDex.
- On the MangaDex website, these chapters may redirect to MangaPlus or another official external site.
- KevDex currently reads chapters hosted directly on MangaDex, not external official viewers.

Current decision:

- Do not fix this during refactor cleanup.
- Do not scrape/bypass external official readers.
- Later, add a clearer message and optional “Open in browser” action.

Possible future improvement:

```txt
This chapter is hosted on an external official source and cannot be read inside KevDex.
```

---

### Android 7 / Samsung A5 2016 Issue

Observed:

- App launches on Samsung A5 2016 running Android 7.
- Some source flow appears to work.
- MangaDex Home opens but appears blank.

Possible causes:

- Android 7 network/TLS/certificate compatibility.
- MangaDex API request failure.
- Older Android HTTP/client behavior.
- UI silently showing empty state instead of error.

Need more testing:

- Google Drive direct link.
- MangaDex direct chapter link.
- MangaDex Home search.
- Error logs from Android Studio/logcat.
- Whether the request fails or returns empty data.

Current decision:

- Track as QA issue.
- Do not block current refactor unless it becomes a wider app issue.

---

## Safe Future Refactor Candidates

### v2.6.4 Candidate - More Small UI Widgets

Possible extraction:

```txt
lib/widgets/common_widgets.dart
lib/widgets/source_hub_widgets.dart
lib/widgets/manga_detail_widgets.dart
```

Safe targets:

- Loading indicator widgets.
- Empty state widgets.
- Error message widgets.
- Small section headers.
- Reusable glass/card panels.
- Source selector buttons.
- Manga/chapter display cards.

Rules:

- Do not move full screens yet.
- Do not change UI design.
- Do not change logic.
- Test after extraction.

---

### v2.6.5 Candidate - Manga Detail Widgets

Possible extraction:

```txt
lib/widgets/manga_detail_widgets.dart
```

Safe targets:

- Manga header card.
- Description panel.
- Chapter list item.
- External website link row.

Rules:

- Keep data fetching in `main.dart` for now.
- Only extract display widgets.

---

### v2.6.6 Candidate - Reader Controls

Possible extraction:

```txt
lib/widgets/reader_controls.dart
```

Safe targets:

- Page counter widget.
- Reader top bar.
- Left/right overlay arrows.
- Reader settings button.
- Reader loading/error states.

Rules:

- Do not move page controller logic yet.
- Do not move image loading logic yet.
- Do not change swipe behavior.

---

## High-Risk Areas

Do not touch these until the project is cleaner.

```txt
ReaderPage full extraction
MangaDex Home full extraction
Google Drive fetch logic
MangaDex API service extraction
Cache/preload logic
Navigation/routing rewrite
iOS/TestFlight setup
Vietnamese source integration
External MangaPlus handling
```

These areas can be refactored later, but only after smaller widgets and services are mapped.

---

## Suggested Roadmap

### Done

```txt
v2.5.2 - Branding and Version Cleanup
v2.6.0 - Refactor Story Models
v2.6.1 - Refactor Constants and Link Helpers
v2.6.2 - Refactor Storage and Reader Settings
v2.6.3 - Refactor Small UI Widgets
```

### Next

```txt
v2.6.4 - Refactor More Small UI Widgets
v2.6.5 - Refactor Manga Detail Widgets
v2.6.6 - Refactor Reader Controls
```

### Later

```txt
v2.7.0 - App Stability / QA / Known Limitations
v2.8.x - Vietnamese Source Research
v3.0 - Cross-platform Preparation
```

---

## Commit Rule

For each cleanup step:

```txt
1. Change a small number of files.
2. Do not mix refactor with new features.
3. Run analyze/test/build.
4. Test APK manually.
5. Commit with a clear version message.
```

Recommended commit style:

```txt
v2.6.x refactor <area name>
```

Example:

```txt
v2.6.4 refactor more small UI widgets
```

---

## Kevin + Dora + Remi Workflow

```txt
Kevin / Nobita
→ Decides direction, tests APK, commits, releases.

Dora-chan
→ Roadmap, review, QA checklist, risk analysis, prompts for Remi.

Remi-chan
→ Code/refactor implementation.
```

This workflow should continue because it keeps KevDex stable while still moving forward.

---

## Final Note

KevDex is no longer just a small Flutter experiment.

It now has:

- Public APK releases.
- Multiple sources.
- MangaDex Home/search.
- Reader and cache behavior.
- Custom UI/background.
- A growing project structure.
- A real refactor roadmap.

The goal is not to clean everything in one day.

The goal is:

```txt
Small refactor.
Test.
Commit.
Repeat.
```
