
# Linux 16.04 Xenial on ChromeOS via Crouton
   
   
![3fa4bf29a8d83625909b76abb99537e9.jpg](http://pichoster.net/images/2017/10/03/3fa4bf29a8d83625909b76abb99537e9.jpg)
   
This is a handy script to automatically set up an Ubuntu dev machine on your chromebook. The Ubuntu will be installed in a chroot along with your current Chrome operating system (you can run two operating systems in parallel). The Crouton project is developed/maintained by David Schneider @ https://github.com/dnschneid  

**This script is made for AMD64 processors**, if you have an ARM processor some packages will not function. Fully tested on Acer Chromebook 14.

Your Chromebook must be in developer mode in order to use this script. It is also highly recommended that you install the chrome crouton extension for added functionality.

**Resources to check out** 

| Type | Link |
| ------ | ------ |
| Crouton Git | https://github.com/dnschneid/crouton |
| Crouton Cheat Sheet | https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet |
| Crouton Wiki | https://github.com/dnschneid/crouton/wiki |
| Crouton Chrome Extension | https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom |
  
***
  
**Ready? let's go!** After placing your Chromebook into developer mode, launch a crosh terminal by hitting `CTRL+ALT+T` then type in the following commands:

```shell
shell  
sudo sh ~/Downloads/getUbuntu.sh
```

After the installation is complete you can launch Ubuntu by opening a crosh terminal `CTRL+ALT+T` and executing:

```shell
shell  
sudo startgnome -b
```

Once in Ubuntu i'd recommend loading up the Gnome Tweak Tool _(which has been pre-installed)_ and selecting the `global dark theme` and the `numix-circle` icons. To switch between operating systems hit `CTRL+ALT+SHIFT+FORWARD` or `CTRL+ALT+SHIFT+BACKWARDS`
