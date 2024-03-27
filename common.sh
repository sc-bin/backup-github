#!/bin/bash


# 如果文件夹不存在，则创建它
mkdir_if_not_exit() {
    DIR=$1
    if [ ! -d $DIR ]; then
        mkdir -p  $DIR
        echo "已创建 $DIR"
    fi
}

# 传入一个文件的路径，转化为一个数组返回
read_file_as_array(){
    local file_path=$1
    local lines=()
    while IFS= read -r line
    do
        # 跳过以#开头的行
        if [[ $line != \#* ]]; then
            lines+=("$line")
        fi
    done < "$file_path"
    echo ${lines[@]}
}
get_git_url_projectname() {
    git_url=$1
    project_name=$(basename "$git_url" | sed 's/\.git$//')
    echo $project_name
}
get_git_url_username() {
    url=$1
    if [[ $url == http* ]]; then
        username=$(echo $url | cut -d'/' -f4)
    else
        username=$(echo $url | cut -d':' -f2 | cut -d'/' -f1)
    fi
    echo $username
}
