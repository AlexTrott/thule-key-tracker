# Build Order

Execute the slash commands in this order for a clean build-up of the app.

## Phase 1: Foundation
```
/scaffold
```
Creates all files, models, enums, formatters, and stub views. After this you should have a compilable project structure (once wrapped in an Xcode project).

**Manual step:** Create the Xcode project in Xcode, add all source files, set the deployment target to iOS 17, and confirm it builds.

## Phase 2: Core Screens
```
/build-list
```
Builds the full product list with search, grouping, swipe actions, and context menus. This is the main screen of the app.

```
/build-form
```
Builds the add/edit form with live key code formatting and validation. After this, the app is functionally complete for the core loop: add → view → search → edit → delete.

## Phase 3: Settings & Data
```
/build-settings
```
Builds settings, JSON export/import, and the data reset flow. After this, the app is feature-complete for v1.

## Phase 4: Tests
```
/write-tests
```
Writes unit tests for the formatter, view models, and export/import. Run them and fix any failures.

## Phase 5: Polish
```
/polish
```
Final review pass for code quality, accessibility, dark mode, edge cases, and localisation readiness.

## Phase 6: Ship
Manual steps:
1. Add App Icon (consider a key + lock SF Symbol rendered as an icon, or a simple branded icon in Thule blue)
2. Write App Store metadata (description, keywords, screenshots)
3. Create a `Fastfile` if you want automated screenshots/submission
4. Archive and submit via Xcode or Fastlane
