#!/bin/bash

###############################################################
## Title helper
###############################################################
title() {
    printf "\\n\\n"
    printf "\\033[1;42m"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' '
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf "\\033[0m"
    printf "\\n"
    sleep .5
}

###############################################################
## Installation
###############################################################
install() {
    # Prepare vars
    selfName=`basename $0`
    selfPath=`dirname $0`/$selfName
    croutonPath=`dirname $0`/crouton
    bootstrapPath=`dirname $0`/xenial.tar.bz2
    downloadsPath=/home/chronos/user/Downloads
    chrootPath=/mnt/stateful_partition/crouton/chroots/xenial
    targets=cli-extra,xorg,xiwi,extension,keyboard,audio,chrome,gnome

    # Move to the downloads folder, we'll work in here
    cd $downloadsPath

    # If no crouton file exists get it
    if [ ! -f $croutonPath ]; then
        title "Fetching latest crouton"
        wget https://goo.gl/fd3zc -O crouton
    fi
    
    # If no chroot is setup
    if [ ! -d $chrootPath ]; then
        # Prepare a bootstrap
        if [ ! -f $bootstrapPath ]; then
            title "Preparing an Ubuntu bootstrap"
            sudo sh $croutonPath -d -f $bootstrapPath -r xenial -t $targets
        fi
        
        # Setup Ubuntu
        title "Installing Ubuntu 16.04LTS in chroot"
        sudo sh $croutonPath -f $bootstrapPath -t $targets
    fi
    
    # Launch Ubuntu & configure
    title "Mounting chroot"
    
    # Get chroot username
    chrootUsername=`ls $chrootPath/home/ | awk '{print $1}'`
    sudo cp $selfPath $chrootPath/home/$chrootUsername/Downloads/$selfName
    sudo chmod +x $chrootPath/home/$chrootUsername/Downloads/$selfName
    sudo enter-chroot -n xenial -l sh /home/$chrootUsername/Downloads/$selfName
}

###############################################################
## Configuration
###############################################################
configure() {
    title "Installing prerequisites..."
    sudo apt install -y locales software-properties-common python-software-properties
    
    title "Setting up repos..."
    sudo add-apt-repository -y ppa:numix/ppa  
    sudo add-apt-repository -y ppa:gnome3-team/gnome3-staging  
    sudo add-apt-repository -y ppa:gnome3-team/gnome3  
    sudo add-apt-repository -y ppa:notepadqq-team/notepadqq  
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6  
    sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list  
    sudo apt install -y curl  
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg  
    sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg  
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    
    title "Installing important tools..."
    sudo apt update -y  
    sudo apt install -y language-pack-en-base nano mlocate htop notepadqq preload inxi
    
    title "Preparing the UI..."
    sudo apt dist-upgrade -y  
    sudo apt install -y numix-icon-theme-circle gnome-tweak-tool gnome-terminal whoopsie gnome-control-center gnome-online-accounts   
    sudo apt install -y gnome-shell-extension-dashtodock gnome-software gnome-software-common gnome-shell-pomodoro  
    
    title "Installing PHP7.0..."
    sudo apt install -y php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip  
    
    title "Installing Composer..."
    sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer  

    title "Installing NodeJS..."
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -  
    sudo apt install -y build-essential nodejs  
    
    title "Installing Bower..."
    sudo npm install -y bower -g  

    title "Installing Gulp..."
    sudo npm install -y gulp -g  

    title "Installing MeteorJS..."
    sudo curl https://install.meteor.com/ | sh  

    title "Installing Git..."
    sudo apt install -y git  

    title "Installing MongoDB..."
    sudo apt install -y mongodb-org
    
    title "Installing MySQL Server & Workbench..."
    sudo apt install -y mysql-server  
    sudo apt install -y mysql-workbench  
    sudo mysql_secure_installation   
    
    title "Installing Robomongo..."
    sudo apt install -y xcb  
    wget https://download.robomongo.org/1.1.1/linux/robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz -O robomongo.tar.gz  
    sudo mkdir /usr/local/bin/robomongo  
    sudo tar xf robomongo.tar.gz  
    sudo rm robomongo.tar.gz  
    sudo mv robo3t-*/* /usr/local/bin/robomongo  
    sudo rm -rf robo3t-*/  
    sudo rm /usr/local/bin/robomongo/lib/libstdc++*  
    sudo chmod +x /usr/local/bin/robomongo/bin/robo3t 
    
    title "Installing VS Code IDE..."
    sudo apt install -y code
    
    title "Installing PHP Storm IDE..."
    wget https://download.jetbrains.com/webide/PhpStorm-2017.2.4.tar.gz -O phpstorm.tar.gz  
    sudo tar xf phpstorm.tar.gz  
    sudo mkdir /usr/local/bin/phpstorm  
    sudo mv PhpStorm-*/* /usr/local/bin/phpstorm  
    sudo rm -rf PhpStorm-*/  
    sudo rm phpstorm.tar.gz  
    
    title "Cleaning up..."
    sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LANGUAGE=en_US.UTF-8" >> /etc/default/locale
    sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
    sudo sed 's/.*XKBMODEL.*/XKBMODEL="chromebook"/' /etc/default/keyboard
    
    sudo apt remove -y xterm netsurf netsurf-common netsurf-fb netsurf-gtk
    sudo apt --purge autoremove -y  
    sudo updatedb 
    
    title "Finalise PHP Storm..."
    cd /usr/local/bin/phpstorm/bin  
    xiwi ./phpstorm.sh  

    title "Finalise Robomongo..."
    cd /usr/local/bin/robomongo/bin  
    xiwi ./robo3t 
}

inodeNum=`ls -id / | awk '{print $1}'`
if [ $inodeNum -eq 2 ]; 
    then 
        install
    else 
        configure
        sudo startgnome   
fi
