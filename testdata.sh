#!/bin/bash

# 生成随机内容
g_content() {
    openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 50
}

# 生成日志文件内容
generate_log_file() {
    file_name="$1"
    for ((i=1; i<=100; i++)); do
        echo "$(g_content)" >> "$file_name"
    done
}

# 循环生成文件
for ((i=1; i<=10; i++)); do
    for format_type in csv dat log txt; do
        for ((j=1; j<=10; j++)); do
            file_name="lofile_${i}_${format_type}_${j}.$format_type"
            generate_log_file "$file_name"
            echo "已生成文件：$file_name"
        done
    done
done

