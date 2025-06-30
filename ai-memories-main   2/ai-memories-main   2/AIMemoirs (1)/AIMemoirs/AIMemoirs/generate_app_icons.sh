#!/bin/bash

# 生成iOS应用图标脚本
# 使用方法：./generate_app_icons.sh source_icon.jpg

if [ "$#" -ne 1 ]; then
    echo "使用方法: $0 <source_icon_file>"
    echo "例如: $0 c9c824809f81e7bc68cea8ab5bfa33e9.jpg"
    exit 1
fi

SOURCE_ICON="$1"
OUTPUT_DIR="Assets.xcassets/AppIcon.appiconset"

# 检查源文件是否存在
if [ ! -f "$OUTPUT_DIR/$SOURCE_ICON" ]; then
    echo "错误: 源图标文件 $OUTPUT_DIR/$SOURCE_ICON 不存在"
    exit 1
fi

echo "开始生成应用图标..."

# 定义所有需要的图标尺寸
declare -a SIZES=(
    "20:AppIcon-20x20.png"
    "40:AppIcon-20x20@2x.png"
    "60:AppIcon-20x20@3x.png"
    "29:AppIcon-29x29.png"
    "58:AppIcon-29x29@2x.png"
    "87:AppIcon-29x29@3x.png"
    "40:AppIcon-40x40.png"
    "80:AppIcon-40x40@2x.png"
    "120:AppIcon-40x40@3x.png"
    "76:AppIcon-76x76.png"
    "152:AppIcon-76x76@2x.png"
    "120:AppIcon-60x60@2x.png"
    "180:AppIcon-60x60@3x.png"
    "167:AppIcon-83.5x83.5@2x.png"
    "1024:AppIcon-1024x1024.png"
)

# 生成每个尺寸的图标
for size_info in "${SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    echo "生成 ${filename} (${size}x${size})"
    
    sips -z "$size" "$size" "$OUTPUT_DIR/$SOURCE_ICON" --out "$OUTPUT_DIR/$filename" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "✅ $filename 生成成功"
    else
        echo "❌ $filename 生成失败"
    fi
done

# 删除旧的jpg文件（可选）
read -p "是否删除原始的jpg文件? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm "$OUTPUT_DIR"/*.jpg
    echo "✅ 已删除旧的jpg文件"
fi

echo "应用图标生成完成!"
echo "请在Xcode中重新构建项目以应用新的图标。" 