#!/bin/bash

# 设置路径
search_path="/tmp/tool"
# 设置备份存放路径
backup_path="/tmp/tool/backup"

# 设置关键词
keywords=("at" "log" "faA")

# 设置打包方式，Y表示相同关键词文件打包成一个包，N表示所有关键词文件打包成一个包
pack_same_keyword="Y"

# 设置日志输出开关，Y表示启用日志输出，N表示禁用日志输出
log_switch="N"
# 设置日志文件存放路径
log_path="/tmp/tool/backup/backup_script.log"

# 备份文件命名中日期通过调用该函数获取
current_date=$(date +'%Y-%m-%d')

# 辅助函数：根据日志输出开关决定是否输出日志
log_output() {
    if [ "$log_switch" = "Y" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$log_path"
    else
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    fi
}

# 检查备份路径是否存在，不存在则创建
if [ ! -d "$backup_path" ]; then
    mkdir -p "$backup_path"
    log_output "备份路径 $backup_path 已创建"
fi

# 初始化关键词对应的文件列表
declare -A keyword_files

# 遍历关键词，初始化文件列表
for keyword in "${keywords[@]}"; do
    keyword_files["$keyword"]=""
done

# 遍历路径下的文件
for file in "$search_path"/*; do
    # 检查文件是否存在
    if [ -f "$file" ]; then
        # 获取文件名
        filename=$(basename "$file")
        # 遍历关键词
        for keyword in "${keywords[@]}"; do
            # 检查文件名是否包含关键词
            if [[ "$filename" == *"$keyword"* ]]; then
                # 将文件加入相应关键词的列表
                keyword_files["$keyword"]+="$file "
                break
            fi
        done
    fi
done

# 根据关键词进行备份和删除文件
for keyword in "${!keyword_files[@]}"; do
    files=${keyword_files["$keyword"]}
    if [ -n "$files" ]; then
        # 生成备份文件名
        backup_filename="${keyword}_files_${current_date}.tar.gz"
        # 如果打包方式为N，则将所有关键词的文件合并为一个文件列表
        if [ "$pack_same_keyword" = "N" ]; then
            all_files+="$files"
        else
            # 打包文件
            tar -czvf "$backup_path/$backup_filename" $files
            # 删除源文件
            rm $files
            log_output "关键词 $keyword 的文件已打包成 $backup_filename 并删除源文件"
        fi
    fi
done

# 如果打包方式为N，则将所有关键词的文件打包到一个包中
if [ "$pack_same_keyword" = "N" ]; then
    # 生成备份文件名
    backup_filename="all_files_${current_date}.tar.gz"
    # 打包文件
    tar -czvf "$backup_path/$backup_filename" $all_files
    # 删除源文件
    rm $all_files
    log_output "所有关键词的文件已打包成 $backup_filename 并删除源文件"
fi

log_output "备份和删除完成"

