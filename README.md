# Reading Book App

A Flutter demo app for reading books with chapter unlocking system using coins.

## Features

- **Book Display**: Shows a book with multiple chapters loaded from JSON
- **Chapter Unlocking**: First chapter is free, others require coins to unlock
- **Coin System**: Start with 50 coins, spend coins to unlock chapters
- **Reading Modes**: 
  - Sliding Mode: Paginated reading with swipe gestures
  - Scrolling Mode: Continuous scrolling reading
- **Local Storage**: Coin balance and unlock status persist using SharedPreferences

## How to Use

1. **Main Screen**: View book info, tags, and chapter list
2. **Coin Balance**: Displayed in the top-right corner
3. **Chapter Access**: 
   - Green lock icon = Unlocked (tap to read)
   - Grey lock icon = Locked (tap to unlock with coins)
4. **Reading**: 
   - Switch between sliding and scrolling modes using the toggle button
   - In sliding mode: tap left/right sides to navigate pages
   - Use navigation buttons at the bottom for page control

## Chapter Pricing

- Chapter 1: Free (always unlocked)
- Chapter 2: 20 coins
- Chapter 3: 30 coins
- Chapter 4: 40 coins
- Chapter 5: 50 coins

## Technical Details

- **Data Source**: `assets/book.json` contains book and chapter data
- **Storage**: SharedPreferences for coin balance and unlock status
- **Pagination**: Text split into ~900 character chunks for sliding mode
- **UI**: Material Design with deep purple theme

## Getting Started

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. The app will load the sample book "My Billionaire Roommates" with 5 chapters

## File Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── book.dart            # Book and Chapter data models
├── services/
│   └── storage_service.dart # SharedPreferences wrapper
└── screens/
    ├── book_screen.dart     # Main book/chapter list screen
    └── reader_screen.dart   # Reading interface with both modes
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
