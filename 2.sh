sleep 1

echo -e "ｈ\nｈ\nｈｈｈｈ　　　ａａａａ　　　　ｏｏｏ　　　　　　　　　　　　　　　　　ｇｇｇｇ　　　ｅｅｅ\nｈ　　　ｈ　　　　　　ａ　　ｏ　　　ｏ　　　　　　　　　　　　　　　ｇ　　　ｇ　　ｅ　　　ｅ\nｈ　　　ｈ　　　　　　ａ　　ｏ　　　ｏ　　　　　　　　　　　　　　　ｇ　　　ｇ　　ｅ　　　ｅ\nｈ　　　ｈ　　　ａａａａ　　ｏ　　　ｏ　　　　　　　　　　　　　　　ｇ　　　ｇ　　ｅｅｅｅｅ\nｈ　　　ｈ　　ａ　　　ａ　　ｏ　　　ｏ　　　　　　　　　　　　　　　　ｇｇｇｇ　　ｅ\nｈ　　　ｈ　　ａ　　　ａ　　ｏ　　　ｏ　　　　　　　　　　　　　　　　　　　ｇ　　ｅ　　　ｅ\nｈ　　　ｈ　　　ａａａａ　　　ｏｏｏ　　　　　　　　　　　　　　　　ｇ　　　ｇ　　　ｅｅｅ\n
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　ｇｇｇ\n"

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }


error() {
	 echo -e "\n$red 输入错误! $none\n"
}

pause() {
	read -rsp "$(echo -e "按 $green Enter 回车键 $none 继续....或按 $red Ctrl + C $none 取消.")" -d $'\n'
    	echo
}

#说明
echo
echo -e "$yellow此脚本仅兼容于Debian 10+系统. 如果你的系统不符合,请Ctrl+C退出脚本$none"
echo "本脚本支持带参数执行, 在参数中输入域名, 网络栈, 端口, 用户名, 密码.例:XXX.sh domain.com 4 443 haoge 1234 "
echo "----------------------------------------------------------------"


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
	*) 	#initial
		netstack="i"
		;;
	esac

	#第3个参数是 端口
	naive_port=${3}
	if [[ -z $naive_port ]]; then
		naive_port=443
	fi


	#第四个参数是 用户名
	naive_user=${4}
	if [[ -z $naive_user ]]; then
		naive_user=$(openssl rand -hex 8)
	fi


	#第五个参数是 密码
	naive_pass=${5}
	if [[ -z $naive_pass ]]; then
		#默认与用户名相等
		naive_pass=$naive_user
	fi

	echo -e "域名:${naive_domain}"
	echo -e "网域栈:${netstack}"
	echo -e "端口:${naive_port}"
	echo -e "用户名:${naive_user}"
	echo -e "密码:${naive_pass}"
fi


pause


# 准备
apt update
apt install -y sudo curl wget git jq qrencode


echo
echo -e "$yellow下载NaïveProxy作者编译的Caddy$none"
echo "----------------------------------------------------------------"
cd /tmp
rm caddy-forwardproxy-naive.tar.xz
rm -r caddy-forwardproxy-naive
wget https://github.com/klzgrad/forwardproxy/releases/download/v2.6.4-caddy2-naive/caddy-forwardproxy-naive.tar.xz
tar -xf caddy-forwardproxy-naive.tar.xz
cd caddy-forwardproxy-naive
./caddy version


# 替换caddy可执行文件
echo
echo -e "$yellow替换Caddy可执行文件$none"
echo "----------------------------------------------------------------"
service caddy stop
cp caddy /usr/bin/
chmod +x /usr/bin/caddy

# xkcd密码生成器页面
echo
echo -e "$yellow xkcd密码生成器页面 $none"
echo "----------------------------------------------------------------"
rm -r /var/www/xkcdpw-html
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
    echo -e "如果你的小鸡是${magenta}双栈(同时有IPv4和IPv6的IP)${none}，请选择你把Naive搭在哪个'网口'上"
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
if [[ -z $naive_user ]]; then
    random=$(openssl rand -hex 8)
    while :; do
        echo
        echo -e "请输入 ${magenta}用户名${none} Input your username"
        read -p "$(echo -e "(默认: ${cyan}${random}$none):") " naive_user
        [ -z "$naive_user" ] && naive_user=$random
        echo
        echo
        echo -e "$yellow 你的用户名Username = $cyan$naive_user$none"
        echo "----------------------------------------------------------------"
        break
    done
fi


# 密码
if [[ -z $naive_pass ]]; then
    random=$(openssl rand -hex 8)
    while :; do
        echo
        echo -e "请输入 ${magenta}密码${none} Input your password"
        read -p "$(echo -e "(默认: ${cyan}${random}$none):") " naive_pass
        [ -z "$naive_pass" ] && naive_pass=$random
        echo
        echo
        echo -e "$yellow 你的密码Password = $cyan$naive_pass$none"
        echo "----------------------------------------------------------------"
        break
    done
fi




# 修改Caddyfile
echo
echo -e "$yellow修改Caddyfile$none"
echo "----------------------------------------------------------------"


begin_line=$(awk "/_naive_config_begin_/{print NR}" /etc/caddy/Caddyfile)
end_line=$(awk "/_naive_config_end_/{print NR}" /etc/caddy/Caddyfile)
if [[ -n $begin_line && -n $end_line ]]; then
  sed -i "${begin_line},${end_line}d" /etc/caddy/Caddyfile
fi

sed -i "1i # _naive_config_begin_\n\
{\n\
  order forward_proxy before file_server\n\
}\n\
:${naive_port}, ${naive_domain} #你的域名\n\
tls e16d9cb045d7@gmail.com #你的邮箱\n\
route {\n\
 forward_proxy {\n\
   basic_auth ${naive_user} ${naive_pass} #用户名和密码\n\
   hide_ip\n\
   hide_via\n\
   probe_resistance\n\
  }\n\
#支持多用户,请入掉注释\n\
#forward_proxy {\n\
#  basic_auth haoge hao12345678 #用户名和密码\n\
#   hide_ip\n\
#   hide_via\n\
#   probe_resistance\n\
#  }\n\
 reverse_proxy  https://demo.cloudreve.org  { #伪装网址\n\
   header_up  Host  {upstream_hostport}\n\
   header_up  X-Forwarded-Host  {host}\n\
  }\n\
}\n\
# _naive_config_end_" /etc/caddy/Caddyfile


#/etc/systemd/system/
cat > /etc/systemd/system/caddy.service << EOF
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF


chmod +x /etc/systemd/system/caddy.service

groupadd --system caddy

useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

# 启动NaïveProxy服务端(Caddy)
echo
echo -e "$yellow启动NaïveProxy服务端(Caddy)$none"
echo "----------------------------------------------------------------"

systemctl daemon-reload
systemctl enable caddy
systemctl start caddy


# 输出参数
echo
echo -e "${yellow}NaïveProxy配置参数${none}"
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
echo "END"




