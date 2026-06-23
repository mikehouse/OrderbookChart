
## App tech stack

- macOS platform
- Swift 5+ as the main language
- SwiftUI as a UI framework

## App architecture

1. The main app UI is NavigationSplitView, where

- The left side (sidebar) is a list of CEX
- The center (content) is a list of tickers from the selected CEX
- The right side (details) is a candlestick chart for the selected ticker

2. API

/Cex/ directory contains API classes for CEX

## What is the app about from the user's perspective

- The app shows a list of tickers from CEX (supports Binance and Bybit)
- For the selected ticker the app shows a candlestick chart for the latest 100–500 candles
- To that candlestick chart, the app also shows realtime order book data from the exchange
- Several timeframes are available for the candlestick chart
- Create a list of favorite symbols

## Agent ruleset

1. If you want to compile the project to verify that code is correct, use a target platform  as `macOS` and must pipe output through `xcbeautify`.

Example:
```
xcodebuild -scheme OrderbookChart -destination 'platform=macOS' build | xcbeautify
```

2. Always use an Xcode system DerivedData path for building the project to reuse already built cache, do not override it.
