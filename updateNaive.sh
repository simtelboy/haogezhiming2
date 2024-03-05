#!/bin/bash

#    bash <(curl -L https://github.com/simtelboy/haogezhiming2/raw/main/2.sh)

# 定义变量
RELEASE_URL="https://github.com/klzgrad/forwardproxy/releases/latest/download/caddy-forwardproxy-naive.tar.xz"
LOCAL_VERSION=$(caddy --version 2>&1 | grep 'naive' | awk '{print $NF}')
REMOTE_VERSION=$(curl -sL https://api.github.com/repos/klzgrad/forwardproxy/releases/latest | grep 'tag_name' | cut -d '"' -f 4)

# 比较版本
if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "发现新版本: $REMOTE_VERSION, 本地版本: $LOCAL_VERSION. 正在更新..."
    
    # 停止caddy服务
    systemctl stop caddy.service
    
    # 下载最新版本的naiveproxy
    wget -O /tmp/caddy-forwardproxy-naive.tar.xz $RELEASE_URL
    
    # 解压缩并替换文件
    tar -xJf /tmp/caddy-forwardproxy-naive.tar.xz -C /tmp
    mv /tmp/caddy /bin/caddy
    
    # 确保caddy具有执行权限
    chmod +x /bin/caddy
    
    # 清理下载的临时文件
    rm /tmp/caddy-forwardproxy-naive.tar.xz
    
    # 重新启动caddy服务
    systemctl start caddy.service
    
    echo "naiveproxy 更新完成."
else
    echo "当前版本是最新版本: $LOCAL_VERSION."
fi
