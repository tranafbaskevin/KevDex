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

## Snapshot After v2.6.8

Current local/GitHub baseline:

- Latest synced commit: `v2.6.8 refactor remaining small widgets`.
- `lib/main.dart`: about 6082 physical lines locally.
- `devtools_options.yaml`: local untracked IDE file. Do not commit it.

This snapshot closes the small-widget cleanup pass and prepares KevDex for v2.7.0 stability testing.

---

## Current Refactor Status

### v2.5.2 - Branding and Version Cleanup

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

### v2.6.3 - Refactor Reader Gallery Widgets

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

### v2.6.4 - Refactor Source Hub Widgets

Created:

```txt
lib/widgets/source_hub_widgets.dart
```

Extracted:

- Source Hub display widgets.
- Source selection chips/buttons.
- Source input/action panels.
- Small source status/message UI pieces.

Notes:

- No UI design changes.
- No logic changes.
- Source switching behavior stayed in the same flow.

---

### v2.6.5 - Refactor Manga Detail Widgets

Created:

```txt
lib/widgets/manga_detail_widgets.dart
```

Extracted:

- Manga/story header display widgets.
- Cover/title/source display pieces.
- Description display widgets.
- Chapter list display items.
- Small external link/detail rows.

Notes:

- Did not split the full Manga Details screen.
- Did not move API or chapter-fetch logic.
- No UI or logic changes.

---

### v2.6.6 - Refactor Reader Controls

Created:

```txt
lib/widgets/reader_controls.dart
```

Extracted:

- Reader top/control display pieces.
- Page counter display widgets.
- Reader overlay arrow buttons.
- Reader loading/error display widgets where safe.

Notes:

- Did not split the full ReaderPage.
- Did not touch PageController logic.
- Did not change image loading, cache, preload, or swipe behavior.

---

### v2.6.7 - Refactor Common UI / Empty and Error States

Created:

```txt
lib/widgets/common_widgets.dart
```

Extracted:

- Shared loading indicators.
- Empty state widgets.
- Error/message widgets.
- Small section/header/panel helpers.
- Reusable simple UI rows where safe.

Notes:

- No UI design changes.
- No app logic changes.
- No source changes.

---

### v2.6.8 - Refactor Remaining Small Widgets / Cleanup Leftovers

Created:

```txt
lib/widgets/background_picker_widgets.dart
```

Extracted:

- Background picker display widgets.
- Small remaining safe UI pieces.
- Minor widget leftovers that did not require moving screen state.

Notes:

- Did not split HomePage, ReaderPage, MangaDex Home, or Manga Details.
- Did not move API/fetch/cache/preload logic.
- No UI or logic changes.

---

### v2.6.9 - Cleanup Docs / Imports / Refactor Map Update

Current goal:

- Update this refactor map to match the real v2.6.8 structure.
- Record the current local `main.dart` size.
- Keep known deferred issues documented.
- Keep `part` declarations in `main.dart` grouped clearly.

Notes:

- No feature changes.
- No UI changes.
- No logic changes.

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
    background_picker_widgets.dart
    common_widgets.dart
    manga_detail_widgets.dart
    reader_controls.dart
    reader_gallery_widgets.dart
    source_hub_widgets.dart

docs/
  refactor/
    main-dart-map.md
```

This is the current safe foundation for future refactoring.

---

## Current `main.dart` Part Order

The `part` declarations are grouped by responsibility:

```txt
models
services
utils
widgets
```

This keeps the top of `main.dart` easier to scan without changing runtime behavior.

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

### Home / Source Hub State

Likely still inside:

- Main home screen.
- Source switching state.
- Google Drive input state.
- MangaDex input state.
- Hentai2Read input state.
- Background picker entry points.
- Library/continue-reading orchestration.

Recommended action:

- Do not extract the full Home screen yet.
- Source Hub display widgets are already partly extracted.
- Future extraction should be screen-level only after a stability checkpoint.

---

### MangaDex Home / Search UI and State

Likely still inside:

- MangaDex Home screen.
- MangaDex search state.
- Manga list/grid state.
- Load-more/infinite scroll state.
- Manga details navigation.
- MangaDex API calls and parsing.

Recommended action:

- Do not extract the full MangaDex Home logic yet.
- Do not move API calls until services are mapped separately.

---

### Manga Details Screen State

Likely still inside:

- Manga detail screen state.
- Description expansion state.
- Chapter list orchestration.
- Chapter open/navigation behavior.

Recommended action:

- Display widgets are partly extracted.
- Keep data/state/navigation in `main.dart` until the service boundary is clearer.

---

### Reader Screen State

Likely still inside:

- Reader page state.
- Page controller.
- Swipe/arrow navigation callbacks.
- Page index updates.
- Cache interaction.
- Preload logic.
- Image loading behavior.
- Reader settings state.

Recommended action:

- Do not extract the full ReaderPage yet.
- Reader is high-risk because it touches page state, cache, image loading, and navigation.
- Reader controls/display widgets are already partly extracted.

---

### Google Drive Flow

Likely still inside:

- Google Drive link input usage.
- Folder ID extraction usage.
- Drive image fetching flow.
- Drive folder/gallery display flow.
- Drive image URL conversion.

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

- Do not move this until after UI widgets and service boundaries are mapped.
- Later, move into:

```txt
lib/services/mangadex_service.dart
```

---

### Hentai2Read Flow

Likely still inside:

- Hentai2Read Home fetch/search flow.
- Hentai2Read detail parsing.
- Hentai2Read chapter/page parsing.

Recommended action:

- Do not move this during v2.6.x cleanup unless a specific adapter refactor is planned.
- Keep source behavior unchanged during cleanup.

---

### Legacy / Private Source Flow

Likely still inside:

- Hitomi/NHentai legacy adapter code.
- Private source toggles and fallback behavior.

Recommended action:

- Treat as deferred/legacy code.
- Do not optimize during v2.6.x cleanup.
- Do not add new private source behavior during cleanup.

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

## Known Deferred Issues

### MangaDex External / MangaPlus Chapters

Current behavior:

- Some MangaDex entries, such as Naruto or other official publisher chapters, may not return readable pages inside KevDex.
- On the MangaDex website, these chapters may redirect to MangaPlus or another official external site.
- KevDex currently reads chapters hosted directly on MangaDex, not external official viewers.

Current decision:

- Do not fix this during refactor cleanup.
- Do not scrape/bypass external official readers.
- Later, add a clearer message and optional "Open in browser" action.

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

### Private Source Thumbnail Issue

Observed:

- One private/adult source may not show thumbnails in Home/list cards.
- The same item can still show images after opening detail/chapter.

Current decision:

- Track as a technical note.
- Do not prioritize during cleanup.
- Do not fix in v2.6.9.

---

## High-Risk Areas

Do not touch these until the project is cleaner and a specific version is planned.

```txt
ReaderPage full extraction
HomePage full extraction
MangaDex Home full extraction
Manga Details full extraction
Google Drive fetch logic
MangaDex API service extraction
Hentai2Read API/parser extraction
Cache/preload logic
Navigation/routing rewrite
iOS/TestFlight setup
Vietnamese source integration
External MangaPlus handling
Android 7 compatibility patch
Private source thumbnail patch
```

These areas can be refactored later, but only after smaller widgets and services are mapped.

---

## Roadmap

### Done

```txt
v2.5.2 - Branding and Version Cleanup
v2.6.0 - Refactor Story Models
v2.6.1 - Refactor Constants and Link Helpers
v2.6.2 - Refactor Storage and Reader Settings
v2.6.3 - Refactor Reader Gallery Widgets
v2.6.4 - Refactor Source Hub Widgets
v2.6.5 - Refactor Manga Detail Widgets
v2.6.6 - Refactor Reader Controls
v2.6.7 - Refactor Common UI / Empty and Error States
v2.6.8 - Refactor Remaining Small Widgets / Cleanup Leftovers
```

### Current

```txt
v2.6.9 - Cleanup Docs / Imports / Refactor Map Update
```

### Next

```txt
v2.7.0 - Stability Checkpoint
```

Suggested v2.7.0 test scope:

- Open app.
- Google Drive source.
- MangaDex paste link.
- MangaDex Home search.
- Manga detail and chapter list.
- Reader page.
- Page counter.
- Cache / clear cache.
- Library / continue reading.
- Background picker.
- Hentai2Read Home/detail/chapter.
- Known limitation messaging.

### Later

```txt
v2.7.x - Reading history, favorites, cache polish
v2.8.x - Vietnamese source research / experiment
v3.0 - Cross-platform preparation and iOS/TestFlight planning
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

Current recommended commit:

```txt
v2.6.9 cleanup refactor docs and imports
```

---

## Kevin + Dora + Remi Workflow

```txt
Kevin / Nobita
-> Decides direction, tests APK, commits, releases.

Dora-chan
-> Roadmap, review, QA checklist, risk analysis, prompts for Remi.

Remi-chan
-> Code/refactor implementation.
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