#!/bin/bash

# 使用ANSI转义序列设置绿色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'  # 用于重置颜色

echo -e " AUTHOR:                                                                                                                          
${YELLOW}                                                                                                                           
VVVVVVVV           VVVVVVVV                                                    LLLLLLLLLLL                                 
V::::::V           V::::::V                                                    L:::::::::L                                 
V::::::V           V::::::V                                                    L:::::::::L                                 
V::::::V           V::::::V                                                    LL:::::::LL                                 
 V:::::V           V:::::V  ssssssssss       cccccccccccccccc    eeeeeeeeeeee    L:::::L                   eeeeeeeeeeee    
  V:::::V         V:::::V ss::::::::::s    cc:::::::::::::::c  ee::::::::::::ee  L:::::L                 ee::::::::::::ee  
   V:::::V       V:::::Vss:::::::::::::s  c:::::::::::::::::c e::::::eeeee:::::eeL:::::L                e::::::eeeee:::::ee
    V:::::V     V:::::V s::::::ssss:::::sc:::::::cccccc:::::ce::::::e     e:::::eL:::::L               e::::::e     e:::::e
     V:::::V   V:::::V   s:::::s  ssssss c::::::c     ccccccce:::::::eeeee::::::eL:::::L               e:::::::eeeee::::::e
      V:::::V V:::::V      s::::::s      c:::::c             e:::::::::::::::::e L:::::L               e:::::::::::::::::e 
       V:::::V:::::V          s::::::s   c:::::c             e::::::eeeeeeeeeee  L:::::L               e::::::eeeeeeeeeee  
        V:::::::::V     ssssss   s:::::s c::::::c     ccccccce:::::::e           L:::::L         LLLLLLe:::::::e           
         V:::::::V      s:::::ssss::::::sc:::::::cccccc:::::ce::::::::e        LL:::::::LLLLLLLLL:::::Le::::::::e          
          V:::::V       s::::::::::::::s  c:::::::::::::::::c e::::::::eeeeeeeeL::::::::::::::::::::::L e::::::::eeeeeeee  
           V:::V         s:::::::::::ss    cc:::::::::::::::c  ee:::::::::::::eL::::::::::::::::::::::L  ee:::::::::::::e  
            VVV           sssssssssss        cccccccccccccccc    eeeeeeeeeeeeeeLLLLLLLLLLLLLLLLLLLLLLLL    eeeeeeeeeeeeee  
                                                                                                                           
                                                                                                                        ${NC}   
                                                                                                                           
                                                                                                                                                                                                                                                  "
echo -e "**************${GREEN}此安装会帮你把安装Kubernetes前期系统设置完成，然后安装k8s${NC}**************\\n"
echo -e "**********************${GREEN}本脚本借助了KubeKey开源安装工具下载Kubernetes${NC}**********************\\n"
echo -e "${GREEN}本安装脚本仅支持对Ubuntu 18.04版本及以上的系统安装kubernetes集群使用，仅供参考和学习使用${NC}\\n"
echo -e "***********************${RED}本脚本执行前需要对k8s集群机器进行自己命名${NC}***********************\\n"
echo -e "**************************${YELLOW}本次安装时间大约十到二十分钟，这取决于您的网速${NC}**************************\\n"
read -p "如果你对上面都没有疑问的话，下面，让我们开始安装吧！（输入y表示开始安装，输入n退出脚本）" choice

if [ $choice == "y" ]; then
    echo ".现在开始执行脚本安装."
elif [ $choice == "n" ]; then
    echo "你已取消安装脚本,现在退出脚本"
    exit 0
fi




# 这里编写一个动态时针的函数
show_dynamic_clock(){
    local clock="/-\|"
    local lock_file="/tmp/install_lock" # 定义一个用于进程之间临时通信的临时文件为锁文件
    touch $lock_file # 创建锁文件
    exec 9<>$lock_file # 以读写的方式打开文件描述符9关联到锁文件
    flock 9 # 获取文件锁

    local i=0 
    while true ;do
        local index=$(( i % 4 )) # 根据当前秒数来获取动态时钟的索引，每秒都更新索引
        echo -ne "\r[${clock:$index:1}]"
        if [ -f "$lock_file.release" ];then # 如果有这个标志着任务完成的文件，就停止时钟循环
            break
        fi
        ((i++))
        sleep 0.5
    done
    echo -ne "\r[✔]"
    flock -u 9 # 释放锁文件
    exec 9>&- # 关闭文件描述符9
    rm -f $lock_file $lock_file.release # 删除文件和任务完成的标志文件
}

# 添加 apt 镜像源
{
    
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cat >> /etc/apt/sources.list << EOF
    deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
EOF
    apt-get update &>/dev/null
    
}


{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "安装k8s前期依赖" 
    apt-get install -y curl socat conntrack ebtables ipset ipvsadm &>/dev/null
    touch "/tmp/install_lock.release" 
    wait $pid
    sleep 1
} 


{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "关闭防火墙"
    systemctl stop ufw &>/dev/null
    systemctl disable ufw &>/dev/null
    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
} 



{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "设置服务器的时间同步"
    sudo apt install ntpdate &>/dev/null
    sudo ntpdate -u ntp.aliyun.com &>/dev/null
    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
} 

sleep 1

{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "设置中国时间" 
    sudo timedatectl set-timezone Asia/Shanghai &>/dev/null
    touch "/tmp/install_lock.release"
    pid=$! # 获取安装运行的PID
    wait $pid
    sleep 1
}

{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "查看当前时间"
    date | while read line; do echo -e "${YELLOW}$line${NC}"; done
    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
}


{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "允许root用户ssh远程登录"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak 
    sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
    sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config
    sudo service ssh restart

    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
}


{
    show_dynamic_clock
    pid=$! # 获取时钟运行的PID
    echo "关闭ubuntu的虚拟内存"
    sudo sed -i 's/^\([^\#].*swap.*\)/#\1/' /etc/fstab &>/dev/null

    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
} 


# 等待一下不然等下版本输出乱序
wait




# 判断是否是master节点，如果是master节点才执行下面操作
node=$(hostname)
if [[ "$node" == *master* ]]; then

# 安装KubeKey
{
    mkdir ~/kubekey
    cd ~/kubekey/
    show_dynamic_clock 15
    echo "安装KubeKey开源集群安装工具"
    # 选择中文区下载(访问 GitHub 受限时使用)
    export KKZONE=cn
    curl -sfL https://get-kk.kubesphere.io | sh -
}

    echo "现在开始使用kubekey安装k8s"
    cd /root/kubekey

    echo "查看可安装的k8s版本"
    # 输出表头
    printf "| %-5s | %-10s |\n" "序号" "版本号"
    printf "|-------|------------|\n"
    k8s_versions="v1.19.0 v1.19.8 v1.19.9 v1.19.15 v1.20.4 v1.20.6 v1.20.10 v1.21.0 v1.21.1 v1.21.2 v1.21.3 v1.21.4 v1.21.5 v1.21.6 v1.21.7 v1.21.8 v1.21.9 v1.21.10 v1.21.11 v1.21.12 v1.21.13 v1.21.14 v1.22.0 v1.22.1 v1.22.2 v1.22.3 v1.22.4 v1.22.5 v1.22.6 v1.22.7 v1.22.8 v1.22.9 v1.22.10 v1.22.11 v1.22.12 v1.22.13 v1.22.14 v1.22.15 v1.22.16 v1.22.17 v1.23.0 v1.23.1 v1.23.2 v1.23.3 v1.23.4 v1.23.5 v1.23.6 v1.23.7 v1.23.8 v1.23.9 v1.23.10 v1.23.11 v1.23.12 v1.23.13 v1.23.14 v1.23.15 v1.23.16 v1.23.17 v1.24.0 v1.24.1 v1.24.2 v1.24.3 v1.24.4 v1.24.5 v1.24.6 v1.24.7 v1.24.8 v1.24.9 v1.24.10 v1.24.11 v1.24.12 v1.24.13 v1.24.14 v1.24.15 v1.24.16 v1.24.17 v1.25.0 v1.25.1 v1.25.2 v1.25.3 v1.25.4 v1.25.5 v1.25.6 v1.25.7 v1.25.8 v1.25.9 v1.25.10 v1.25.11 v1.25.12 v1.25.13 v1.25.14 v1.25.15 v1.25.16 v1.26.0 v1.26.1 v1.26.2 v1.26.3 v1.26.4 v1.26.5 v1.26.6 v1.26.7 v1.26.8 v1.26.9 v1.26.10 v1.26.11 v1.26.12 v1.26.13 v1.26.14 v1.26.15 v1.27.0 v1.27.1 v1.27.2 v1.27.3 v1.27.4 v1.27.5 v1.27.6 v1.27.7 v1.27.8 v1.27.9 v1.27.10 v1.27.11 v1.27.12 v1.27.13 v1.27.14 v1.27.15 v1.27.16 v1.28.0 v1.28.1 v1.28.2 v1.28.3 v1.28.4 v1.28.5 v1.28.6 v1.28.7 v1.28.8 v1.28.9 v1.28.10 v1.28.11 v1.28.12 v1.28.13 v1.28.14 v1.28.15 v1.29.0 v1.29.1 v1.29.2 v1.29.3 v1.29.4 v1.29.5 v1.29.6 v1.29.7 v1.29.8 v1.29.9 v1.29.10 v1.30.0 v1.30.1 v1.30.2 v1.30.3 v1.30.4 v1.30.5 v1.30.6 v1.31.0 v1.31.1 v1.31.2"
    #echo "$k8s_versions"

    # 将获取到的版本信息按行分割成数组
    IFS=' ' read -r -a version_array <<< "$k8s_versions"
    #echo "当前IFS的值为: $IFS"

    if [ ${#version_array[@]} -eq 0 ]; then
        echo "版本数组没有填充完毕，请检查输出格式"
        exit 1
    fi

    # 这里也等待一下
    wait

    # 输出可供选择的版本信息，并添加序号
    echo "可安装的K8S版本："
    for ((i=0; i < ${#version_array[@]}; i++));do
        printf "| %-5d | %-10s |\n" $((i + 1)) "${version_array[i]}"
    done

    # 获取安装者选择的版本序号
    read -p "请输入你要选择版本的序号：" choice

    # 根据用户选择的序号确定要安装的版本
    selected_verison=${version_array[$((choice-1))]}

    file_name=k8s-${version_array[$((choice-1))]}.yaml
    
    # 生成用户选择版本的k8s安装yaml文件
    ./kk create config -f $file_name --with-kubernetes $selected_verison

    echo "这是根据选择版本产生的yaml文件：$file_name"

    # 下面进行改写生成的shell脚本
    yaml_content=$(cat $file_name)
    #echo "$yaml_content"


    # 显示当前部分的hosts信息
    display_hosts_info(){
        echo "当前hosts的信息："
        # 这里awk范围匹配语法后面别忘记闭合
        echo "$yaml_content" | awk '/hosts:/,/roleGroups:/' | grep -v "roleGroups:"
    }

    # 显示rolesGroups里面的信息
    display_roleGroups_info(){
        echo "当前roleGroups的信息："
        echo "$yaml_content" | awk '/roleGroups:/,/controlPlaneEndpoint:/'  | grep -v "controlPlaneEndpoint:"
    }

    # 添加hosts
    add_host(){
        read -p "请输入输入新的主机名字:" host_name
        read -p "请输入新的地址：" new_address
        read -p "请输入新的内部地址：" new_internal_address
        read -p "请输入SSH连接的用户名：(默认输入为root)" new_user
        read -p "请输入SSH连接的密码：" new_passwd

        new_host_entry="{name: $host_name, address: $new_address, internalAddress: $new_internal_address, user: $new_user, password: \"$new_passwd\"}"

        yaml_content=$(echo "$yaml_content" | sed "s/hosts:/hosts:\n  - $new_host_entry/")

        echo "新主机已添加到hosts部分。"
    }


    # 修改hosts部分
    modify_hosts(){
        new_user=root
        display_hosts_info
        read -p "请输入要修改的主机名字：（用于定位修改行）" target_name
        read -p "请输入输入新的主机名字:" host_name
        read -p "请输入新的地址：" new_address
        read -p "请输入新的内部地址：" new_internal_address
        read -p "请输入SSH连接的用户名：(默认输入为root)" new_user
        read -p "请输入SSH连接的密码：" new_passwd

        # 构建新主机的信息行
        #new_host_entry="{name: $host_name, address: $new_address, internalAddress: $new_internal_address , user: $new_user, password: \"$new_passwd\"}"

        # 用sed替换指定的主机信息
        # shellcheck disable=SC2001
        yaml_content=$(echo "$yaml_content" | sed -E "s/\{name: $target_name, address: [^,]+, internalAddress: [^,]+, user: [^,]+, password: \"[^\"]*\"\}/{name: $host_name, address: $new_address, internalAddress: $new_internal_address, user: $new_user, password: \"$new_passwd\"}/")

        echo "主机信息已经修改"

    }

    display_total_yaml(){
        echo "$yaml_content"
    }

    modify_pod_cidr(){
        read -p "输入你想替换的PodCIDR的值（格式例如10.2.0.0/18）：" new_value
        yaml_content=$(echo "$yaml_content" | sed "s#kubePodsCIDR:[^\\n]*$#kubePodsCIDR: $new_value#")
        echo -e -n "\e[1;32mPodCIDR替换成功！\e[0m"
        echo "当前PodCIDR的值为："
        echo "$yaml_content" | grep kubePodsCIDR
    }

    modify_svc_cidr(){
        read -p "输入你想替换的ServiceCIDR的值（格式例如10.1.0.0/18）：" new_value
        yaml_content=$(echo "$yaml_content" | sed "s#kubeServiceCIDR:[^\\n]*$#kubeServiceCIDR: $new_value#")
        echo -e -n "\e[1;32mPodCIDR替换成功！\e[0m"
        echo "当前ServiceCIDR的值为："
        echo "$yaml_content" | grep kubeServiceCIDR
    }
    manual_yaml(){
        while true;do
            vi $file_name
            read -p "是否继续编辑文件（y/n）" choice
            if [ "$choice" != "y" ];then
                break
            fi
        done

    }


    main_menu(){
        echo "请选择操作："
        echo "1. 显示当前hosts部分信息"
        echo "2. 显示当前roleGroups部分信息"
        echo "3. 添加新主机到hosts部分"
        echo "4. 修改hosts部分"
        echo "5. 查看整个yaml文件"
        echo "6. 修改kubePodsCIDR-IP"
        echo "7. 修改kubeServiceCIDR-IP"
        echo "8. 手动修改生成的yaml文件"

        echo "9. 退出(yaml编写完毕开始执行安装)"

    read -p "请输入你的选择：" choice

    case $choice in
        1)
            display_hosts_info
            main_menu
            ;;
        2)
            display_roleGroups_info
            main_menu
            ;;
        3)
            add_host
            echo "$yaml_content" > $file_name
            main_menu
            ;;
        4)
            modify_hosts
            echo "$yaml_content" > $file_name
            main_menu
            ;;
        5) 
            display_total_yaml
            main_menu
            ;;

        6) 
            modify_pod_cidr
            echo "$yaml_content" > $file_name
            main_menu
            ;;
        7) 
            modify_svc_cidr
            echo "$yaml_content" > $file_name
            main_menu
            ;;
        8) 
            manual_yaml
            yaml_content=$(cat $file_name)
            echo -e "
            ${GREEN}修改后的yaml文件如下${NC}
            $yaml_content
            "
            main_menu
            ;;
        9)
            echo "yaml文件已经修改完毕，下面进行Kubekey的安装步骤"
            ./kk create cluster -f $file_name 2>&1 | tee install_log.txt
            if [ $? -eq 0 ];then
                echo ""
            else 
                echo  -e  "$YELLOW 你的yaml修改之后的格式有问题的，请重新修改！ $NC"
                main_menu
            fi
            ;;
        *)
            echo "无效的选择，请重新输入。"
            main_menu
            ;;
    esac
}

main_menu

wait 

echo -e "Kubernetes已经安装完毕啦！输入${GREEN}kubectl get node${NC}查看节点状态吧！(得等上两三分钟节点才会READY状态)"
sleep 4;



{
    show_dynamic_clock &
    pid=$!
    echo "现在为你添加kubectl的命令补全"
    apt install bash-completion -y
    source /usr/share/bash-completion/bash_completion
    source <(kubectl completion bash)
    kubectl completion bash >/etc/bash_completion.d/kubectl
    echo '# Enable bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
   . /usr/share/bash-completion/bash_completion
fi

# Enable kubectl completion
if [ -f /etc/bash_completion.d/kubectl ]; then
   . /etc/bash_completion.d/kubectl
fi' >> ~/.bashrc
    source ~/.bashrc

    touch "/tmp/install_lock.release"
    wait $pid
    sleep 1
}

echo -e "${YELLOW}替换镜像源的命令如下请为其他节点替换，本机以自动替换镜像源！${NC}"
read -p "现在帮你更换docker/daemon.json文件，输入y替换(默认帮你备份)，n不替换：" choice
    if [ choice == 'y' ];then
        mkdir -p /etc/docker > /dev/null
        touch /etc/docker/daemon.json
        cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        rm /etc/docker/daemon.json
        cp ./daemon.json /etc/docker/
    fi
echo "感谢使用我的脚本，我是vscle，我们下次见！
完结撒花！
"

echo -e "
.##..##...####...#####...#####...##..##..........######..##..##..#####...######..##..##...####..
.##..##..##..##..##..##..##..##...####...........##......###.##..##..##....##....###.##..##.....
.######..######..#####...#####.....##............####....##.###..##..##....##....##.###..##.###.
.##..##..##..##..##......##........##............##......##..##..##..##....##....##..##..##..##.
.##..##..##..##..##......##........##............######..##..##..#####...######..##..##...####..
................................................................................................
"

else
    read -p "现在帮你更换docker/daemon.json文件，输入y替换(默认帮你备份)，n不替换：" choice
    if [ choice == 'y' ];then
        mkdir -p /etc/docker > /dev/null
        touch /etc/docker/daemon.json
        cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        rm /etc/docker/daemon.json
        cp ./daemon.json /etc/docker/
    fi
    echo "该节点不是master节点，上面初始化系统操作已经完成，退出脚本！"
    exit 0
fi
