#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/Users/wzqin/.npm-global/bin:$PATH"  # TODO: 根据实际情况调整路径
export NODE_TLS_REJECT_UNAUTHORIZED=0


SAVE_DIR="/Users/wzqin/Library/CloudStorage/OneDrive-个人/gemini-paper/Paper-Reading" # TODO: 根据实际情况调整路径
mkdir -p "$SAVE_DIR"

INPUTS="$1"
if [ -z "$INPUTS" ]; then
    echo "❌ 错误: 未接收到任何输入参数！"
    exit 1
fi

echo "📁 笔记将自动保存至: $SAVE_DIR"
echo "🚀 开始处理论文..."
echo "=================================================="

# ==========================================
# 解析参数并下载 PDF
# ==========================================
echo "接收到的参数: $INPUTS"

# 提取无后缀的文件名 (例如从 ActionCodec 提取出 ActionCodec)
PAPER_TITLE=$(echo "$INPUTS" | cut -d'@' -f1)
echo "PAPER_TITLE:$PAPER_TITLE"
# 提取 URL (取出 @ 之后的内容)
PAPER_URL=$(echo "$INPUTS" | cut -d'@' -f2)
echo "PAPER_URL:$PAPER_URL"

# 构造一个安全的临时 PDF 文件名 (将空格替换为下划线，去除特殊符号)
SAFE_TITLE=$(echo "$PAPER_TITLE" | tr ' ' '_' | tr -d '/')
TEMP_PDF="/$SAVE_DIR/${SAFE_TITLE}.pdf"

echo "⬇️ 正在将 PDF 下载至本地: $TEMP_PDF"
# 使用 curl 下载，-s 减少杂乱输出，-L 允许重定向
curl -sL -o "$TEMP_PDF" "$PAPER_URL"

# 检查是否下载成功（文件存在且大小不为 0）
if [ ! -f "$TEMP_PDF" ] || [ ! -s "$TEMP_PDF" ]; then
    echo "❌ 错误: PDF 下载失败或文件为空，请检查代理或链接！"
    exit 1
fi
echo "✅ 下载成功！"


SAVE_PATH="$SAVE_DIR/${PAPER_TITLE}.md"
echo "📄 正在呼叫 Gemini 处理本地 PDF: $PAPER_TITLE"
PROMPT="请使用 paper-explainer 技能，读取本地PDF文件（文件路径：$TEMP_PDF），帮我深度讲解并提取这篇论文的模型架构和实验结论。"
/opt/homebrew/bin/gemini --yolo "$PROMPT" < /dev/null > "$SAVE_PATH"

if [ -s "$SAVE_PATH" ]; then
    echo "✅ 保存成功 -> $SAVE_PATH"
else
    echo "⚠️ 处理失败或输出为空，请检查文件权限或代理状态。"
fi

SLEEP_TIME=$((RANDOM % 21 + 20))
echo "💤 休眠 $SLEEP_TIME 秒..."
sleep $SLEEP_TIME
echo "--------------------------------------------------"