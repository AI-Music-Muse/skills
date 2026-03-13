#!/usr/bin/env bash
# Muse Skill 一键部署
# 适用于所有支持 skills 的 AI CLI（Claude Code / OpenClaw / Kimi / 千问 / 智谱等）
# 用法: bash install.sh          # 安装
#       bash install.sh --uninstall  # 卸载

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/muse"
DATA_DIR="$HOME/.claude/.muse"

# ── 卸载模式 ──
if [ "$1" = "--uninstall" ]; then
  echo "🗑  正在卸载 Muse Skill..."
  rm -rf "$SKILL_DIR"
  echo "✅ Muse Skill 已卸载（Token 数据保留在 $DATA_DIR）"
  echo "   如需彻底清除: rm -rf $DATA_DIR"
  exit 0
fi

# ── Python 检查 ──
# 优先 python3，兼容部分系统只有 python 的情况
PYTHON=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON="python"
fi

if [ -z "$PYTHON" ]; then
  echo "❌ 未检测到 Python，请先安装 Python 3.6+"
  echo "   Ubuntu/Debian: sudo apt install python3"
  echo "   macOS: brew install python3"
  exit 1
fi

PY_VER=$($PYTHON -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PY_MAJOR=$(echo "$PY_VER" | cut -d. -f1)
PY_MINOR=$(echo "$PY_VER" | cut -d. -f2)
if [ "$PY_MAJOR" -lt 3 ] || ([ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 6 ]); then
  echo "❌ Python $PY_VER 版本过低，需要 3.6+"
  echo "   Ubuntu/Debian: sudo apt install python3"
  echo "   macOS: brew install python3"
  exit 1
fi

# ── 部署 ──
echo "🎵 Muse Skill v$VERSION 安装中..."

mkdir -p "$DATA_DIR"

# 升级安装：清理旧版本目录，确保无残留文件
if [ -d "$SKILL_DIR" ]; then
  echo "   检测到旧版本，正在升级..."
  rm -rf "$SKILL_DIR"
fi
mkdir -p "$SKILL_DIR"

# 排除非运行时文件
EXCLUDE_FILES="README.md LICENSE CHANGELOG.md package.json install.sh .gitignore .git"

for item in "$SCRIPT_DIR"/*; do
  name=$(basename "$item")
  skip=false
  for ex in $EXCLUDE_FILES; do
    [ "$name" = "$ex" ] && skip=true && break
  done
  [ "$skip" = true ] && continue
  cp -r "$item" "$SKILL_DIR/"
done

# ── 安装验证 ──
VERIFY_OK=true

if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  echo "❌ 安装异常：SKILL.md 缺失"
  VERIFY_OK=false
fi

if ! $PYTHON "$SKILL_DIR/scripts/muse_api.py" device-id >/dev/null 2>&1; then
  echo "❌ 安装异常：Python 脚本无法正常运行"
  VERIFY_OK=false
fi

if [ "$VERIFY_OK" = false ]; then
  echo "⚠️  安装可能不完整，请检查上述错误后重试"
  exit 1
fi

echo ""
echo "✅ Muse Skill v$VERSION 安装成功"
echo "   技能目录: $SKILL_DIR"
echo "   数据目录: $DATA_DIR"
echo "   Python:   $PY_VER ($PYTHON)"
echo ""
echo "在对话中发送「做首歌」即可开始创作 🎶"
