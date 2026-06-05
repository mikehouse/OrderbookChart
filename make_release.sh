#!/bin/sh -e

xcodebuild -version

PROJECT_DIR="$(pwd)"
for arch in "arm64" "x86_64"; do
    xcodebuild -scheme OrderbookChart -project OrderbookChart.xcodeproj -configuration Release -derivedDataPath ./.build -arch $arch build | (xcbeautify || xcpretty || tee)
    cd ./.build/Build/Products/Release/
    find ./OrderbookChart.app/Contents/Resources -type f -name "*.json" -delete
    zip -rq OrderbookChart.app.$arch.zip OrderbookChart.app
    cd "$PROJECT_DIR"
    mv ./.build/Build/Products/Release/OrderbookChart.app.$arch.zip ./.build/
done