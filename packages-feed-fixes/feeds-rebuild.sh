#!/bin/sh
# ============================================================
# 安全更新 feeds,并自动把本地改动(golang/rust 等)打回 packages feed
# 替代手动的 ./scripts/feeds update -a && ./scripts/feeds install -a
# 用法: cd /home/kali/openwrt && sh feeds-rebuild.sh
# ============================================================
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
PATCH="$ROOT/my-packages-fixes.patch"
cd "$ROOT"

echo "==> [1/3] 更新所有 feeds (会冲掉 packages feed 的本地改动)..."
./scripts/feeds update -a

if [ -f "$PATCH" ] && [ -s "$PATCH" ]; then
  echo "==> [2/3] 把本地改动打回 packages feed..."
  cd "$ROOT/feeds/packages"
  if git apply --check "$PATCH" 2>/dev/null; then
    git apply "$PATCH"
    echo "    补丁干净应用成功 ✔"
  else
    echo "    !! 无法干净应用(官方 feed 可能已变动),尝试三方合并..."
    if git apply --3way "$PATCH"; then
      echo "    三方合并成功,但请检查是否有冲突标记 <<<<<<<"
    else
      echo "    !! 补丁冲突,需手动处理。补丁文件: $PATCH"
      echo "    处理完后可继续手动执行: ./scripts/feeds install -a"
      exit 1
    fi
  fi
  cd "$ROOT"
else
  echo "==> [2/3] 未找到补丁 $PATCH,跳过(可先运行 sh save-fixes.sh 生成)"
fi

echo "==> [3/3] 重新安装 feeds..."
./scripts/feeds install -a

echo "==> 完成。现在可以 make -j\$(nproc) 编译了。"
