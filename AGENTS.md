
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

## Agent ruleset

1. **DO NOT COMPILE CODE YOURSELF** as it spends a lot of tokens. A human operator will use Xcode to compile new generated code. Just say that the code is ready to be built.
2. **DO NOT SCAN** directories if not asked:

- ./.idea
- ./.git
