#!/bin/bash

set -xe

FILE=translationCore-macos-x64-$VERSION-$HASH.dmg

./node_modules/.bin/gulp build --osx || exit 1;
./node_modules/.bin/gulp release-macos --out=../build/$SAFE_BRANCH/$FILE || exit 1;

echo "[macOS build $VERSION ($HASH)]($BUILD_CDN/build/$SAFE_BRANCH/$FILE) is ready for download." >> ../build_meta/comment.md
echo "<$BUILD_CDN/build/$SAFE_BRANCH/$FILE|macOS build $HASH (v$VERSION)> is ready for download." >> ../build_meta/notification.txt
