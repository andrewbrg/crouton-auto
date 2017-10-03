
# Linux 16.04 Xenial on ChromeOS via Crouton
##

| Plugin | README |
| ------ | ------ |
| Crouton | https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet |
| Crouton Extension | https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom |


After placing your Chromebook into developer mode, launch a terminal by CTRL+ALT+T then run the following commands:

### Get a fresh Crouton
```shell
$ shell;
$ cd /tmp;
$ wget https://goo.gl/fd3zc -O crouton;
```

### Install Linux 16.04 LTS via Crouton
```sh
$ sudo sh /tmp/crouton -r xenial -t cli-extra,xorg,xiwi,extension,keyboard,audio,chrome,gnome -e;
```

### Install prerequisites
```sh
$ sudo enter-chroot;
$ sudo apt install locales software-properties-common python-software-properties;
```

### Install important repositories
```sh
$ sudo add-apt-repository ppa:numix/ppa;
$ sudo add-apt-repository ppa:gnome3-team/gnome3-staging;
$ sudo add-apt-repository ppa:gnome3-team/gnome3;
$ sudo add-apt-repository ppa:notepadqq-team/notepadqq;
```

### Install important tools
```shell
sudo apt update;
sudo apt install language-pack-en-base nano mlocate htop curl notepadqq preload inxi;
```

### Set correct locales
```sh
$ sudo nano /etc/default/locale;
```
Now enter the following lines in this file and save it:

> LANG=en_US.UTF-8
>
> LANGUAGE=en_US.UTF-8
>
> LC_ALL=en_US.UTF-8

Once this is done you should reboot the chroot and verify all locales are setup correctly as en_US.UTF-8:
```sh
$ exit;
$ sudo enter-chroot;
$ locale;
```

### Distribution UI
```sh
$ sudo apt dist-upgrade;
$ sudo apt install numix-icon-theme-circle gnome-tweak-tool gnome-terminal whoopsie gnome-control-center gnome-online-accounts;
$ sudo apt install gnome-shell-extension-dashtodock gnome-software gnome-software-common gnome-shell-pomodoro;
$ sudo apt remove xterm netsurf netsurf-common netsurf-fb netsurf-gtk xserver-xorg-video-intel;
```

### Install PHP 7.0
```sh
$ sudo apt install php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip;
```

### Install Composer
```sh
$ sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer;
```

### Install NodeJS/npm
```sh
$ curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
$ sudo apt install node npm build-essential;
```

### Install Bower
```sh
$ sudo npm install -g bower
```

### Install MeteorJS
```sh
$ sudo curl https://install.meteor.com/ | sh
```

### Install Git
```sh
$ sudo apt install git
```

### Install MongoDB
```sh
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10;
$ sudo echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list;
$ sudo apt update;
$ sudo apt install mongodb-org;
```

### Install Robo3T (RoboMongo)
```sh
$ sudo apt install xcb;
$ cd /tmp;
$ wget https://download.robomongo.org/1.1.1/linux/robo3t-1.1.1-linux-x86_64-c93c6b0.tar.gz -O robomongo.tar.gz;
$ sudo mkdir /usr/local/bin/robomongo;
$ sudo tar xf robomongo.tar.gz;
$ sudo rm robomongo.tar.gz;
$ sudo mv robo3t-*/* /usr/local/bin/robomongo;
$ sudo rm -rf robo3t-*/;
$ sudo rm /usr/local/bin/robomongo/lib/libstdc++*;
$ sudo chmod +x /usr/local/bin/robomongo/bin/robo3t;
```

### Install MySQL Server and Workbench
```sh
$ sudo apt install mysql-server;
$ sudo apt install mysql-workbench;
$ sudo mysql_secure_installation;
```

### Install VSCode IDE
```sh
$ cd /tmp;
$ curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
$ sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg;
$ sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list';
$ sudo apt update;
$ sudo apt install code;
```

### Install PhpStorm IDE
```sh
$ cd /tmp;
$ wget https://download.jetbrains.com/webide/PhpStorm-2017.2.4.tar.gz -O phpstorm.tar.gz;
$ sudo tar xf phpstorm.tar.gz;
$ sudo mkdir /usr/local/bin/phpstorm;
$ sudo mv PhpStorm-*/* /usr/local/bin/phpstorm;
$ sudo rm -rf PhpStorm-*/;
$ sudo rm phpstorm.tar.gz;
```

### Clean up and enter GUI
```sh
$ sudo apt --purge autoremove -y;
$ sudo updatedb;
$ exit;
```

### Boot up Ubuntu!
```sh
$ sudo startgnome;
```

### Finalise PhpStorm IDE / Robo3T
```sh
$ cd /usr/local/bin/phpstorm/bin;
$ ./phpstorm.sh;

$ cd /usr/local/bin/robomongo/bin;
$ ./robo3t;
```

# Updating Ubuntu via Crouton
If a new version of crouton came out, grab it and run:
```sh
$ sudo sh -e /tmp/crouton -n xenial -u;
```
