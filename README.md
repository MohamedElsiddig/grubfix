# grubfix
One of the most common problems facing new linux users is when they dual booting with windows or when they need to install windows after trying linux and they completely feel confused when windows only booting up and the grub menu vanished.

Usually, for experienced users it's ordinary thing to reinstall grub once again but when come to new users it might be complex.

using this shell script shall help new users to reinstall grub
it has been tested on ubuntu. It's also support both legacy and efi modes.
Please feel free for giving your opinion.

# Usage:

Run the script from linux live cd (Tested on ubuntu):

* To manually enter the linux installation partition run

```bash
sudo ./grub_fix.sh
```

* To automatically detect the linux partition run

```bash
sudo ./grub_fix_autoDetect.sh
```

  ![](https://thepracticaldev.s3.amazonaws.com/i/98jbnwn8q3ebjhymhj1z.jpg)
