#!/bin/bash
###########################################################################
#This Script can help you to fix grub issue after installing windows
###########################################################################

#Written By Mohamed Elsiddig 


#########################################################################
#The part_find Function find the partition that contained the distro
#########################################################################

function part_find()
{
    echo ""
    echo "Checking For Any Linux Installation in the Hard Disk ...!!"
    echo ""
    sleep 1
    for partition in $(fdisk -l | grep /dev/sda | cut -f1 -d' '|cut -f1 -d'D'| sed '/^$/d')
        do 
            echo -e "$white Checking $partition$normal"
            mount $partition /media/ > /dev/null 2>&1
            if [ -d /media/boot/grub ]
                then 
                    sleep 2
                    echo -e " $light_green[ ✔ ]$normal$white Found a linux distro in $partition Proceeding with installation"
                    umount /media/ > /dev/null 2>&1
                    sleep 1
                    echo -e " $light_cyan[ * ]$light_blue Operating on $white$partition$normal"
                    sleep 3
                    echo ""
                    grub_fix
                else 
                    sleep 2
                    echo -e " $red[ X ]$white nothing Here Moving To The Next Partition ...!!"
                    umount /media/ > /dev/null 2>&1
                    echo ""
            fi
    done 
}


################################################################
#The Check Root Function Check For the Root Privilege
################################################################

function chk_root()
{
    if [ $(id -u) != 0 ]
        then
        echo ""
        echo -e $red [x]$cyan::[$red You are not root $cyan]: You need to be [$red root $cyan] to run this script.$normal
        echo ""
        sleep 3
        exit 1
    fi
}


###################################################################
#The Grub Fix Function executes commands thats fix the grub
###################################################################

function grub_fix()
{
    #echo -en "$light_cyan [ * ]$light_blue Please Enter the target os partition:$normal "
    #read partition
    if [[ ! -d $partition && -e $partition ]]
        then
            echo -en 
            mount $partition /mnt
            for fs_mount  in /dev/ /proc/ /run/ /sys/ 
                do
                    echo " "
                    echo -e "$orange [ ☣ ]$normal$yellow Mounting $white$fs_mount$yellow Virtual File System ...$normal"
                    sleep 2
                    mount --bind $fs_mount /mnt/$fs_mount > /dev/null 2>&1
            done
            echo " "
            echo -e "$orange [ ☣ ]$yellow Installing The new grub ..."
            chroot /mnt  grub-install /dev/sda > /dev/null 2>&1
            echo ""
            echo -e "$orange [ ☣ ]$yellow Updating The new grub ..."
            chroot /mnt  update-grub > /dev/null 2>&1
            if [ $? -eq 0 ]
                then
                    sleep 2
                    echo " "
                    echo -e " $light_green[ ✔ ]$normal$light_cyan Installation Complete $normal" 
                    sleep 2
                    echo " "
                    echo -en " $light_cyan[ * ]$light_blue Do you want to reboot now!! ($light_green yes$light_blue/$red no $light_blue):$normal"
                    read option 
                    if [[ ! -z $option && $option = "yes" || "$option" = "y" ]]
                        then
                        echo " "
                        echo -e "$orange [ ☣ ]$yellow Rebooting System ...! "
                        sleep 2
                        reboot
                    elif [[ -n $option && $option = "no" || $option = "n" ]] 
                        then
                            echo " "
                            echo -e $orange "Quiting The Script \n" $normal
                            exit 0
                        else
                            echo " "
                            echo -e $red\"$option\"$normal$orange is not an option$orange "Quiting The Script \n" $normal
                    fi
                else
                echo " "
                echo -en "$red [ X ] Grub ReInstallation Failed !!\n\tTry to execute the steps Manually\n\n$normal"
                exit 1
            fi
    else
        echo -e " "
        echo -e $red "[ X ]$normal$white Couldn't Find a linux installation in the Hard Disk !!\n" $normal
        exit 1
    fi
}


normal='\e[0m'
cyan='\e[0;36m'
red='\e[1;31m'
green='\e[0;32m'
light_green='\e[1;32m'
white='\e[0;37m'
yellow='\e[0;33m'
light_blue='\e[1;34m'
orange='\e[38;5;166m'
light_cyan='\e[1;36m'


chk_root
echo " "
echo -e "$white [ Tip ]::$cyan To exit press Ctrl C\n$normal"
sleep 2
part_find
