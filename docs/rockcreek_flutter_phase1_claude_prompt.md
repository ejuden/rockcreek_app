# Claude Prompt -- Rock Creek Church App Phase 1 Scaffold

Date: 2026-02-15

You are a senior Flutter engineer.

We are building a Flutter starter app for Rock Creek Church.

Follow the Phase 1 Contract strictly.

------------------------------------------------------------------------

## Requirements

Create a Flutter project structure inside an existing empty Flutter
project with:

lib/ main.dart config/app_config.dart models/sermon.dart
services/api_service.dart screens/home_screen.dart
screens/sermons_screen.dart screens/sermon_detail_screen.dart
screens/events_screen.dart screens/connect_screen.dart
widgets/loading_indicator.dart

------------------------------------------------------------------------

## Technical Requirements

-   Use Dart null safety
-   Use http package for networking
-   Use html parser package for scraping
-   Use webview_flutter for embedded video
-   Use FutureBuilder for async UI
-   No API keys
-   No Firebase
-   No secrets

------------------------------------------------------------------------

## Functionality

1.  App has BottomNavigationBar with four tabs:
    -   Home
    -   Sermons
    -   Events
    -   Connect
2.  Sermons Screen:
    -   Fetch HTML from https://www.rockcreektx.church/sermons/
    -   Parse sermon titles and detail URLs
    -   Display as scrollable ListView
    -   On tap, navigate to SermonDetailScreen
3.  Sermon Detail Screen:
    -   Fetch detail page HTML
    -   Extract embedded iframe src
    -   Display video using WebView
    -   Display sermon title
4.  Events Screen:
    -   Display WebView pointing to church events URL (placeholder
        configurable)
5.  Connect Screen:
    -   Static contact info
    -   Button to open map link

------------------------------------------------------------------------

## Code Quality Rules

-   Keep code clean and modular
-   Add comments explaining HTML selectors
-   All URLs must come from AppConfig.dart
-   Handle network failures gracefully
-   Show loading indicator during fetch

------------------------------------------------------------------------

## Deliverable

Provide all Dart files fully written and ready to paste into the Flutter
project.

Do not include explanations. Output only the complete file contents
grouped by file name.
