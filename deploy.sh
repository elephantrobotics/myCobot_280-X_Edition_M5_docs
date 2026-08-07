#!/bin/bash
# 构建并部署 GitBook 到 GitHub Pages
# 用法: bash deploy.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BRANCH="gh-pages"

echo "=== 安装插件 ==="
for book in mycobot_280_M5_10th_cn mycobot_280_M5_10th_en mycobot_280_PI_10th_cn mycobot_280_PI_10th_en; do
  gitbook install "$REPO_DIR/$book" 2>/dev/null
done

# 清理旧构建
rm -rf "$REPO_DIR/docs"
mkdir -p "$REPO_DIR/docs"

# 复制首页
cp "$REPO_DIR/index.html" "$REPO_DIR/docs/index.html"

echo ""
echo "=== 构建 GitBook ==="
for book in mycobot_280_M5_10th_cn mycobot_280_M5_10th_en mycobot_280_PI_10th_cn mycobot_280_PI_10th_en; do
  echo "--- 构建 $book ---"
  gitbook build "$REPO_DIR/$book" "$REPO_DIR/docs/$book"
  echo "完成: $book"
done

echo ""
echo "=== 部署到 $BRANCH 分支 ==="
cd "$REPO_DIR"
cp -r docs /tmp/gitbook-deploy-temp
git checkout "$BRANCH" 2>/dev/null || git checkout --orphan "$BRANCH"
rm -rf ./*
cp -r /tmp/gitbook-deploy-temp/* .
rm -rf /tmp/gitbook-deploy-temp
git add -A
git commit -m "Deploy GitBook $(date '+%Y-%m-%d %H:%M')" || echo "No changes to deploy"
git push origin "$BRANCH" -f
git checkout main

echo ""
echo "=== 部署完成 ==="
echo "GitHub Pages 地址: https://elephantrobotics.github.io/mycobot_280-X_Edition_M5_docs"
