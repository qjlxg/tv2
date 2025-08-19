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

# 尝试第一种提取方法：匹配 IP:PORT 或 DOMAIN:PORT 格式
grep -oE '\b([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}|[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):[0-9]+\b' "$temp_html_file" > "$output_file"

# 尝试第二种提取方法：如果第一种失败，尝试匹配 Fofa 网页中的特定HTML结构
if [ ! -s "$output_file" ]; then
    echo "方法一未找到结果，使用备用方法提取..."
    # 备用方法：匹配 <a class="hsxa-host" ...>IP/DOMAIN</a>:<span ...>PORT</span> 的模式
    grep -oE 'class="hsxa-host">([^<]+)</a>:\s*<span[^>]*>([^<]+)</span>' "$temp_html_file" | \
    sed -E 's/class="hsxa-host">([^<]+)<\/a>:\s*<span[^>]*>([^<]+)<\/span>/\1:\2/' > "$output_file"
fi

# 尝试第三种提取方法：如果前两种都失败，尝试更通用的模式
if [ ! -s "$output_file" ]; then
    echo "备用方法也未找到结果，尝试更通用的匹配..."
    # 尝试提取所有包含 IP 或域名，并后接端口号的模式
    grep -oE '([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,})(:|\s*:\s*)[0-9]+' "$temp_html_file" | \
    sed -E 's/\s+//g' > "$output_file"
fi


# 检查所有方法后是否有结果
if [ -s "$output_file" ]; then
    lines=$(wc -l < "$output_file")
    echo "成功提取 $lines 个结果，已保存到文件：$output_file"
else
    echo "未找到任何匹配的 IP/域名和端口号。可能原因："
    echo "1. Fofa 页面结构已发生较大变化，需要更新脚本。"
    echo "2. 搜索结果为空。"
fi

# 清理临时文件
rm -f "$temp_html_file"

echo "=============================================="
echo "=== 脚本执行完毕 ==="
echo "=============================================="
