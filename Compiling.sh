#!/bin/bash

# 1. 安装 Go（最新版本）
echo "正在安装 Go..."
LATEST_GO_VERSION=$(curl -s https://go.dev/dl/ | grep -oP 'go[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n 1)
GO_TAR="https://golang.org/dl/${LATEST_GO_VERSION}.linux-amd64.tar.gz"

# 下载并安装 Go
wget $GO_TAR
sudo tar -zxvf "${LATEST_GO_VERSION}.linux-amd64.tar.gz" -C /usr/local/

# 设置环境变量
echo -e 'export PATH=$PATH:/usr/local/go/bin\nexport PATH=$PATH:$HOME/go/bin' | tee -a ~/.bashrc ~/.profile
source ~/.bashrc && source ~/.profile

# 2. 安装 xcaddy
echo "正在安装 xcaddy..."
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# 3. 安装 C 编译器
echo "正在安装 C 编译器..."
sudo apt update 
sudo apt install -y build-essential

# 4. 使用 xcaddy 编译带有 naiveproxy 插件的 Caddy
echo "正在编译带有 naiveproxy 插件的 Caddy..."
CGO_ENABLED=1 xcaddy build --with github.com/caddyserver/forwardproxy=github.com/simtelboy/forwardproxy2@naive

echo "安装和编译完成！"
