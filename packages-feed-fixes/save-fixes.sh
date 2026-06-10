#!/bin/sh
# ============================================================
# 保存 packages feed 的本地改动(golang / rust 等)为补丁
# 适用场景:你改完 go 版本、rust 版本、或修了编译问题之后,
#          跑一下本脚本,把改动刷新进补丁文件。
# 用法: cd /home/kali/openwrt && sh save-fixes.sh
# ============================================================
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
PATCH="$ROOT/my-packages-fixes.patch"
FEED="$ROOT/feeds/packages"

[ -d "$FEED/.git" ] || { echo "找不到 $FEED ,先跑 feeds update/install"; exit 1; }

cd "$FEED"
# 清掉临时备份,避免污染补丁
rm -f lang/rust/Makefile.bak
# 把所有改动(含新增文件)纳入索引,再整体导出
git add -A
git diff HEAD > "$PATCH"

echo "已保存补丁: $PATCH"
git diff HEAD --stat | tail -3
echo "补丁行数: $(wc -l < "$PATCH")"
