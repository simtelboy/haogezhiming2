#!/bin/bash

/*
使用:   bash <(curl -s https://raw.githubusercontent.com/simtelboy/haogezhiming2/refs/heads/main/Uninstalling.sh)
或者:   bash <(wget -qO- https://raw.githubusercontent.com/simtelboy/haogezhiming2/refs/heads/main/Uninstalling.sh)

*/

# 1. 删除 Go 安装目录
echo "正在删除 Go 安装目录..."
sudo rm -rf /usr/local/go

# 2. 删除 xcaddy
echo "正在删除 xcaddy..."
go clean -i github.com/caddyserver/xcaddy/cmd/xcaddy

# 3. 清理环境变量配置
echo "正在清理环境变量配置..."
sed -i '/\/usr\/local\/go\/bin/d' ~/.bashrc
sed -i '/\/usr\/local\/go\/bin/d' ~/.profile
sed -i '/\$HOME\/go\/bin/d' ~/.bashrc
sed -i '/\$HOME\/go\/bin/d' ~/.profile

# 4. 重新加载配置文件
echo "重新加载配置文件..."
source ~/.bashrc
source ~/.profile

echo "反安装完成！"
