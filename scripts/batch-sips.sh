#!/bin/bash

# 用法帮助
usage() {
    cat << 'EOF'
Usage: ./resize_icon.sh [OPTIONS] <input_image>

Options:
    -o, --output DIR     输出目录 (默认: ./AppIcon.appiconset)
    -p, --prefix NAME    文件名前缀 (默认: icon)
    -f, --format FMT     输出格式: png|jpg|webp (默认: png)
    -j, --json-only      仅生成 Contents.json，不处理图片
    -h, --help           显示帮助

Examples:
    ./resize_icon.sh icon_1024.png
    ./resize_icon.sh -o ./icons -p appIcon my_image.png
    ./resize_icon.sh -p launcher logo.png

EOF
    exit 0
}

# 默认配置
OUTPUT_DIR="./AppIcon.appiconset"
PREFIX="icon"
FORMAT="png"
JSON_ONLY=false
INPUT=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -p|--prefix)
            PREFIX="$2"
            shift 2
            ;;
        -f|--format)
            FORMAT="$2"
            shift 2
            ;;
        -j|--json-only)
            JSON_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "❌ 未知选项: $1"
            usage
            ;;
        *)
            INPUT="$1"
            shift
            ;;
    esac
done

# 如果不是仅生成JSON模式，检查输入文件
if [[ "$JSON_ONLY" == false ]]; then
    if [[ -z "$INPUT" ]]; then
        echo "❌ 错误: 请提供输入图片路径"
        usage
    fi
    if [[ ! -f "$INPUT" ]]; then
        echo "❌ 错误: 文件不存在: $INPUT"
        exit 1
    fi
    # 检查 sips 是否可用
    if ! command -v sips &> /dev/null; then
        echo "❌ 错误: 未找到 sips 命令 (仅 macOS 可用)"
        exit 1
    fi
fi

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 定义尺寸规格: "pt scale 实际像素 xcode_size"
sizes=(
    "16 1x 16 16x16"
    "16 2x 32 16x16"
    "32 1x 32 32x32"
    "32 2x 64 32x32"
    "128 1x 128 128x128"
    "128 2x 256 128x128"
    "256 1x 256 256x256"
    "256 2x 512 256x256"
    "512 1x 512 512x512"
    "1024 1x 1024 512x512"
)

# 生成 Contents.json
generate_json() {
    local json_file="$OUTPUT_DIR/Contents.json"
    
    echo "📝 生成 Contents.json..."
    
    cat > "$json_file" << EOF
{
  "images" : [
EOF

    local first=true
    for spec in "${sizes[@]}"; do
        read pt scale px xcode_size <<< "$spec"
        filename="${PREFIX}_${pt}pt@${scale}.${FORMAT}"
        
        # 处理逗号（最后一个不加逗号）
        if [[ "$first" == true ]]; then
            first=false
        else
            echo "," >> "$json_file"
        fi
        
        # 注意：1024pt@1x 在 Xcode 里对应 512x512 的 2x 图
        if [[ "$pt" == "1024" ]]; then
            scale="2x"
        fi
        
        cat >> "$json_file" << EOF
    {
      "filename" : "$filename",
      "idiom" : "mac",
      "scale" : "$scale",
      "size" : "$xcode_size"
    }
EOF
    done

    cat >> "$json_file" << EOF

  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

    echo "   ✅ $json_file"
}

# 处理图片
process_images() {
    echo "🎨 处理图片: $INPUT"
    echo "   输出: $OUTPUT_DIR/"
    echo "   格式: $FORMAT | 前缀: $PREFIX"
    
    local success=0
    local failed=0

    for spec in "${sizes[@]}"; do
        read pt scale px xcode_size <<< "$spec"
        output_name="${PREFIX}_${pt}pt@${scale}.${FORMAT}"
        output_path="$OUTPUT_DIR/$output_name"
        
        echo -n "  生成 ${pt}pt@${scale} (${px}x${px})... "
        
        if sips -z $px $px "$INPUT" --out "$output_path" &>/dev/null; then
            echo "✅"
            ((success++))
        else
            echo "❌ 失败"
            ((failed++))
        fi
    done

    echo ""
    echo "✅ 图片处理完成: $success 个成功, $failed 个失败"
}

# 主逻辑
if [[ "$JSON_ONLY" == true ]]; then
    echo "📁 仅生成 Contents.json 模式"
    generate_json
else
    process_images
    generate_json
fi

echo "📁 输出目录: $(cd "$OUTPUT_DIR" && pwd)"
echo ""
echo "📋 生成的文件列表:"
ls -la "$OUTPUT_DIR"
