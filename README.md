
# Linux 16.04 Xenial on ChromeOS via Crouton
   
   
![3fa4bf29a8d83625909b76abb99537e9.jpg](http://pichoster.net/images/2017/10/03/3fa4bf29a8d83625909b76abb99537e9.jpg)
   
This is a handy script to automatically set up an Ubuntu dev machine on your chromebook. Crouton is developed and maintained by David Schneider https://github.com/dnschneid  

**This script is built for AMD64 processors**, if you have an ARM cpu some packages will not function.

Your Chromebook must be in developer mode in order to use this script.

**A few vital resources before getting started.** 

| Type | Link |
| ------ | ------ |
| Official Crouton Git | https://github.com/dnschneid/crouton |
| Crouton Cheat Sheet | https://github.com/dnschneid/crouton/wiki/Crouton-Command-Cheat-Sheet |
| Crouton Wiki | https://github.com/dnschneid/crouton/wiki |
| Crouton Chrome Extension | https://chrome.google.com/webstore/detail/crouton-integration/gcpneefbbnfalgjniomfjknbcgkbijom |
  
***
  
**Ready? let's go!** After placing your Chromebook into developer mode, launch a crosh terminal by hitting `CTRL+ALT+T` then type in the following commands:

```shell
shell  
sudo sh ~/Downloads/getUbuntu.sh
```

After the installation is complete you can launch Ubuntu by oepning a crosh terminal and executing:

```shell
shell  
sudo startgnome -b
```

To switch between operating systems hit `CTRL+ALT+FORWARD` or `CTRL+ALT+BACKWARDS`
