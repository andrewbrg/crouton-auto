
# Linux 16.04 (Xenial) dual OS on ChromeOS via Crouton
   
   
![3fa4bf29a8d83625909b76abb99537e9.jpg](http://pichoster.net/images/2017/10/03/3fa4bf29a8d83625909b76abb99537e9.jpg)
   
   
Download latest version here: [https://goo.gl/EYStRG](https://goo.gl/EYStRG) _(open->right click->save as)_

This is a handy script to automatically set up an Ubuntu dev machine on your chromebook. The Ubuntu will be installed in a chroot along with your current Chrome operating system _(you can run two operating systems in parallel)_. The Crouton project is developed/maintained by David Schneider @ https://github.com/dnschneid  

**This script is made for AMD64 processors**, if you have an ARM processor some packages will not function. Fully tested on Acer Chromebook 14.

Your Chromebook must be in developer mode in order to use this script. It is also highly recommended that you install the crouton chrome extension for added functionality including a shared clipboard between operating systems. You may get the latest version directly from the [chrome store](https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom)

**Resources to check out** 

| Type | Link |
| ------ | ------ |
| Crouton GitHub | https://github.com/dnschneid/crouton |
| Crouton Cheatsheet | https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet |
| Crouton Wiki | https://github.com/dnschneid/crouton/wiki |
  
***

## What is a chroot?

A chroot is basically a special directory on your computer which prevents applications, if run from inside that directory, from accessing files outside the directory. In many ways, a chroot is like installing another operating system inside your existing operating system.

Technically-speaking, chroot temporarily changes the root directory (which is normally /) to the chroot directory (for example, /var/chroot). As the root directory is the top of the filesystem hierarchy, applications are unable to access directories higher up than the root directory, and so are isolated from the rest of the system. This prevents applications inside the chroot from interfering with files elsewhere on your computer.

Note that it is possible for software from outside the chroot to access files inside the chroot.
  
## Ready? let's go!

After placing your Chromebook into developer mode, launch a crosh terminal by hitting `CTRL+ALT+T` then type in the following commands:

```shell
shell  
sudo sh ~/Downloads/getUbuntu.sh
```
This will open a menu where you can install, backup, or update your chroot.
After the installation is complete you can launch Ubuntu by opening a crosh terminal `CTRL+ALT+T` and executing:

```shell
shell  
sudo startgnome
```

If you want to be able to close the crosh terminal without Ubuntu un-mounting itself as a consequence use the following:

```shell
shell
sudo startgnome -b
```

Once in Ubuntu i'd recommend loading up the Gnome Tweak Tool _(which has been pre-installed by this script)_ and selecting the `global dark theme` and the `numix-circle` icons, as well as the `paper` icon theme.. Also go ahead and enable the `Pomodoro`, `Dash to dock` and any other UI shell extensions within the Gnome Tweak Tool as desired.

To switch between operating systems hit `CTRL+ALT+SHIFT+FORWARD` or `CTRL+ALT+SHIFT+BACKWARDS`.

It's important to logout from Ubuntu once before powering down your system to avoid potential corruption to the mounted root.

## Updating your chroot
Run the script and select "Update Ubuntu" to update between Ubuntu versions (e.g. 16.04 to (when it comes out)18.04)
Select "update crouton" if your chroot is acting up (generally this happens after Chrome OS update)
