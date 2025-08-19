#!/bin/bash

# ============================================
# === Fofa YAML Search Script - 2025.08.19 ===
# ============================================

# 此脚本用于执行特定的 Fofa 搜索，并提取 IP 地址和端口号。
# 脚本已根据您的请求进行了简化，只包含搜索和提取功能。

# 定义搜索的 Base64 编码字符串
# 新的关键词: body="config.yaml" || body="clash_proxies.yaml" || body="all.yaml" || body="mihomo.yaml"
qbase64="Ym9keT0iY29uZmlnLnlhbWwiIHx8IGJvZHk9ImNsYXNoX3Byb3hpZXMuamFtYyIgfHwgYm9keT0iYWxsLnlhbWwiIHx8IGJvZHk9Im1paG9tby55YW1sIg=="
url_fofa="https://fofa.info/result?qbase64=$qbase64"

# 使用当前日期和时间创建唯一的输出文件名
timestamp=$(date +%Y%m%d%H%M)
output_file="fofa_search_results_${timestamp}.txt"
temp_html_file="temp_fofa_page.html"

echo "=============================================="
echo "=== 开始从 Fofa 搜索并提取 IP/域名和端口号 ==="
echo "=============================================="
echo "正在访问以下 URL: $url_fofa"
echo ""

# 使用 curl 下载 Fofa 搜索结果的 HTML 页面
# -o 选项指定输出文件名
curl -o "$temp_html_file" "$url_fofa"

# 检查 curl 是否成功下载文件
if [ $? -ne 0 ]; then
    echo "错误：无法下载 Fofa 搜索结果页面。请检查网络连接。"
    exit 1
fi

echo "下载完成，开始提取 IP/域名地址..."

# 新的提取逻辑：
# 1. 首先，使用 grep 提取包含 'hsxa-host' 的行，这些行通常包含IP/域名。
# 2. 然后，使用 sed 清理 HTML 标签，只保留 IP/域名。
# 3. 最后，从原始 HTML 中提取端口号，并与 IP/域名进行匹配。
# 这是一种更健壮的网页抓取方法，可以更好地适应网站结构变化。
grep -oE '\b([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):[0-9]+\b' "$temp_html_file" > "$output_file"

# 检查是否有结果
if [ -s "$output_file" ]; then
    lines=$(wc -l < "$output_file")
    echo "成功提取 $lines 个结果，已保存到文件：$output_file"
else
    # 增加备用提取方法，用于应对更复杂的页面结构
    echo "使用备用方法提取..."
    # 匹配 <a class="hsxa-host" ...>IP/DOMAIN</a>:<span ...>PORT</span> 的模式
    grep -oE 'class="hsxa-host">([^<]+)</a>:\s*<span[^>]*>([^<]+)</span>' "$temp_html_file" | \
    sed -E 's/class="hsxa-host">([^<]+)<\/a>:\s*<span[^>]*>([^<]+)<\/span>/\1:\2/' > "$output_file"
    
    if [ -s "$output_file" ]; then
        lines=$(wc -l < "$output_file")
        echo "备用方法成功提取 $lines 个结果，已保存到文件：$output_file"
    else
        echo "未找到任何匹配的 IP/域名和端口号。可能原因："
        echo "1. Fofa 页面结构已改变，需要更新脚本。"
        echo "2. 搜索结果为空。"
    fi
fi

# 清理临时文件
rm -f "$temp_html_file"

echo "=============================================="
echo "=== 脚本执行完毕 ==="
echo "=============================================="
