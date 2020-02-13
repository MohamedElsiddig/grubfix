#!/bin/bash
###########################################################################
#This Script can help you to fix grub issue after installing windows
###########################################################################

##Written By Mohamed Elsiddig 

################################################################
#The check_efi Function check if there any efi  partition 
################################################################
function check_efi()
{
    echo -e "$light_cyan [ * ]$light_blue Checking for UEFI Instalation$normal " 
    sleep 3
    echo " "
    if [ -d /sys/firmware/efi ] 
        then
            sleep 2
            echo -e "$light_cyan [ * ]$light_blue Found an EFI Instalation$normal " 
            echo " "
            efi_mode=true
            echo -e "$light_cyan [ * ]$light_blue Please select the EFI partition:$normal "
        echo " "
        select efi_dev in $(sudo fdisk -l 2>/dev/null |grep -i 'efi' | sed -n 's#\(/dev/[^[:blank:]]*\).*#\1#p') 'No uefi'
            do
                if [ "$efi_dev" != 'No uefi' ]
                    then
                        echo ""
                        echo -e "$light_cyan [ * ]$light_blue you have chosen: $efi_dev$normal "
                        sleep 3
                        echo ""
                        break
                    else
                        echo ""
                        sleep 3
                        echo -e "$light_cyan [ * ]$white It seem's that your boot media booted in EFI mode but no\n\t EFI partion was selected please create an efi partion and try again ..\n$normal "
                        sleep 2
                        echo -e "$light_cyan [ * ]$white Please refers to this link to learn how to create an EFI partion\n\t https://help.ubuntu.com/community/UEFI ..\n$normal "
                        sleep 2
                        echo -en "$red [ X ] Grub Re-Installation Aborted ..\n\n$normal"
                        exit 1
                fi
            done
        else
            sleep 3
            echo -e "$light_cyan [ * ]$light_blue No UEFI device.. Using legacy mode..$normal "
            efi_mode=false
            sleep 2
    fi
    
    
}

#########################################################################
#The part_find Function find the partition that contained the distro
#########################################################################

function part_find()
{
    echo ""
    echo "Checking For Any Linux Installation in the Hard Disk ...!!"
    echo ""
    sleep 1
    for partition in $(fdisk -l 2>/dev/null |grep -i 'linux' | grep -iv 'swap' | sed -n 's#\(/dev/[^[:blank:]]*\).*#\1#p')
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
                    echo -e " $red[ X ]$white Nothing Here Moving To The Next Partition ...!!"
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
    sleep 2
    check_efi
    if [[ $efi_mode=fales ]]
        then
            #echo -en "$light_cyan [ * ]$light_blue Please Enter the target os partition:$normal "
            #read partition
            if [[ ! -d $partition && -e $partition ]]
                then
                    echo -en 
                    mount $partition /mnt
                    for fs_mount  in /dev/ /proc/ /run/ /sys/ 
                        do
                            echo " "
                            echo -e "$orange [ ☣ ]$normal$yellow Mounting $white$fs_mount$yellow Virtual File System ..."
                            sleep 2
                            mount --bind $fs_mount /mnt/$fs_mount > /dev/null 2>&1
                    done
                    echo " "
                    echo -e "$orange [ ☣ ]$yellow Installing The new grub ..."
                    chroot /mnt grub-install "${partition:0:-1}" > /dev/null 2>&1
                    if [ $? -eq 0 ]
                        then
                            sleep 2
                            echo " "
                            echo -e " $light_green[ ✔ ]$normal$light_cyan Installation Complete " 
                            sleep 2
                            echo ""
                            echo -e "$orange [ ☣ ]$yellow Running update-grub ..."
                            chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
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
    else
        if [[ ! -d $partition && -e $partition ]]
                then
                    echo -en 
                    mount $partition /mnt
                    for fs_mount  in /dev/ /proc/ /run/ /sys/ 
                        do
                            echo " "
                            echo -e "$orange [ ☣ ]$normal$yellow Mounting $white$fs_mount$yellow Virtual File System ..."
                            sleep 2
                            mount --bind $fs_mount /mnt/$fs_mount > /dev/null 2>&1
                    done
                    echo " "
                    echo -e "$orange[ ☣ ]$yellow Running mount $efi_dev /boot/efi ..."
                    chroot /mnt mount $efi_dev /boot/efi > /dev/null 2>&1
                    sleep 2
                    echo " "
                    echo -e "$orange [ ☣ ]$yellow Installing The new grub ..."
                    chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi > /dev/null 2>&1
                    if [ $? -eq 0 ]
                        then
                            sleep 2
                            echo " "
                            echo -e " $light_green[ ✔ ]$normal$light_cyan Installation Complete " 
                            sleep 2
                            echo -e "$orange [ ☣ ]$yellow Running update-grub ..."
                            chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
                            sleep 2
                            echo -e "$orange [ ☣ ]$yellow Running umount /boot/efi"
                            chroot /mnt umount /boot/efi
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
