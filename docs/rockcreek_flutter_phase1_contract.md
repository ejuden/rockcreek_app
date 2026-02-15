# Rock Creek Church App -- Phase 1 Contract

Date: 2026-02-15

## Objective

Create a Flutter-based starter mobile application for Rock Creek Church
that:

-   Runs on both iOS and Android
-   Uses a single Flutter codebase
-   Dynamically pulls sermon data from the church website
-   Requires no API keys
-   Requires no backend
-   Requires no Firebase
-   Contains no secrets or credentials
-   Can be handed off via GitHub for the church to extend independently

------------------------------------------------------------------------

## Scope -- Phase 1 (MVP)

### Included

1.  Flutter project scaffold
2.  Tab-based navigation
3.  Sermons screen:
    -   Fetch HTML from https://www.rockcreektx.church/sermons/
    -   Parse sermon list from HTML
    -   Extract title and detail URL
    -   Fetch detail page on tap
    -   Extract embedded YouTube iframe URL
    -   Display video in WebView
4.  Events screen:
    -   WebView pointing to church events page (or fallback page)
5.  Connect screen:
    -   Static contact info
    -   External map link
6.  AppConfig.dart for centralized URLs
7.  Clean folder structure
8.  README explaining:
    -   How to update URLs
    -   How to change app name
    -   How to update colors
    -   How to update HTML selectors if website changes

------------------------------------------------------------------------

## Explicitly Excluded

-   Push notifications
-   Firebase
-   YouTube API usage
-   Payment/giving integration
-   Authentication
-   Offline caching
-   Admin backend
-   Analytics
-   App Store publishing

------------------------------------------------------------------------

## Architecture Requirements

-   Flutter (stable channel)
-   Dart null-safety enabled
-   Clean folder separation:
    -   models/
    -   services/
    -   screens/
    -   widgets/
    -   config/
-   Use http package for networking
-   Use html parser package for scraping
-   Use webview_flutter only where necessary
-   No hardcoded secrets
-   No API keys
-   Keep dependencies minimal

------------------------------------------------------------------------

## Maintainability Requirements

-   All URLs centralized in AppConfig.dart
-   All HTML selectors centralized in ApiService.dart
-   Clear comments explaining selector logic
-   Graceful error handling if parsing fails
-   Loading indicators for network calls

------------------------------------------------------------------------

## Deliverable

A clean, buildable Flutter project that:

-   Runs on iOS simulator
-   Runs on Android emulator
-   Displays live sermon data from website
-   Can be committed to GitHub and handed off

------------------------------------------------------------------------

## Definition of Done

-   `flutter run` succeeds on both platforms
-   Sermon list loads dynamically
-   Tapping a sermon loads embedded video
-   No runtime crashes
-   Clean, readable, documented code

------------------------------------------------------------------------

End of Phase 1 Contract
