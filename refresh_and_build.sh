#!/bin/bash

# 脚本说明：
# 1. 清理 Flutter 构建缓存
# 2. 清理 pub 缓存（包括 GitHub 包）
# 3. 强制拉取所有依赖（确保 GitHub 包为最新）
# 4. 构建 debug 包

set -e

cd "$(dirname "$0")"

echo "==== 1. 清理 Flutter 构建缓存 ===="
flutter clean

echo "==== 2. 清理 pub 缓存（包括 GitHub 包）===="
flutter pub cache repair

echo "==== 3. 强制拉取所有依赖（包括最新 GitHub 包）===="
flutter pub get

echo "==== 完成！所有依赖已强制刷新 ====" 