
# //// Linux 16.04 Xenial on ChromeOS via Crouton

### Useful resources
_Crouton:_ https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet
_Crouton ext:_ https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom 

After placing your Chromebook into developer mode, launch a terminal by CTRL+ALT+T then run the following commands:

### Get a fresh Crouton
```bash
shell;
cd /tmp;
wget https://goo.gl/fd3zc -O crouton;
```

### Let Crouton install a Linux 16.04 LTS
```bash
sudo sh /tmp/crouton -r xenial -t cli-extra,xorg,xiwi,extension,keyboard,audio,chrome,gnome -e;
```

### Install prerequisites
```bash
sudo enter-chroot;
sudo apt install locales software-properties-common python-software-properties;
```

### Install important repositories
```bash
sudo add-apt-repository ppa:numix/ppa;
sudo add-apt-repository ppa:gnome3-team/gnome3-staging;
sudo add-apt-repository ppa:gnome3-team/gnome3;
sudo add-apt-repository ppa:notepadqq-team/notepadqq;
```

# Install important tools
```bash
sudo apt update;
sudo apt install language-pack-en-base nano mlocate htop curl notepadqq preload inxi;
```

# Set correct locales
```bash
sudo nano /etc/default/locale;
```

LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8

```bash
exit;
sudo enter-chroot;
locale; # confirm all locales are set as en_US.UTF-8
```


### Distribution UI
```bash
sudo apt dist-upgrade;
sudo apt install numix-icon-theme-circle gnome-tweak-tool gnome-terminal whoopsie gnome-control-center gnome-online-accounts;
sudo apt install gnome-shell-extension-dashtodock gnome-software gnome-software-common gnome-shell-pomodoro;
sudo apt remove xterm netsurf netsurf-common netsurf-fb netsurf-gtk xserver-xorg-video-intel;
```

### Install PHP 7.0
```bash
sudo apt install php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip;
```

### Install Composer
```bash
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer;
```

### Install NodeJS/npm
```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install node npm build-essential;
```

### Install Bower
```bash
sudo npm install -g bower
```

### Install MeteorJS
```bash
sudo curl https://install.meteor.com/ | sh
```

### Install Git
```bash
sudo apt install git
```

### Install MongoDB
```bash
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10;
sudo echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list;
sudo apt update;
sudo apt install mongodb-org;
```

### Install Robo3T
```bash
sudo apt install xcb;
cd /tmp;
wget https://download.robomongo.org/1.1.1/linux/robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz -O robomongo.tar.gz;
sudo mkdir /usr/local/bin/robomongo;
sudo tar xf robomongo.tar.gz;
sudo rm robomongo.tar.gz;
sudo mv robo3t-*/* /usr/local/bin/robomongo;
sudo rm -rf robo3t-*/;
sudo rm /usr/local/bin/robomongo/lib/libstdc++*;
sudo chmod +x /usr/local/bin/robomongo/bin/robo3t;
```

### Install MySQL Server and Workbench
```bash
sudo apt install mysql-server;
sudo apt install mysql-workbench;
sudo mysql_secure_installation;
```

### Install VSCode IDE
```bash
cd /tmp;
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg;
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list';
sudo apt update;
sudo apt install code;
```

### Install PhpStorm IDE
cd /tmp;
wget https://download.jetbrains.com/webide/PhpStorm-2017.2.4.tar.gz -O phpstorm.tar.gz;
sudo tar xf phpstorm.tar.gz;
sudo mkdir /usr/local/bin/phpstorm;
sudo mv PhpStorm-*/* /usr/local/bin/phpstorm;
sudo rm -rf PhpStorm-*/;
sudo rm phpstorm.tar.gz;
```

### Clean up and enter GUI
```bash
sudo apt --purge autoremove -y;
sudo updatedb;
exit;
sudo startgnome;
```

### Finalise PhpStorm IDE / Robo3T
```bash
cd /usr/local/bin/phpstorm/bin;
./phpstorm.sh;

cd /usr/local/bin/robomongo/bin;
./robo3t;
```

## Updating Ubuntu via Crouton
```bash
sudo sh -e /tmp/crouton -n xenial -u;
```
