#!/bin/bash
# 强制设置终端支持颜色
export TERM=xterm-256color

# 一键安装
# apt update
# apt install -y curl
# bash <(curl -L https://github.com/simtelboy/haogezhiming2/raw/main/caddy_manager.sh)
# 
# 一条语句安装: apt update -y && apt install -y curl && bash <(curl -L https://github.com/simtelboy/haogezhiming2/raw/main/caddy_manager.sh)

#
#
# 反安装执行以下语句
# service caddy stop
# systemctl disable caddy
# sudo userdel caddy
# sudo groupdel caddy
# rm -r /etc/caddy
# rm /etc/systemd/system/caddy.service
# rm /usr/bin/caddy
# 
# 一条语句反安装:
# service caddy stop && systemctl disable caddy && sudo userdel caddy && sudo groupdel caddy && rm -r /etc/caddy && rm /etc/systemd/system/caddy.service && rm /usr/bin/caddy && rm /etc/apt/sources.list.d/caddy-stable.list && apt remove -y caddy || true


# 颜色定义
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
none='\033[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# 错误处理
error() {
    echo -e "\n$red 输入错误! $none\n"
}

sleep 1
# 显示“天神之眼”的ASCII艺术（金色）
echo -e "${yellow}             #      #       #            #                      #    \n #############      #      #             #             # ########   \n       #            #      #  #          #          ######     #    \n       #         ###### ########                    #  # #     #    \n       #             #  #  #  #    ############     #  # #######    \n       #     #      #   #  #  #              #      #  # #     #    \n###############    ###  #  #  #             #       #### #     #    \n       #          # # # #######            #        #  # #######    \n      # #        #  #   #  #  #           #         #  # # #    #   \n      # #           #   #  #  #          #          #### # #   #    \n     #   #          #   #  #  #         #           #  # #  # #     \n     #   #          #   #######       ##            #  # #   #      \n    #     #         #   #  #  #     ##              #  # #    #     \n   #       #        #      #       #  #        ##   #### # #   ###  \n  #         ###     #      #           #########    #  # ##     #   \n##           #      #      #                             #    ${none}"
#说明
echo
echo -e "$yellow此脚本仅兼容于Debian 10+系统. 如果你的系统不符合,请Ctrl+C退出脚本$none"

# 暂停函数
pause() {
    read -rsp "$(echo -e "按 $green Enter 回车键 $none 继续....或按 $red Ctrl + C $none 取消.")" -d $'\n'
    echo
}

# 显示菜单
show_menu() {
    echo -e "${yellow}请选择操作：${none}"
    echo -e "${green}1: 安装【天神之眼】系统${none}"
    echo -e "${green}2: 升级核心程序${none}"
    echo -e "${green}3: 升级核心程序和网页管理系统${none}"
    echo -e "${green}4: 卸载所有${none}"
    echo -e "${green}5: 查看天神之眼状态${none}"
    echo -e "${green}6: 退出（Ctrl+C）${none}"
    read -p "请输入选项 (1/2/3/4/5): " choice
}

# 获取本地Caddy版本
get_local_caddy_version() {
    local_version=$(caddy version | awk '{print $1}')
    echo "$local_version"
}

# 获取GitHub上最新的Caddy版本
get_latest_caddy_version() {
    latest_version=$(curl -s https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy | grep -oP '"tag_name": "\K(.*)(?=")')
    echo "$latest_version"
}

# 比较版本号
compare_versions() {
    local_version=$1
    latest_version=$2

    if [[ "$local_version" == "$latest_version" ]]; then
        echo "0"
    elif [[ "$local_version" < "$latest_version" ]]; then
        echo "1"
    else
        echo "-1"
    fi
}


# 检查 Caddy 状态
check_caddy_status() {
    # 获取 Caddy 的进程 ID
    CADDY_PID=$(pgrep -f caddy)

    if [ -z "$CADDY_PID" ]; then
        echo -e "${red}未找到正在运行的 Caddy 进程${none}"
        return 1
    fi

    echo -e "${yellow}=== 天神之眼 进程监控 ===${none}"
    echo "进程 PID: $CADDY_PID"
    echo ""

    # 获取 CPU 和内存使用情况（通过 /proc）
    echo "1. CPU 和内存占用:"
    cpu_times=$(cat /proc/"$CADDY_PID"/stat 2>/dev/null | awk '{print $14 + $15 + $16 + $17}') # utime + stime + cutime + cstime
    total_cpu=$(cat /proc/stat 2>/dev/null | grep '^cpu ' | awk '{print $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9 + $10}')
    if [ -n "$cpu_times" ] && [ -n "$total_cpu" ] && [ "$total_cpu" -gt 0 ]; then
        cpu_usage=$((cpu_times * 100 / total_cpu))
        cpu_display="$cpu_usage%"
    else
        cpu_display="无法获取"
    fi
    rss=$(grep "VmRSS" /proc/"$CADDY_PID"/status 2>/dev/null | awk '{print $2}') # Resident Set Size (KB)
    total_mem=$(grep "MemTotal" /proc/meminfo 2>/dev/null | awk '{print $2}') # Total memory (KB)
    if [ -n "$rss" ] && [ -n "$total_mem" ] && [ "$total_mem" -gt 0 ]; then
        mem_usage=$((rss * 100 / total_mem))
        mem_display="$mem_usage% ($rss KB / $total_mem KB)"
    else
        mem_display="无法获取"
    fi
    echo "CPU 使用率: $cpu_display"
    echo "内存使用率: $mem_display"
    echo ""

    # 获取线程数
    echo "2. 线程数:"
    threads=$(cat /proc/"$CADDY_PID"/status 2>/dev/null | grep "Threads" | awk '{print $2}')
    echo "线程数: ${threads:-无法获取}"
    echo ""

    # 获取打开的文件描述符数
    echo "3. 打开的文件描述符数:"
    fd_count=$(ls /proc/"$CADDY_PID"/fd 2>/dev/null | wc -l)
    echo "文件描述符数: ${fd_count:-无法获取}"
    echo ""

    # 获取网络连接信息（通过 /proc/net）
    echo "4. 网络连接状态（简略版）:"
    tcp_connections=$(cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | grep -v "sl" | wc -l)
    echo "活动 TCP 连接数: ${tcp_connections:-无法获取}"
    echo "（详细连接信息需要 netstat 或 ss，当前仅显示总数）"
    echo ""

    # 获取网络带宽使用情况
    echo "5. 网络带宽使用情况 (计算中，请等待 5 秒)..."
    interface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5}' | head -n 1)
    if [ -z "$interface" ]; then
        echo "无法确定网络接口"
    else
        rx1=$(cat /proc/net/dev | grep "$interface" | awk '{print $2}')
        tx1=$(cat /proc/net/dev | grep "$interface" | awk '{print $10}')
        sleep 5
        rx2=$(cat /proc/net/dev | grep "$interface" | awk '{print $2}')
        tx2=$(cat /proc/net/dev | grep "$interface" | awk '{print $10}')
        
        rx_speed=$(( (rx2 - rx1) / 5 / 1024 ))
        tx_speed=$(( (tx2 - tx1) / 5 / 1024 ))
        
        echo "下载速度: ${rx_speed:-无法获取} KB/s"
        echo "上传速度: ${tx_speed:-无法获取} KB/s"
    fi
    echo ""

    # 获取运行时间（纯整数运算）
    echo "6. 进程运行时间:"
    start_time=$(cat /proc/"$CADDY_PID"/stat 2>/dev/null | awk '{print $22}') # 以 jiffies 为单位
    jiffies_per_sec=$(getconf CLK_TCK 2>/dev/null) # 系统每秒 jiffies 数，通常是 100
    current_time=$(cat /proc/uptime 2>/dev/null | awk '{print $1}' | cut -d'.' -f1) # 系统运行时间（秒）
    if [ -n "$start_time" ] && [ -n "$jiffies_per_sec" ] && [ -n "$current_time" ] && [ "$jiffies_per_sec" -gt 0 ]; then
        elapsed_sec=$((current_time - start_time / jiffies_per_sec))
        days=$((elapsed_sec / 86400))
        hours=$(((elapsed_sec % 86400) / 3600))
        mins=$(((elapsed_sec % 3600) / 60))
        secs=$((elapsed_sec % 60))
        runtime=$(printf "%d-%02d:%02d:%02d" "$days" "$hours" "$mins" "$secs")
    else
        runtime="无法获取"
    fi
    echo "运行时间: $runtime"
    echo ""

    echo -e "${yellow}=== 监控完成 ===${none}"
}


# 安装Caddy
install_caddy() {
    echo -e "${yellow}开始安装天神之眼高阶版...${none}"
   
#执行脚本带参数
if [ $# -ge 1 ]; then

    #默认不重新编译
    not_rebuild="Y"

    #第一个参数是域名
    naive_domain=${1}

    #第二个参数是ipv4还是ipv6
    case ${2} in
    4)
        netstack=4
        ;;
    6) 
        netstack=6
        ;;
    *)  #initial
        netstack="i"
        ;;
    esac

    #第3个参数是 端口
    naive_port=${3}
    if [[ -z $naive_port ]]; then
        naive_port=443
    fi


    #第四个参数是 用户名
    naive_user="haoge" #设置默认用户名
    #naive_user=${4}
    #if [[ -z $naive_user ]]; then
    #    naive_user=$(openssl rand -hex 8)
    #fi


    #第五个参数是 密码
    naive_pass="123456789kt" #设置默认密码
    #naive_pass=${5}
    #if [[ -z $naive_pass ]]; then
        #默认与用户名相等
    #    naive_pass=$naive_user
    #fi
    
    #第六个参数是伪装网址
    naive_fakeweb=${6}
     
    echo -e "域名:${naive_domain}"
    echo -e "网域栈:${netstack}"
    echo -e "端口:${naive_port}"
    echo -e "用户名:${naive_user}"
    echo -e "密码:${naive_pass}"
    echo -e "伪装:${naive_fakeweb}"
else
    # 如果没有提供参数，则设置默认值
    naive_user="DivineEye"
    naive_pass="DivineEye"    
fi


pause


# 准备
apt update
apt install -y sudo curl wget git jq qrencode


echo
echo -e "$yellow下载程序主体$none"
echo "----------------------------------------------------------------"
cd /tmp
rm -f caddy
wget https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy

# 替换caddy可执行文件
echo
echo -e "$yellow替换可执行文件$none"
echo "----------------------------------------------------------------"
service caddy stop
cp caddy /usr/bin/
chmod +x /usr/bin/caddy

# xkcd密码生成器页面
echo
echo -e "$yellow 密码生成器 $none"
echo "----------------------------------------------------------------"
rm -rf /var/www/xkcdpw-html
git clone https://github.com/simtelboy/xkcd-password-generator -b "master" /var/www/xkcdpw-html --depth=1

# 域名
if [[ -z $naive_domain ]]; then
    while :; do
        echo
        echo -e "请输入一个 ${magenta}正确的域名${none} Input your domain"
        read -p "(例如: mydomain.com): " naive_domain
        [ -z "$naive_domain" ] && error && continue
        echo
        echo
        echo -e "$yellow 你的域名Domain = $cyan$naive_domain$none"
        echo "----------------------------------------------------------------"
        break
    done
fi


# 网络栈
if [[ -z $netstack ]]; then
    echo -e "如果你的服务器是${magenta}双栈(同时有IPv4和IPv6的IP)${none}，请选择你把系统搭在哪个'网口'上"
    echo "如果你不懂这段话是什么意思, 请直接回车"
    read -p "$(echo -e "Input ${cyan}4${none} for IPv4, ${cyan}6${none} for IPv6:") " netstack
    if [[ $netstack == "4" ]]; then
        domain_resolve=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$naive_domain&type=A" | jq -r '.Answer[0].data')
    elif [[ $netstack == "6" ]]; then 
        domain_resolve=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$naive_domain&type=AAAA" | jq -r '.Answer[0].data')
    else
        domain_resolve=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$naive_domain&type=A" | jq -r '.Answer[0].data')
        if [[ "$domain_resolve" != "null" ]]; then
            netstack="4"
        else
            domain_resolve=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$naive_domain&type=AAAA" | jq -r '.Answer[0].data')            
            if [[ "$domain_resolve" != "null" ]]; then
                netstack="6"
            fi
        fi
    fi


      # 本机 IP
    if [[ $netstack == "4" ]]; then
        ip=$(curl -4s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
    elif [[ $netstack == "6" ]]; then 
        ip=$(curl -6s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
    else
        ip=$(curl -s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
    fi

    if [[ $domain_resolve != $ip ]]; then
        echo
        echo -e "$red 域名解析错误Domain resolution error....$none"
        echo
        echo -e " 你的域名: $yellow$domain$none 未解析到: $cyan$ip$none"
        echo
        if [[ $domain_resolve != "null" ]]; then
            echo -e " 你的域名当前解析到: $cyan$domain_resolve$none"
        else
            echo -e " $red检测不到域名解析Domain not resolved $none "
        fi
        echo
        echo -e "备注...如果你的域名是使用$yellow Cloudflare $none解析的话... 在 DNS 设置页面, 请将$yellow代理状态$none设置为$yellow仅限DNS$none, 小云朵变灰."
        echo "Notice...If you use Cloudflare to resolve your domain, on 'DNS' setting page, 'Proxy status' should be 'DNS only' but not 'Proxied'."
        echo
        exit 1
    else
        echo
        echo
        echo -e "$yellow 域名解析 = ${cyan}我确定已经有解析了$none"
        echo "----------------------------------------------------------------"
        echo
    fi
fi


# 端口
if [[ -z $naive_port ]]; then
    default=443
    while :; do
        echo -e "请输入 ${yellow}端口${none} [${magenta}1-65535${none}], 不能选择 ${magenta}80${none}端口"
        read -p "$(echo -e "(默认端口port: ${cyan}${default}$none):")" naive_port
        [ -z "$naive_port" ] && naive_port=$default
        case $naive_port in
        80)
            echo
            echo " ...都说了不能选择 80 端口了咯....."
            error
            ;;
        [1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
            echo
            echo
            echo -e "$yellow 端口Port = $cyan$naive_port$none"
            echo "----------------------------------------------------------------"
            echo
            break
            ;;
        *)
            error
            ;;
        esac
    done
fi


# 用户名
#if [[ -z $naive_user ]]; then
#    random=$(openssl rand -hex 8)
#    while :; do
#        echo
#        echo -e "请输入 ${magenta}用户名${none} Input your username"
#        read -p "$(echo -e "(默认: ${cyan}${random}$none):") " naive_user
#        [ -z "$naive_user" ] && naive_user=$random
#        echo
#        echo
#        echo -e "$yellow 你的用户名Username = $cyan$naive_user$none"
#        echo "----------------------------------------------------------------"
#        break
#    done
#fi


# 密码
#if [[ -z $naive_pass ]]; then
#    random=$(openssl rand -hex 8)
#    while :; do
#        echo
#        echo -e "请输入 ${magenta}密码${none} Input your password"
#        read -p "$(echo -e "(默认: ${cyan}${random}$none):") " naive_pass
#        [ -z "$naive_pass" ] && naive_pass=$random
#        echo
#        echo
#        echo -e "$yellow 你的密码Password = $cyan$naive_pass$none"
#        echo "----------------------------------------------------------------"
#        break
#    done
#fi

# 伪装网址
if [[ -z $naive_fakeweb ]]; then
    while :; do
        echo
        echo -e "请输入一个 ${magenta}正确的域名作为伪装网址${none} Input your domain"
        read -p "(例如: bing.com): " naive_fakeweb
        [ -z "$naive_fakeweb" ] && error && continue
        echo
        echo
        echo -e "$yellow 你的伪装网址 = $cyan$naive_fakeweb$none"
        echo "----------------------------------------------------------------"
        break
    done
fi


# 修改Caddyfile
echo
echo -e "$yellow修改Caddyfile$none"
echo "----------------------------------------------------------------"


if [ ! -d /etc/caddy ]; then
  mkdir /etc/caddy
fi

if [ ! -f /etc/caddy/Caddyfile ]; then
  touch /etc/caddy/Caddyfile
  chmod +x /etc/caddy/Caddyfile
else 
  chmod +x /etc/caddy/Caddyfile
fi

begin_line=$(awk "/_naive_config_begin_/{print NR}" /etc/caddy/Caddyfile)
end_line=$(awk "/_naive_config_end_/{print NR}" /etc/caddy/Caddyfile)
if [[ -n $begin_line && -n $end_line ]]; then
  sed -i "${begin_line},${end_line}d" /etc/caddy/Caddyfile
fi

cat > /etc/caddy/Caddyfile << EOF
# _naive_config_begin_
{
	order forward_proxy before file_server
}
:443, ${naive_domain} {
	tls e16d9cb045d7@gmail.com #{
	#  alpn http/1.1 h2 h3
	# }
	route {
		forward_proxy {
			basic_auth ${naive_user} ${naive_pass}
			hide_ip
			hide_via
			probe_resistance
		}
		# 如果共存版则用file_server 
		# file_server {
		#   root /var/www/html
		# }
		# 如果单独版navie则用reverse_proxy 
		reverse_proxy ${naive_fakeweb} {
			header_up Host {upstream_hostport}
			#header_up  X-Forwarded-Host {host}
		}
	}
}
# _naive_config_end_
EOF

#/etc/systemd/system/
if [[ ! -f /etc/systemd/system/caddy.service ]]; then
cat > /etc/systemd/system/caddy.service << EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=caddy
Group=caddy
ExecStartPre=/bin/sh -c '/bin/chown -R caddy:caddy /etc/caddy/databases && /usr/bin/find /etc/caddy/databases -type f -exec chmod 600 {} \;'
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
ExecStop=/usr/bin/caddy stop
TimeoutStopSec=10s
Restart=on-failure
RestartSec=5s
PrivateTmp=true
LimitNOFILE=1048576
LimitNPROC=512
AmbientCapabilities=CAP_NET_BIND_SERVICE
Environment=HOME=/var/lib/caddy
Environment=XDG_DATA_HOME=/var/lib/caddy/.local/share
Environment=XDG_CONFIG_HOME=/var/lib/caddy/.config
Environment=CADDY_CLUSTERING=true

[Install]
WantedBy=multi-user.target
EOF
fi

chmod +x /etc/systemd/system/caddy.service

if ! getent group caddy >/dev/null; then
groupadd --system caddy
fi

if ! getent passwd caddy >/dev/null; then
useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy
fi

# 下载安装 Painted.zip 并设置权限
echo
echo -e "$yellow正在准备二维码$none"
echo "----------------------------------------------------------------"
cd /etc/caddy/
rm caddy_files.tar.xz
#wget https://github.com/simtelboy/forwardproxy/blob/naive/caddy_files.tar.xz
wget https://github.com/simtelboy/haogezhiming2/raw/main/caddy_files.tar.xz
tar -xf caddy_files.tar.xz
rm caddy_files.tar.xz

# 设置 /etc/caddy 目录权限
chown -R caddy:caddy /etc/caddy/
chmod +x /etc/caddy/
//sudo chmod -R 600 /etc/caddy/

# 启动NaïveProxy服务端(Caddy)
echo
echo -e "$yellow启动服务端 $none"
echo "----------------------------------------------------------------"

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy


# 输出参数
echo
echo -e "${yellow}配置参数${none}"
echo "----------------------------------------------------------------"
echo -e "域名Domain: ${naive_domain}"
echo -e "端口Port: ${naive_port}"
echo -e "用户名Username: ${naive_user}"
echo -e "密码Password: ${naive_pass}"

naive_url="https://$(echo -n \
"${naive_user}:${naive_pass}@${naive_domain}:${naive_port}" \
| base64 -w 0)"
echo -e "${cyan}${naive_url}${none}"
echo "以下两个二维码完全一样的内容"
qrencode -t UTF8 $naive_url
qrencode -t ANSI $naive_url

echo "---------- END -------------"
echo "以上节点信息保存在 ~/_naive_url_ 中"

echo $naive_url > ~/_naive_url_
echo "以下两个二维码完全一样的内容" >> ~/_naive_url_
qrencode -t UTF8 $naive_url >> ~/_naive_url_
qrencode -t ANSI $naive_url >> ~/_naive_url_

echo
echo "----------------------------------------------------------------"
# 定义框的宽度
width=60

# 画顶部边框
_yellow "╭$(printf "%0.s─" $(seq 1 $width))╮"

# 画空行
_yellow "$(printf "%${width}s" "")"

# 画内容行
_yellow "  $(printf "%-${width}s" "你务必登录以下网址")"
_yellow "  $(printf "%-${width}s" "添加用户才能正常运行:")"
_yellow "  $(printf "%-${width}s" "管理员: 	https://${naive_domain}/admin/login")"
_yellow "  $(printf "%-${width}s" "超级管理员：  https://${naive_domain}/admin/rootlogin")"

# 画空行
_yellow "$(printf "%${width}s" "")"

# 画底部边框
_yellow "╰$(printf "%0.s─" $(seq 1 $width))╯"
echo -e "${green}安装完成！${none}"
}

# 升级Caddy
upgrade_caddy() {
    pause
    echo -e "${yellow}开始检查版本...${none}"

    local_version=$(get_local_caddy_version)
    latest_version=$(get_latest_caddy_version)

    echo -e "本地版本: ${cyan}$local_version${none}"
    echo -e "服务器最新版本: ${cyan}$latest_version${none}"

    comparison_result=$(compare_versions "$local_version" "$latest_version")

    if [[ "$comparison_result" == "1" ]]; then
        echo -e "${yellow}发现新版本，开始升级...${none}"
        service caddy stop
        cd /tmp
        rm -f caddy
        wget https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy
        cp caddy /usr/bin/
        chmod +x /usr/bin/caddy
        systemctl daemon-reload
        systemctl start caddy
        echo -e "${green} 升级完成！${none}"
    else
        echo -e "${green}当前版本为最新，无需升级。${none}"
        echo -e "${yellow}是否强制重新安装最新版本？${none}"
        read -p "$(echo -e "输入 ${cyan}y${none} 强制升级，${cyan}n${none} 退出 [y/n]: ")" force_upgrade
        if [[ "$force_upgrade" == "y" || "$force_upgrade" == "Y" ]]; then
            echo -e "${yellow}开始强制升级...${none}"
            service caddy stop
            cd /tmp
            rm -f caddy
            wget https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy
            cp caddy /usr/bin/
            chmod +x /usr/bin/caddy
            systemctl daemon-reload
            systemctl start caddy
            echo -e "${green} 强制升级完成！${none}"
        else
            echo -e "${yellow}取消升级，返回菜单。${none}"
        fi
    fi
}


# 升级Caddy和caddy_files
upgrade_caddy_and_files() {
    pause
    echo -e "${yellow}开始检查版本...${none}"

    local_version=$(get_local_caddy_version)
    latest_version=$(get_latest_caddy_version)

    echo -e "本地版本: ${cyan}$local_version${none}"
    echo -e "服务器最新版本: ${cyan}$latest_version${none}"

    comparison_result=$(compare_versions "$local_version" "$latest_version")

    if [[ "$comparison_result" == "1" ]]; then
        echo -e "${yellow}发现新版本，开始升级...${none}"
        service caddy stop
        cd /tmp
        rm -f caddy
        wget https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy
        cp caddy /usr/bin/
        chmod +x /usr/bin/caddy
        systemctl daemon-reload
        systemctl start caddy
        echo -e "${green}升级完成！${none}"
    else
        echo -e "${green}当前版本为最新，无需升级。${none}"
        echo -e "${yellow}是否强制重新安装最新版本？${none}"
        read -p "$(echo -e "输入 ${cyan}y${none} 强制升级，${cyan}n${none} 退出 [y/n]: ")" force_upgrade
        if [[ "$force_upgrade" == "y" || "$force_upgrade" == "Y" ]]; then
            echo -e "${yellow}开始强制升级...${none}"
            service caddy stop
            cd /tmp
            rm -f caddy
            wget https://github.com/simtelboy/HaoGeZhiMing/releases/latest/download/caddy
            cp caddy /usr/bin/
            chmod +x /usr/bin/caddy
            systemctl daemon-reload
            systemctl start caddy
            echo -e "${green} 强制升级完成！${none}"
        else
            echo -e "${yellow}取消升级，返回菜单。${none}"
        fi
    fi

    # 无论Caddy是否需要更新，caddy_files都会更新
    echo -e "${yellow}开始更新管理网页文件...${none}"
    cd /etc/caddy/
    rm -f caddy_files.tar.xz
    wget https://github.com/simtelboy/haogezhiming2/raw/main/caddy_files.tar.xz
    tar -xf caddy_files.tar.xz
    rm caddy_files.tar.xz

    chown -R caddy:caddy /etc/caddy/
    chmod +x /etc/caddy/

    echo -e "${green}管理网页文件更新完成！${none}"
}

# 卸载所有
uninstall_all() {
    pause
    echo -e "${yellow}开始卸载相关文件...${none}"
    service caddy stop || true
    systemctl disable caddy || true
    sudo userdel caddy || true
    sudo groupdel caddy || true
    rm -rf /etc/caddy || true
    rm -f /etc/systemd/system/caddy.service || true
    rm -f /usr/bin/caddy || true
    rm -f /etc/apt/sources.list.d/caddy-stable.list || true
    apt remove -y caddy || true
    systemctl daemon-reload
    echo -e "${green}卸载已完成！${none}"
}

# 主逻辑在
while true; do
    show_menu
    case $choice in
        1)
            install_caddy
            ;;
        2)
            upgrade_caddy
            ;;
        3)
            upgrade_caddy_and_files
            ;;
        4)
            uninstall_all
            ;;
	5)
            check_caddy_status
            ;;
	6)
            echo -e "${yellow}退出脚本...${none}"
            exit 0
            ;;
        *)
            error
            ;;
    esac
    pause
done




