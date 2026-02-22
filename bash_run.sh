#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/Users/wzqin/.npm-global/bin:$PATH" # TODO: 根据实际情况调整路径

# ==========================================
# 1. 设置网络代理 (纯 HTTP 模式，防 Node.js 崩溃)
# ==========================================
export HTTP_PROXY="http://127.0.0.1:6789"
export HTTPS_PROXY="http://127.0.0.1:6789"
export http_proxy="http://127.0.0.1:6789"
export https_proxy="http://127.0.0.1:6789"

# 强制注销可能引起 socket 崩溃的 SOCKS 代理
unset ALL_PROXY
unset all_proxy

# 放宽 TLS 校验
export NODE_TLS_REJECT_UNAUTHORIZED=0

# ==========================================
# 2. 核心路径配置
# ==========================================
SAVE_DIR="/Users/wzqin/Library/CloudStorage/OneDrive-个人/gemini-paper/Paper-Reading" # TODO: 根据实际情况调整路径
mkdir -p "$SAVE_DIR"

# ==========================================
# 3. 定义核心处理函数 (处理单篇 PDF)
# ==========================================
process_pdf() {
    local filepath="$1"
    
    # 提取无后缀的文件名 (例如从 attention.pdf 提取出 attention)
    local BASENAME=$(basename "$filepath" .pdf)
    local SAVE_PATH="$SAVE_DIR/${BASENAME}_分析报告.md"
    
    # 切换到论文所在目录（防 .Trash 扫描报错）
    cd "$(dirname "$filepath")" || return
    
    echo "📄 正在呼叫 Gemini 处理: $BASENAME.pdf"
    
    local PROMPT="请使用 paper-explainer 技能，帮我深度讲解并提取这篇论文的模型架构和实验结论。目标文件绝对路径：$filepath"

    # 使用绝对路径调用 gemini，并加上 || true 防止其崩溃导致整个脚本退出
    /opt/homebrew/bin/gemini --yolo "$PROMPT" < /dev/null > "$SAVE_PATH" 2>/dev/null || true

    if [ -s "$SAVE_PATH" ]; then
        echo "✅ 保存成功 -> $SAVE_PATH"
    else
        echo "⚠️ 处理失败或输出为空，请检查文件权限、代理状态或服务器是否限流。"
    fi
}

# ==========================================
# 4. 参数解析与路由 (判断是文件还是文件夹)
# ==========================================
INPUT_PATH="$1"

if [ -z "$INPUT_PATH" ] || [ ! -e "$INPUT_PATH" ]; then
    echo "❌ 错误: 请提供有效的文件夹路径或单个 PDF 文件路径！"
    exit 1
fi

echo "📁 笔记将自动保存至: $SAVE_DIR"
echo "=================================================="

# 如果是文件夹 (-d)
if [ -d "$INPUT_PATH" ]; then
    echo "📂 检测到输入为文件夹，开始批量处理..."
    # 查找所有 pdf 并循环处理
    find "$INPUT_PATH" -type f -iname "*.pdf" | while read -r file; do
        process_pdf "$file"
        
        SLEEP_TIME=$((RANDOM % 21 + 20))
        echo "💤 休眠 $SLEEP_TIME 秒防封禁..."
        sleep $SLEEP_TIME
        echo "--------------------------------------------------"
    done
    echo "🎉 文件夹内所有 PDF 论文处理并归档完成！"

# 如果是单个文件 (-f)
elif [ -f "$INPUT_PATH" ]; then
    # 兼容 macOS Bash 3.2 的小写转换写法
    INPUT_LOWER=$(echo "$INPUT_PATH" | tr '[:upper:]' '[:lower:]')
    
    # 检查后缀是否为 pdf
    if [[ "$INPUT_LOWER" != *.pdf ]]; then
         echo "❌ 错误: 传入的文件不是 PDF 格式！"
         exit 1
    fi
    echo "📄 检测到输入为单一 PDF 文件，开始处理..."
    process_pdf "$INPUT_PATH"
    echo "--------------------------------------------------"
    echo "🎉 单一 PDF 论文处理并归档完成！"
    
else
    echo "❌ 错误: 无法识别的路径类型！"
    exit 1
fi