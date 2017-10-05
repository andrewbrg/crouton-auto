
# Linux 16.04 Xenial on ChromeOS via Crouton
   
   
![3fa4bf29a8d83625909b76abb99537e9.jpg](http://pichoster.net/images/2017/10/03/3fa4bf29a8d83625909b76abb99537e9.jpg)
   
This is a handy tutorial on setting up a dev machine on your chromebook, Crouton is developed and maintained by David Schneider https://github.com/dnschneid  

**A few vital resources before getting started.** 

| Type | Link |
| ------ | ------ |
| Official Crouton Git | https://github.com/dnschneid/crouton |
| Crouton Cheat Sheet | https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet |
| Crouton Wiki | https://github.com/dnschneid/crouton/wiki |
| Crouton Chrome Extension | https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom |
  
***
  
**Ready, Let's go!** After placing your Chromebook into developer mode, launch a terminal by `CTRL+ALT+T` then run the following commands:
### Get a fresh Crouton
```shell
shell;
cd ~/Downloads;
wget https://goo.gl/fd3zc -O crouton;
```

Official Crouton repository is here: https://github.com/dnschneid/crouton 

### Install Linux 16.04 LTS via Crouton
```sh
sudo sh ~/Downloads -r xenial -t cli-extra,xorg,extension,keyboard,audio,chrome,gnome -e;
```

### Install prerequisites
```sh
sudo enter-chroot;
sudo apt install locales software-properties-common python-software-properties;
```

### Install important repositories
```shell
sudo add-apt-repository ppa:numix/ppa;
sudo add-apt-repository ppa:gnome3-team/gnome3-staging;
sudo add-apt-repository ppa:gnome3-team/gnome3;
sudo add-apt-repository ppa:notepadqq-team/notepadqq;
```

### Install important tools
```shell
sudo apt update;
sudo apt install language-pack-en-base nano mlocate htop curl notepadqq preload inxi;
```

### Set correct locales
```shell
sudo nano /etc/default/locale;
```
Now enter the following lines in this file and save it:

> LANG=en_US.UTF-8    
> LANGUAGE=en_US.UTF-8    
> LC_ALL=en_US.UTF-8    

Once this is done you should reboot the chroot and verify all locales are setup correctly as `en_US.UTF-8`
```shell
exit;
sudo enter-chroot;
locale;
```

### Distribution UI
```shell
sudo apt dist-upgrade;
sudo apt install numix-icon-theme-circle gnome-tweak-tool gnome-terminal whoopsie gnome-control-center gnome-online-accounts;
sudo apt install gnome-shell-extension-dashtodock gnome-software gnome-software-common gnome-shell-pomodoro;
sudo apt remove xterm netsurf netsurf-common netsurf-fb netsurf-gtk;
```

### Install PHP 7.0
```shell
sudo apt install php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip;
```

### Install Composer
```shell
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer;
```

### Install NodeJS/NPM
```shell
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt install node npm build-essential;
```

### Install Bower
```shell
sudo npm install bower -g
```

### Install Gulp
```shell
sudo npm install gulp -g
```

### Install MeteorJS
```shell 
sudo curl https://install.meteor.com/ | sh
```

### Install Git
```shell 
sudo apt install git
```

### Install MongoDB
```shell 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6;
sudo echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list;
sudo apt update;
sudo apt install mongodb-org;
```

### Install Robo3T (RoboMongo)
```shell 
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
```shell 
sudo apt install mysql-server;
sudo apt install mysql-workbench;
sudo mysql_secure_installation;
```

### Install VSCode IDE
```shell 
cd /tmp;
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg;
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list';
sudo apt update;
sudo apt install code;
```

### Install PhpStorm IDE
```shell 
cd /tmp;
wget https://download.jetbrains.com/webide/PhpStorm-2017.2.4.tar.gz -O phpstorm.tar.gz;
sudo tar xf phpstorm.tar.gz;
sudo mkdir /usr/local/bin/phpstorm;
sudo mv PhpStorm-*/* /usr/local/bin/phpstorm;
sudo rm -rf PhpStorm-*/;
sudo rm phpstorm.tar.gz;
```

### Clean up
```shell 
sudo apt --purge autoremove -y;
sudo updatedb;
exit;
```

### Boot up Ubuntu!
```shell 
sudo startgnome;
```

### Finalise PhpStorm IDE / Robo3T
```shell 
cd /usr/local/bin/phpstorm/bin;
./phpstorm.sh;

cd /usr/local/bin/robomongo/bin;
./robo3t;
```

# Updating Ubuntu via Crouton
If a new version of crouton came out, grab it and run:
```shell 
sudo sh -e /tmp/crouton -n xenial -u;
```
