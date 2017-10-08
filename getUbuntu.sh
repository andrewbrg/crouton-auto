#!/bin/bash

###############################################################
## GLOBALS
###############################################################
SELF_NAME=`basename $0`
SELF_PATH=`dirname $0`/${SELF_NAME}
CROUTON_PATH=`dirname $0`/crouton
PHPSTORM_PATH=/usr/local/bin/phpstorm
INODE_NUM=`ls -id / | awk '{print $1}'`
ROBO_MONGO_PATH=/usr/local/bin/robomongo
BOOTSTRAP_PATH=`dirname $0`/xenial.tar.bz2
DOWNLOADS_PATH=/home/chronos/user/Downloads
CHROOT_PATH=/mnt/stateful_partition/crouton/chroots/xenial
TARGETS=cli-extra,xorg,xiwi,extension,keyboard,audio,chrome,gnome
    
    
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
install() {
    # Move to the downloads folder, we'll work in here
    cd ${DOWNLOADS_PATH}

    # If no crouton file exists get it
    if [ ! -f ${CROUTON_PATH} ]; then
        title "Fetching latest crouton"
        wget https://goo.gl/fd3zc -O crouton
        breakLine
    fi
    
    # If no chroot is setup
    if [ ! -d ${CHROOT_PATH} ]; then
        # Prepare a bootstrap
        if [ ! -f ${BOOTSTRAP_PATH} ]; then
            title "Preparing an Ubuntu bootstrap"
            sudo sh ${CROUTON_PATH} -d -f ${BOOTSTRAP_PATH} -r xenial -t ${TARGETS}
            breakLine
        fi
        
        # Setup Ubuntu
        title "Ubuntu 16.04 on Chromebook"
        if [ "$(askUser "Install Ubuntu 16.04 LTS (xenial)")" -eq 1 ]; then
            sudo sh ${CROUTON_PATH} -f ${BOOTSTRAP_PATH} -t ${TARGETS}
        fi
        breakLine
    fi
    
    # Launch Ubuntu & configure
    title "Mounting chroot"
    
    # Get chroot username
    CHROOT_USERNAME=`ls ${CHROOT_PATH}/home/ | awk '{print $1}'`
    sudo enter-chroot -n xenial -l sh /home/${CHROOT_USERNAME}/Downloads/${SELF_NAME}
    breakLine
}

###############################################################
## Configuration
###############################################################
cPrerequisites() {
    title "Installing prerequisites"
    sudo apt install -y locales software-properties-common python-software-properties
    breakLine
}

cRepos() {
    title "Setting up repos"
    sudo add-apt-repository -y ppa:numix/ppa
    sudo add-apt-repository -y ppa:gnome3-team/gnome3-staging
    sudo add-apt-repository -y ppa:gnome3-team/gnome3
    sudo add-apt-repository -y ppa:notepadqq-team/notepadqq
    
    sudo apt install -y curl apt-transport-https ca-certificates
    
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    
    sudo apt update -y
    breakLine
}

cUi() {
    title "Preparing the Gnome UI"
    sudo apt dist-upgrade -y
    sudo apt install -y numix-icon-theme-circle gnome-tweak-tool gnome-terminal whoopsie gnome-control-center gnome-online-accounts
    sudo apt install -y language-pack-en-base nano mlocate htop notepadqq preload inxi filezilla vlc
    sudo apt install -y gnome-shell-extension-dashtodock gnome-software gnome-software-common gnome-shell-pomodoro chrome-gnome-shell gnome-shell-extension-top-icons-plus
    breakLine
}

cClean() {
    title "Cleaning up"
    sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LANGUAGE=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
    sudo sed -i "s/XKBMODEL=.*/XKBMODEL=\"chromebook\"/g" /etc/default/keyboard
    
    sudo apt remove -y xterm netsurf netsurf-common netsurf-fb netsurf-gtk
    sudo apt --purge autoremove -y
    sudo updatedb
    breakLine
}

cPhp() {
    title "PHP 7.0"
    if [ "$(askUser "Install PHP7.0")" -eq 1 ]; then
        sudo apt install -y php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip php7.0-dev php-pear
        
        breakLine
        title "Composer"
        if [ "$(askUser "Install Composer")" -eq 1 ]; then
            sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
        fi
        
        breakLine
        title "Swoole"
        if [ "$(askUser "Install Swoole")" -eq 1 ]; then
            sudo pecl install -y swoole
        fi
    fi
    breakLine
}

cNodeJs() {
    title "Node JS"
    if [ "$(askUser "Install NodeJS")" -eq 1 ]; then
        curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
        sudo apt install -y build-essential nodejs
        
        breakLine
        title "Bower"
        if [ "$(askUser "Install Bower")" -eq 1 ]; then
            sudo npm install -y bower -g
        fi
        
        breakLine
        title "Gulp"
        if [ "$(askUser "Install Gulp")" -eq 1 ]; then
            sudo npm install -y gulp -g
        fi

        breakLine
        title "Nodemon"
        if [ "$(askUser "Install Nodemon")" -eq 1 ]; then
            sudo npm install -y nodemon -g
        fi
        
        breakLine
        title "Meteor.JS"
        if [ "$(askUser "Install Meteor.js")" -eq 1 ]; then
            sudo curl https://install.meteor.com/ | sh
        fi
        
        breakLine
        title "Vue Cli"
        if [ "$(askUser "Install Vue")" -eq 1 ]; then
            sudo npm install -y vue-cli -g
        fi
        
    fi
    breakLine
}

cGit() {
    title "Git"
    if [ "$(askUser "Install Git")" -eq 1 ]; then
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

cMySql() {
    title "MySQL Workbench"
    if [ "$(askUser "Install MySQL Workbench")" -eq 1 ]; then
        sudo apt install -y mysql-workbench
    fi
    breakLine
}

cMongoDb() {
    title "MongoDB"
    if [ "$(askUser "Install MongoDB server")" -eq 1 ]; then
        sudo apt install -y mongodb-org
        
        breakLine
        title "RoboMongo (Robo 3T)"
        if [ "$(askUser "Install RoboMongo")" -eq 1 ]; then
            sudo apt install -y xcb
            cd /tmp
            wget https://download.robomongo.org/1.1.1/linux/robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz -O robomongo.tar.gz
            
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
        fi
  fi
  breakLine
}

cVsCodeIde() {
    title "Microsoft VS Code IDE"
    if [ "$(askUser "Install Microsoft VS Code IDE")" -eq 1 ]; then
        sudo apt install -y code
    fi
    breakLine
}

cPopcornTime() {
    title "Popcorn Time"
    if [ "$(askUser "Install Popcorn Time")" -eq 1 ]; then
        if [ ! -d /opt/popcorn-time ]; then
            sudo rm -rf /opt/popcorn-time
        fi
        
        sudo mkdir /opt/popcorn-time
        sudo wget -qO- https://get.popcorntime.sh/build/Popcorn-Time-0.3.10-Linux-64.tar.xz | sudo tar Jx -C /opt/popcorn-time
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
        sudo echo "Icon=phpstorm" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Exec=/usr/bin/popcorn-time" >> ${POPCORN_TIME_LAUNCHER_PATH}
        sudo echo "Categories=Application;" >> ${POPCORN_TIME_LAUNCHER_PATH}
    fi
    breakLine   
}

cPhpStormIde() {
    title "PHP Storm IDE"
    if [ "$(askUser "Install PHP Storm IDE")" -eq 1 ]; then
        cd /tmp
        wget https://download.jetbrains.com/webide/PhpStorm-2017.2.4.tar.gz -O phpstorm.tar.gz
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
        sudo echo "Comment=The Drive to Develop" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Categories=Development;IDE;" >> ${PHPSTORM_LAUNCHER_PATH}
        sudo echo "Terminal=false" >> ${PHPSTORM_LAUNCHER_PATH}
    fi
    breakLine
}

cSlack() {
    title "Slack"
    if [ "$(askUser "Install Slack")" -eq 1 ]; then
        sudo apt install -y slack-desktop gvfs-bin gir1.2-gnomekeyring-1.0

        local SLACK_LAUNCHER_PATH=/usr/share/applications/slack.desktop

        if [ ! -f ${SLACK_LAUNCHER_PATH} ]; then
            sudo touch ${SLACK_LAUNCHER_PATH}
        fi

        sudo truncate --size 0 ${SLACK_LAUNCHER_PATH}
        sudo echo "[Desktop Entry]" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Name=Slack" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Comment=Slack Desktop" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "GenericName=Slack Client for Linux" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Exec=/usr/bin/slack --disable-gpu %U" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Icon=slack" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Type=Application" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "StartupNotify=true" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "Categories=GNOME;GTK;Network;InstantMessaging;" >> ${SLACK_LAUNCHER_PATH}
        sudo echo "MimeType=x-scheme-handler/slack;" >> ${SLACK_LAUNCHER_PATH}
    fi
    breakLine
}

configure() {
    
    # Set the home variable
    export HOME=/home/`ls /home/ | awk '{print $1}'`
    
    # OS setup
    local IS_OS_SETUP=`dpkg -l | grep preload | awk '{print $1}'`
    if [ "$IS_OS_SETUP" = "" ]; then
        cPrerequisites;
        cRepos;
        cUi;
    fi
    
    # Apps setup
    cPhp;
    cNodeJs;
    cGit;
    cDocker;
    cMySql;
    cMongoDb;
    cVsCodeIde;
    cPhpStormIde;
    cSlack;
    cPopcornTime;
    cClean;
    exit;
}


###############################################################
## Main application
###############################################################
clear
if [ ${INODE_NUM} -eq 2 ];
    then
        install;
    else
        configure;
fi