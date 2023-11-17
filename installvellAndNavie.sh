# 等待1秒, 避免curl下载脚本的打印与脚本本身的显示冲突, 吃掉了提示用户按回车继续的信息
clear
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

# 说明
echo
echo -e "$yellow此脚本仅兼容于Debian 10+系统. 如果你的系统不符合,请Ctrl+C退出脚本$none"
echo -e "本脚本开头有详尽注,查看脚本整体思路和关键命令, 以便针对你自己的系统做出调整."
echo "本脚本不支持带参数执行"
echo "----------------------------------------------------------------"


invalid_choice=true

while $invalid_choice; do
    echo "请选择一个选项："
    echo "1. 只安装v2ray+vless"
    echo "2. 只安装naive"
    echo "3. 安装v2ray与naive共存版"

    read choice

    case $choice in
        1)
            echo "只安装v2ray+vless"
            apt update
            apt install -y curl
            bash <(curl -L https://github.com/simtelboy/v2ray_wss/blob/main/install.sh)
            invalid_choice=false
            ;;
        2)
            echo "只安装naive"
            	apt update
            	apt install -y curl
            	bash <(curl -L https://github.com/simtelboy/haogezhiming2/raw/main/2.sh)
            invalid_choice=false
            ;;
        3)
            echo "安装v2ray与naive共存版"
            apt update
            apt install -y curl
            bash <(curl -L https://github.com/simtelboy/v2ray_wss/blob/main/install.sh)
            bash <(curl -L https://github.com/simtelboy/haogezhiming2/raw/main/2.sh)
            invalid_choice=false
            ;;
        *)
            echo "无效的选择，请重新选择"
            ;;
    esac
done