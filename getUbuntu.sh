#!/bin/bash

###############################################################
## GLOBALS
###############################################################
SELF_NAME=`basename $0`
SELF_PATH=`dirname $0`/${SELF_NAME}
CROUTON_PATH=`dirname $0`/crouton
PYCHARM_PATH=/usr/local/bin/pycharm
PHPSTORM_PATH=/usr/local/bin/phpstorm
INODE_NUM=`ls -id / | awk '{print $1}'`
ROBO_MONGO_PATH=/usr/local/bin/robomongo
BOOTSTRAP_PATH=`dirname $0`/bionic.tar.bz2
DOWNLOADS_PATH=/home/chronos/user/Downloads
CHROOT_PATH=/mnt/stateful_partition/crouton/chroots/bionic
TARGETS=cli-extra,xorg,xiwi,extension,keyboard,audio,chrome,xfce


###############################################################
## Helpers
###############################################################
title() {
    printf "\033[1;42m"
    printf '%*s\n'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' '
    printf '%*s'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf "\033[0m"
    printf "\n\n"
    sleep .5
}

breakLine() {
    printf "\n"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "\n\n"
}

askUser() {
    while true; do
        read -p " - $1 (y/n): " yn
        case ${yn} in
            [Yy]* ) echo 1; return 1;;
            [Nn]* ) echo 0; return 0;;
        esac
    done
}


###############################################################
## Installation
###############################################################
fetchCrouton() {

    # Move to the downloads folder, we'll work in here
    cd ${DOWNLOADS_PATH}

    if [ ! -f ${CROUTON_PATH} ]; then
        title "Fetching crouton..."
        curl "https://goo.gl/fd3zc" -L -o crouton
        breakLine
    fi
}

updateChroot() {

    # Move to the downloads folder, we'll work in here
    cd ${DOWNLOADS_PATH}

    # If no crouton file exists get it
    fetchCrouton

    title "Updating your chroot installation"
    sudo sh ${CROUTON_PATH} -n bionic -u
    breakLine
}

install() {

    # Move to the downloads folder, we'll work in here
    cd ${DOWNLOADS_PATH}

    # If no crouton file exists get it
    fetchCrouton

    # If no chroot is setup
    if [ ! -d ${CHROOT_PATH} ]; then
        # Prepare a bootstrap
        if [ ! -f ${BOOTSTRAP_PATH} ]; then
            title "Preparing an Ubuntu 18.04 bootstrap"
            sudo sh ${CROUTON_PATH} -d -f ${BOOTSTRAP_PATH} -r bionic -t ${TARGETS}
            breakLine
        fi

        # Setup Ubuntu
        title "Install Ubuntu 18.04 on ChromeOS"
        if [ "$(askUser "Install Ubuntu 18.04 LTS (bionic) with XFCE")" -eq 1 ]; then
            sudo sh ${CROUTON_PATH} -f ${BOOTSTRAP_PATH} -t ${TARGETS}
        fi
        breakLine
    fi

    # Launch Ubuntu & configure
    title "Mounting the chroot"

    # Get chroot username
    CHROOT_USERNAME=`ls ${CHROOT_PATH}/home/ | awk '{print $1}'`
    sudo enter-chroot -n bionic -l sh /home/${CHROOT_USERNAME}/Downloads/${SELF_NAME}
    breakLine
}

###############################################################
## Configuration
###############################################################
cPreRequisites() {
    title "Installing pre-requisites"
    sudo apt install -y software-properties-common python-software-properties
    breakLine
}

cRepositories() {
    title "Setting up required repositories"
    sudo add-apt-repository -y ppa:numix/ppa
    sudo add-apt-repository -y ppa:moka/daily
    sudo add-apt-repository -y ppa:docky-core/ppa
    sudo add-apt-repository -y ppa:gottcode/gcppa
    sudo apt install -y curl apt-transport-https ca-certificates
    
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

    curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    sudo apt update -y
    breakLine
}

cUi() {
    title "Preparing the UI/Apps"
    sudo apt dist-upgrade -y
    sudo apt install -y whoopsie language-pack-en-base nano mlocate htop preload inxi filezilla vlc bleachbit putty vim fish kiki xarchiver p7zip p7zip-rar

    sudo apt install -y numix-icon-theme-circle moka-icon-theme
    sudo apt install -y docky
    sudo apt install -y xfce4-whiskermenu-plugin
    
    cd /tmp
    wget "https://github.com/oguzhaninan/Stacer/releases/download/v1.0.8/Stacer_x64_v1.0.8.deb" -O stacer.deb
    sudo dpkg -i stacer.deb
    sudo rm stacer.deb
    
    sudo chown -R 1000:1000 "$HOME"

    if [ -f /usr/share/applications/kiki.desktop ]; then
        sudo sed -i "s/Icon=.*/Icon=regexxer/g" /usr/share/applications/kiki.desktop
    fi

    breakLine
}

cPhp() {
    title "PHP v7"
    if [ "$(askUser "Install PHP v7")" -eq 1 ]; then
        sudo apt install -y php php-pear
        php -v
        
        breakLine
        title "Composer"
        if [ "$(askUser "Install Composer for PHP")" -eq 1 ]; then
            sudo curl -sS "https://getcomposer.org/installer" | sudo php -- --install-dir=/usr/local/bin --filename=composer
        fi

        breakLine
        title "Swoole"
        if [ "$(askUser "Install Swoole PHP framework")" -eq 1 ]; then
            sudo pecl install swoole -y
        fi
    fi
    breakLine
}

cNodeJs() {
    title "NodeJS v9.0 Environment"
    if [ "$(askUser "Install NodeJS v9.0 environment")" -eq 1 ]; then
        curl -sL "https://deb.nodesource.com/setup_9.x" | sudo -E bash -
        sudo apt install -y build-essential nodejs
        
        sudo npm install -y webpack -g
        sudo npm install -y nodemon -g
        sudo npm install -y gulp -g
        sudo npm install -y bower -g
        sudo npm install -y browserify -g

        breakLine
        title "Bower"
        if [ "$(askUser "Install Bower")" -eq 1 ]; then
            
        fi
        
        breakLine
        title "Vue CLI"
        if [ "$(askUser "Install Vue CLI SDK")" -eq 1 ]; then
            sudo npm install -y vue-cli -g
        fi

        breakLine
        title "React Native"
        if [ "$(askUser "Install React/Native SDKs")" -eq 1 ]; then
            sudo npm install -y create-react-app create-react-native-app -g
        fi

        breakLine
        title "AngularJS Framework"
        if [ "$(askUser "Install the Angular CLI, Service Worker & PWA tools framework")" -eq 1 ]; then
            sudo npm install -y @angular/cli @angular/service-worker ng-pwa-tools -g
        fi
    fi
    breakLine
}

cGit() {
    title "Git"
    if [ "$(askUser "Install Git VCS")" -eq 1 ]; then
        sudo apt install -y git
    fi
    breakLine
}

cDocker() {
    title "Docker"
    if [ "$(askUser "Install Docker")" -eq 1 ]; then
        sudo apt install -y docker-ce
    fi
    breakLine
}

cMySqlWorkbench() {
    title "MySQL Workbench"
    if [ "$(askUser "Install MySQL Workbench")" -eq 1 ]; then
        sudo apt install -y mysql-workbench
    fi
    breakLine
}

cMongoDb() {
    title "MongoDB"
    if [ "$(askUser "Install MongoDB server")" -eq 1 ]; then
        sudo apt install -y mongodb mongo-tools mongodb-server

        breakLine
        title "RoboMongo (Robo3T)"
        if [ "$(askUser "Install RoboMongo database manager")" -eq 1 ]; then
            sudo apt install -y xcb
            cd /tmp
            wget "https://download.robomongo.org/1.2.1/linux/robo3t-1.2.1-linux-x86_64-3e50a65.tar.gz" -O robomongo.tar.gz

            if [ -d ${ROBO_MONGO_PATH} ]; then
                sudo rm -rf ${ROBO_MONGO_PATH}
            fi

            sudo mkdir ${ROBO_MONGO_PATH}
            sudo tar xf robomongo.tar.gz
            sudo rm robomongo.tar.gz
            sudo mv robo3t-*/* ${ROBO_MONGO_PATH}
            sudo rm -rf robo3t-*/
            sudo rm ${ROBO_MONGO_PATH}/lib/libstdc++*
            sudo chmod +x ${ROBO_MONGO_PATH}/bin/robo3t

            local ROBO_MONGO_LAUNCHER_PATH=/usr/share/applications/robomongo.desktop

            if [ ! -f ${ROBO_MONGO_LAUNCHER_PATH} ]; then
                sudo touch ${ROBO_MONGO_LAUNCHER_PATH}
            fi

            sudo truncate --size 0 ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "[Desktop Entry]" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Name=Robomongo" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Comment=MongoDB Database Administration" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Exec=/usr/local/bin/robomongo/bin/robo3t" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Terminal=false" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Type=Application" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "Icon=robomongo" >> ${ROBO_MONGO_LAUNCHER_PATH}
            sudo echo "StartupWMClass=robo3t" >> ${ROBO_MONGO_LAUNCHER_PATH}
        fi
  fi
  breakLine
}

cVsCodeIde() {
    title "Microsoft Visual Studio Code IDE"
    if [ "$(askUser "Install Microsoft Visual Studio Code IDE")" -eq 1 ]; then
        sudo apt install -y code
    fi
    breakLine
}

cPhpStormIde() {
    title "PHPStorm (30 Day Trial) IDE"
    if [ "$(askUser "Install PHPStorm (30 Day Trial) IDE")" -eq 1 ]; then
        cd /tmp
        wget "https://download.jetbrains.com/webide/PhpStorm-2018.2.1.tar.gz" -O phpstorm.tar.gz
        sudo tar xf phpstorm.tar.gz

        if [ -d ${PHPSTORM_PATH} ]; then
            sudo rm -rf ${PHPSTORM_PATH}
        fi

        sudo mkdir ${PHPSTORM_PATH}
        sudo mv PhpStorm-*/* ${PHPSTORM_PATH}
        sudo rm -rf PhpStorm-*/
        sudo rm phpstorm.tar.gz

        local PHPSTORM_LAUNCHER_PATH=/usr/share/applications/phpstorm.desktop

        if [ ! -f ${PHPSTORM_LAUNCHER_PATH} ]; then
            sudo touch ${PHPSTORM_LAUNCHER_PATH}
        fi

        sudo truncate --size 0 ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "[Desktop Entry]" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Version=1.0" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Type=Application" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Name=PhpStorm" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Icon=phpstorm" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Exec=/usr/local/bin/phpstorm/bin/phpstorm.sh" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "StartupWMClass=jetbrains-phpstorm" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Comment=The Drive to Develop" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Categories=Development;IDE;" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Terminal=false" >> ${PHPSTORM_LAUNCHER_PATH}
    fi
    breakLine
}

cPyCharmIde() {
    title "PyCharm Community Edition IDE"
    if [ "$(askUser "Install PyCharm Community Edition IDE")" -eq 1 ]; then
        cd /tmp
        wget "https://download.jetbrains.com/python/pycharm-community-2017.2.3.tar.gz" -O pycharm.tar.gz
        sudo tar xf pycharm.tar.gz

        if [ -d ${PYCHARM_PATH} ]; then
            sudo rm -rf ${PYCHARM_PATH}
        fi

        sudo mkdir ${PYCHARM_PATH}
        sudo mv pycharm-*/* ${PYCHARM_PATH}
        sudo rm -rf pycharm-*/
        sudo rm pycharm.tar.gz

        local PYCHARM_LAUNCHER_PATH=/usr/share/applications/pycharm.desktop

        if [ ! -f ${PYCHARM_LAUNCHER_PATH} ]; then
            sudo touch ${PYCHARM_LAUNCHER_PATH}
        fi

        sudo truncate --size 0 ${PYCHARM_LAUNCHER_PATH}
        sudo echo "[Desktop Entry]" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Version=1.0" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Type=Application" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Name=PyCharm" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Icon=pycharm" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Exec=/usr/local/bin/pycharm/bin/pycharm.sh" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "StartupWMClass=jetbrains-pycharm-ce" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Comment=The Drive to Develop" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Categories=Development;IDE;" >> ${PYCHARM_LAUNCHER_PATH}
        sudo echo "Terminal=false" >> ${PYCHARM_LAUNCHER_PATH}
    fi
    breakLine
}

cFacebookMessenger() {
    title "Facebook Messenger"
    if [ "$(askUser "Install Facebook Messenger")" -eq 1 ]; then
        cd /tmp
        wget "https://updates.messengerfordesktop.com/download/linux/latest/beta?arch=amd64&pkg=deb" -O messenger.deb
        sudo dpkg -i messenger.deb
        sudo rm messenger.deb
    fi
    breakLine
}

cSkype () {
    title "Skype Messenger"
    if [ "$(askUser "Install Skype Messenger")" -eq 1 ]; then
        cd /tmp
        wget "https://go.skype.com/skypeforlinux-64.deb" -O skypeforlinux.deb
        sudo dpkg -i skypeforlinux.deb
        sudo rm skypeforlinux.deb
    fi
    breakLine
}

cPopcornTime() {
    title "Popcorn Time (because why not? :p)"
    if [ "$(askUser "Install Popcorn Time (you deserve it)")" -eq 1 ]; then
        if [ -d /opt/popcorn-time ]; then
            sudo rm -rf /opt/popcorn-time/
        fi

        sudo mkdir /opt/popcorn-time
        sudo wget -qO- "https://get.popcorntime.sh/build/Popcorn-Time-0.3.10-Linux-64.tar.xz" | sudo tar Jx -C /opt/popcorn-time
        sudo ln -sf /opt/popcorn-time/Popcorn-Time /usr/bin/popcorn-time

        local POPCORN_TIME_LAUNCHER_PATH=/usr/share/applications/popcorntime.desktop

        if [ ! -f ${POPCORN_TIME_LAUNCHER_PATH} ]; then
            sudo touch ${POPCORN_TIME_LAUNCHER_PATH}
        fi

        sudo truncate --size 0 ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "[Desktop Entry]" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Version=1.0" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Terminal=false" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Type=Application" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Name=Popcorn Time" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Icon=popcorntime" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Exec=/opt/popcorn-time/Popcorn-Time" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "StartupWMClass=Chromium-browser" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Categories=Application;" >> ${POPCORN_TIME_LAUNCHER_PATH}
    fi
    breakLine
}

cLocalesPlusKeymap() {
    title "Configuring locales and keyboard mappings"
    sudo locale-gen en_US.UTF-8 
    sudo locale-gen en_GB.UTF-8
    sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LANGUAGE=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
    sudo sed -i "s/XKBMODEL=.*/XKBMODEL=\"chromebook\"/g" /etc/default/keyboard
    breakLine
}

cClean() {
    title "Cleaning up..."
    sudo apt remove -y xterm netsurf netsurf-common netsurf-fb netsurf-gtk
    sudo apt update -y
    sudo apt autoremove --purge -y
    sudo updatedb
    breakLine
}

configure() {

    # Set the home variable
    export HOME=/home/`ls /home/ | awk '{print $1}'`

    # OS setup
    local IS_OS_SETUP=`dpkg -l | grep preload | awk '{print $1}'`
    if [ "$IS_OS_SETUP" = "" ]; then
        cPreRequisites
        cRepositories
        cUi
    fi

    # Systems setup
    cPhp
    cNodeJs
    cGit
    cDocker
    cMySqlWorkbench
    cMongoDb
    cVsCodeIde
    cPhpStormIde
    cPyCharmIde
    cFacebookMessenger
    cPopcornTime
    cLocalesPlusKeymap
    cClean
    exit
}


###############################################################
## Main application
###############################################################
clear
if [ ${INODE_NUM} -eq 2 ];
    then
        if [ $# -eq 0 ];
            then
            install
        else while getopts :u option
            do
                case "${option}" in
                u) updateChroot;;
                esac
            done
        fi
    else configure
fi
