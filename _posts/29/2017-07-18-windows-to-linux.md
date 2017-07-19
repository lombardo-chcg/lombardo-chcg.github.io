---
layout: post
title:  "windows to linux"
date:   2017-07-18 22:21:52
categories: environment
excerpt: "installing ubuntu on an old windows pc"
tags:
  - linux
---

*The Task*

I have an old Windows 7 machine.  It is painfully slow to even open a web browser.

Let's install Ubuntu on it!  We'll even use the Windows machine to prepare it's own end.  Poetic, that.

*The Steps*

1. Grab a USB Drive with at least 2gb capacity
2. If the drive was formatted for a Mac, follow these steps to reformat using the Windows `CMD` prompt: [https://superuser.com/questions/274687/how-do-i-format-a-usb-drive-on-a-pc-that-was-formatted-on-a-mac](https://superuser.com/questions/274687/how-do-i-format-a-usb-drive-on-a-pc-that-was-formatted-on-a-mac) (use the steps provided by user Bacon Bits)
3. Download the Ubuntu ISO: [https://www.ubuntu.com/download/desktop](https://www.ubuntu.com/download/desktop)   
4. Just dropping the ISO file to the USB storage volume is not enough.  We need to make it a bootable USB drive.  Down the Rufus utility to make a USB drive bootable:  [https://rufus.akeo.ie/](https://rufus.akeo.ie/)
* (more on iso lineage: [https://en.wikipedia.org/wiki/ISO_image](https://en.wikipedia.org/wiki/ISO_image))
5. Use this guide to walk thru the Rufus prompts to create the bootable drive: [https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-windows#0](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-windows#0)
6. Backup anything on the Windows machine you want to save.  Use another USB drive tho.
7. Restart the Windows OS.  As it boots up, press f12 repeatedly to arrive at the boot menu option, and choose to boot from USB
8. When the Ubuntu prompt arrives, choose Install and continue with the wizard.  You can choose to have a "dual boot" installation where Windows remains an option.  Or, you can go for it.
9. Have fun exploring the new OS!
