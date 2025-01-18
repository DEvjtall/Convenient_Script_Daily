#!/bin/bash

# 检查是否为root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# 安装依赖
install_deps() {
    apt update
    apt install -y zsh git curl wget fontconfig autojump
}

# 安装oh-my-zsh
install_zsh() {
    echo "正在为root用户安装zsh配置..."
    
    # 清理现有安装
    rm -rf /root/.oh-my-zsh
    rm -f /root/.zshrc*
    
    # 安装oh-my-zsh
    sh -c "$(curl -fsSL https://gitee.com/pocmon/ohmyzsh/raw/master/tools/install.sh)" "" --unattended
    
    # 安装主题和插件
    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k
    git clone https://gitee.com/mirrors/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://gitee.com/mirrors/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    
    # 配置.zshrc
    cp /root/.zshrc /root/.zshrc.bak
    sed -i 's/plugins=(git)/plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting)/g' /root/.zshrc
    sed -i 's/ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' /root/.zshrc
    echo 'POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> /root/.zshrc
    
    # 设置默认shell
    chsh -s $(which zsh)
}

# 主函数
main() {
    check_root
    install_deps
    install_zsh
    
    echo "===================="
    echo "root用户zsh安装完成！"
    echo "请重新登录以使用新shell"
    echo "===================="
}

main