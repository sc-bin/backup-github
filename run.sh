#!/bin/bash

URL_TXT="url.txt"

PATH_CURRENT=$(
    cd $(dirname $0)
    pwd
)
FILE_URL_TXT="${PATH_CURRENT}/${URL_TXT}"
PATH_CLONE_PROJECT="${PATH_CURRENT}/GITHUB"
PATH_SAVE_TAR="${PATH_CURRENT}/BACKUP"
PATH_LOG="${PATH_CURRENT}/LOG"
FILE_LOG_LAST="${PATH_CURRENT}/last.log"
FILE_LOG="${PATH_LOG}/$(date +%Y-%m-%d-%H_%M_%S).log"

[[ ! -d $PATH_LOG ]] && mkdir -p $PATH_LOG
[[ -f $FILE_LOG ]] && rm -f $FILE_LOG
[[ -f $FILE_LOG_LAST ]] && rm -f $FILE_LOG_LAST
touch $FILE_LOG
touch $FILE_LOG_LAST

log() {
    text=$1
    echo -e "$text" | tee -a $FILE_LOG
    echo -e "$text" | tee -a $FILE_LOG_LAST
}

log "==================== $(date +%Y-%m-%d %H:%M) ===================="

# 检测 URL_TXT 文件是否存在，不存在则创建后退出
if [ ! -f $FILE_URL_TXT ]; then
    echo "已创建 ${FILE_URL_TXT} 文件，请将要下载的github项目一行行的存放进去"
    touch $FILE_URL_TXT
fi

source ${PATH_CURRENT}/common.sh
mkdir_if_not_exit $PATH_CLONE_PROJECT

cd $PATH_CLONE_PROJECT
project_list=$(read_file_as_array $FILE_URL_TXT)
count=0

for project_url in ${project_list[@]}; do
    count=$(expr $count + 1)
    echo -e "[ $count ]  $project_url\n"
    dir_user=${PATH_CLONE_PROJECT}/$(get_git_url_username $project_url)
    dir_project=${dir_user}/$(get_git_url_projectname $project_url)
    echo -e "\t存放 : $dir_project"
    mkdir_if_not_exit $dir_user

    # 存在该文件夹，则pull
    # 不存在，则clone
    if [ ! -d $dir_project ]; then
        cd $dir_user
        git clone $project_url
        if [ $? -ne 0 ]; then
            log "克隆失败 : $project_url"
        else
            log "           $project_url"
        fi
    else
        cd $dir_project
        git pull
        if [ $? -ne 0 ]; then
            log "更新失败 : $project_url"
        else
            log "           $project_url"
        fi
    fi
    echo -e "\n"
done
