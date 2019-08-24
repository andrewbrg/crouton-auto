#!/bin/bash
DISTRO=buster;
TARGETS=cli-extra,xorg,xiwi,extension,keyboard,audio,chrome;

SELF_NAME=`basename $0`;
INODE_NUM=`ls -id / | awk '{print $1}'`;

SELF_PATH=`dirname $0`/${SELF_NAME};
CROUTON_PATH=`dirname $0`/crouton;
BOOTSTRAP_PATH=`dirname $0`/${DISTRO}.tar.bz2;
DOWNLOADS_PATH=/home/chronos/user/Downloads;
CHROOT_PATH=/mnt/stateful_partition/crouton/chroots/${DISTRO};

## Helpers
###############################################################
title() {
  printf "\033[1;42m";
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
  printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' ';
  printf '%*s' "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
  printf "\033[0m";
  printf "\n\n";
}

breakLine() {
  printf "\n";
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
  printf "\n\n";
  sleep .5;
}

fetchCrouton() {
  cd ${DOWNLOADS_PATH};
  if [ ! -f ${CROUTON_PATH} ]; then
    title "Fetching Crouton";
      curl "https://goo.gl/fd3zc" -L -o crouton;
    breakLine;
  fi
}
###############################################################


## Installation
###############################################################
install() {
  fetchCrouton;
  if [ ! -d ${CHROOT_PATH} ]; then
    if [ ! -f ${BOOTSTRAP_PATH} ]; then
      title "Preparing Linux Bootstrap";
        sudo sh ${CROUTON_PATH} -d -f ${BOOTSTRAP_PATH} -r ${DISTRO} -t ${TARGETS};
      breakLine;
    fi

    title "Installing Linux on ChromeOS";
      sudo sh ${CROUTON_PATH} -f ${BOOTSTRAP_PATH} -t ${TARGETS};
    breakLine;
  fi
}

mount() {
  title "Mounting Chroot";
    CHROOT_USERNAME=`ls ${CHROOT_PATH}/home/ | awk '{print $1}'`;
    sudo enter-chroot -n ${DISTRO} -l sh /home/${CHROOT_USERNAME}/Downloads/${SELF_NAME};
  breakLine;
}

configure() {
  mount;
  local IS_OS_SETUP=`dpkg -l | grep preload | awk '{print $1}'`;
  if [ "$IS_OS_SETUP" = "" ]; then
    title "Installing Pre-Requisites";
      sudo apt install -y software-properties-common \
                          python-software-properties \
                          curl \
                          apt-transport-https \
                          ca-certificates;
    breakLine;

    title "Updating Repositories";
      sudo add-apt-repository -y ppa:numix/ppa;
      sudo add-apt-repository -y ppa:moka/daily;
      sudo add-apt-repository -y ppa:gwendal-lebihan-dev/cinnamon-stable;
      sudo apt update -y;
    breakLine;
  
    title "Preparing UI";
      sudo apt install -y cinnamon \
                          language-pack-en-base \
                          numix-icon-theme-circle \
                          moka-icon-theme \
                          whoopsie \
                          mlocate \
                          preload \
                          xarchiver \
                          p7zip \
                          p7zip-rar;
    breakLine;
    
    title "Setting Home Permissions";
      export HOME_PATH=/home/`ls /home/ | awk '{print $1}'`;
      sudo chown -R 1000:1000 ${HOME_PATH};
    breakLine;
    
    title "Configuring Locale & Keyboard";
      sudo locale-gen en_US.UTF-8;
      sudo locale-gen en_GB.UTF-8;
      sudo echo "LANG=en_US.UTF-8" >> /etc/default/locale;
      sudo echo "LANGUAGE=en_US.UTF-8" >> /etc/default/locale;
      sudo echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale;
      sudo sed -i "s/XKBMODEL=.*/XKBMODEL=\"chromebook\"/g" /etc/default/keyboard;
    breakLine;
    
    title "Configure Your Disto";
      cd ~/;
      sudo apt install -y wget;
      bash <(wget -qO- "https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/setup.sh");
    breakLine;
    
    wget "https://gist.github.com/sohjsolwin/5934362/raw/f68fc0942798902a0bd48f40c17dc0cd5cf585ea/startcinnamon";
    sudo chmod +x startcinnamon;
  fi
  
  exit;
  
  cd ${DOWNLOADS_PATH};
  sudo mv ./startcinnamon "/usr/local/bin";
}

update() {
  if [ ${INODE_NUM} -eq 2 ]; then
    title "Updating Chroot";
      fetchCrouton;
      sudo sh ${CROUTON_PATH} -n ${DISTRO} -u;
    breakLine;
  else
    echo "Linux must be installed on your system first!";
  fi
  exit;
}
###############################################################


## Main Application
###############################################################
while true; do
  read -p " - $1 Install (i) or Update(u) your Linux environment?: " CHOICE
  case ${CHOICE} in
    [Ii]* ) install && configure;;
    [Uu]* ) update;;
  esac
done
###############################################################
