
Must read first ../AGENTS.md

# Ticker list Export feature

## About

For selected CEX we want to export the ticker list to a file.

## How to do it

1. On the split view content view add a button with the text "Export" above the list of tickers that ask a user to select a directory where to save the file.
2. Add there a list (dropdown without title) of formats to choose from to save a file. For now, we only support TradingView's import format (call it as 'TradingView').
3. Add there a 'split count' dropdown menu without a title. The default value should be 100. Values available are 100, 150, 200, 250. This menu is available when the TradingView format is selected only. With this 'count' value, we will split the list of tickers into chunks and export each chunk separately.
4. When a user clicks on the "Export" button for TradingView format and selected directory, split tickers for selected CEX into chunks and save every chunk in a separate file. The file name should be like "${CEX_NAME}-${COUNT}-${yyyy-mm-dd-hh-mm}-${CHUNK_NUM}.txt". File format for trading view is:

```txt
${CEX_NAME_UPPERCASED}:${TICKER_1}.P,${CEX_NAME_UPPERCASED}::${TICKER_2}.P
```