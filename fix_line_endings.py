#!/usr/bin/env python3
import os
import glob

# 需要转换的文件路径列表
files_to_convert = [
    'luci-app-ssr-plus/root/etc/init.d/shadowsocksr',
    'luci-app-ssr-plus/root/usr/bin/ssr-rules',
    'luci-app-ssr-plus/root/usr/bin/ssr-monitor',
    'luci-app-ssr-plus/root/usr/bin/ssr-switch',
    'luci-app-ssr-plus/root/etc/uci-defaults/luci-ssr-plus',
    'luci-app-ssr-plus/root/usr/share/shadowsocksr/*.sh'
]

def convert_to_lf(filepath):
    """Convert CRLF to LF in a file"""
    try:
        with open(filepath, 'rb') as file:
            content = file.read()
        
        # Replace CRLF with LF
        content = content.replace(b'\r\n', b'\n')
        
        with open(filepath, 'wb') as file:
            file.write(content)
        
        print(f"Converted: {filepath}")
    except Exception as e:
        print(f"Error converting {filepath}: {e}")

# Convert each file
for pattern in files_to_convert:
    if '*' in pattern:
        # Handle glob patterns
        for filepath in glob.glob(pattern):
            if os.path.isfile(filepath):
                convert_to_lf(filepath)
    else:
        # Handle single files
        if os.path.isfile(pattern):
            convert_to_lf(pattern)
        else:
            print(f"File not found: {pattern}")

print("\nLine ending conversion completed!")