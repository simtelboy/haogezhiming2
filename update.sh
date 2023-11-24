# bash <(curl -L https://raw.githubusercontent.com/simtelboy/haogezhiming2/main/update.sh)

sleep 1

echo -e " _\n| |      \n| |__  _____  ___      ____ _____ \n|  _ \(____ |/ _ \    / _  | ___ |\n| | | / ___ | |_| |  ( (_| | ____|\n|_| |_\_____|\___/    \___ |_____)\n                     (_____|\n"

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
echo "本脚本为更新naive版本"
echo "----------------------------------------------------------------"


pause


# 准备
apt update
apt install -y sudo curl wget git jq qrencode


echo -e "$yellow下载NaïveProxy作者编译的Caddy$none"
echo "----------------------------------------------------------------"
cd /tmp
rm caddy-forwardproxy-naive.tar.xz
rm -r caddy-forwardproxy-naive
wget https://github.com/klzgrad/forwardproxy/releases/latest/download/caddy-forwardproxy-naive.tar.xz
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

# 启动NaïveProxy服务端(Caddy)
echo
echo -e "$yellow启动NaïveProxy服务端(Caddy)$none"
echo "----------------------------------------------------------------"

systemctl start caddy

pause

systemctl status caddy
