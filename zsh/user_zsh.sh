#!/bin/bash

# 检查用户和环境
check_user() {
    # 获取所有普通用户
    USERS=$(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd)
    
    # 检查是否为root
    if [ "$(id -u)" != "0" ]; then
        echo "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# 为指定用户安装
install_for_user() {
    local USER=$1
    local USER_HOME=$(eval echo ~$USER)
    
    echo "正在为用户 $USER 安装配置..."
    
    # 创建用户目录
    mkdir -p "$USER_HOME"
    chown -R $USER:$USER "$USER_HOME"
    
    # 以用户身份执行安装
    su - $USER -c "
        export HOME=$USER_HOME
        # 安装oh-my-zsh
        sh -c \"\$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)\" \"\" --unattended
        
        # 安装主题和插件
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git $USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k
        git clone https://gitee.com/mirrors/zsh-autosuggestions.git $USER_HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        git clone https://gitee.com/mirrors/zsh-syntax-highlighting.git $USER_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        
        # 配置.zshrc
        cp $USER_HOME/.zshrc $USER_HOME/.zshrc.bak
        sed -i 's/plugins=(git)/plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)/g' $USER_HOME/.zshrc
        sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $USER_HOME/.zshrc
    "
    
    # 设置默认shell
    chsh -s $(which zsh) $USER
}

# 安装系统依赖
install_deps() {
    apt update
    apt install -y zsh git curl wget fontconfig autojump
}

# 主函数
main() {
    check_user
    install_deps
    
    # 为每个用户安装
    for user in $USERS; do
        echo "===================="
        echo "正在为用户 $user 安装..."
        install_for_user "$user"
        echo "用户 $user 安装完成"
        echo "===================="
    done
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >>! ~/.zshrc
    
    echo "所有用户安装完成！"
    echo "用户需要重新登录以使用新的shell"
}

main