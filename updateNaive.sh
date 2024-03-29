#!/bin/bash

#    bash <(curl -L https://raw.githubusercontent.com/simtelboy/haogezhiming2/main/updateNaive.sh)

# 定义变量
RELEASE_URL="https://github.com/klzgrad/forwardproxy/releases/latest/download/caddy-forwardproxy-naive.tar.xz"
BIN_PATH="/bin"
TMP_DIR="/tmp"
TMP_FILE="/tmp/caddy-forwardproxy-naive.tar.xz"
LOCAL_VERSION=$($BIN_PATH/caddy --version 2>&1 | awk '{print $1}')
REMOTE_VERSION=$(curl -s https://api.github.com/repos/klzgrad/forwardproxy/releases/latest | grep 'tag_name' | cut -d '"' -f 4)

# 从版本字符串中仅提取主版本号 vX.Y.Z
LOCAL_VERSION=$(echo $LOCAL_VERSION | grep -oP 'v\d+\.\d+\.\d+')
REMOTE_VERSION=$(echo $REMOTE_VERSION | grep -oP 'v\d+\.\d+\.\d+')

# 比较版本
if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "发现新版本: $REMOTE_VERSION, 本地版本: $LOCAL_VERSION. 正在更新..."
    
    # 停止caddy服务
    systemctl stop caddy.service
    
    # 下载最新版本的naiveproxy
    wget -O $TMP_FILE $RELEASE_URL
    
    # 解压缩到临时目录
   # mkdir -p $TMP_DIR
    tar -xJf $TMP_FILE -C $TMP_DIR
    
    # 替换旧版本的caddy
    mv $TMP_DIR/caddy-forwardproxy-naive/caddy $BIN_PATH
    
    # 确保新版本的caddy具有执行权限
    chmod +x $BIN_PATH/caddy
    
    
    
    # 重新启动caddy服务
    systemctl start caddy.service

    # 清理下载的临时文件和目录
    rm -f $TMP_FILE
    rm -rf $TMP_DIR/caddy-forwardproxy-naive
   
    echo "naiveproxy 更新完成."
else
    echo "当前版本是最新版本: $LOCAL_VERSION."
fi
