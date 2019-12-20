#!/bin/bash

function select_listed_mac
{
    printf '\n List Of Saved MAC \n'
    count=0
    declare -a mac_array=()
    while read -r line; do
        count=$(expr $count + 1)
        echo "[$count] $line"
        mac_array+=($line)
    done < macList.txt

    if [ $count -eq 0 ]; then
        echo '--- No MACs Found ---'
    fi

    printf '\nSelect A MAC from this list : '
    read mac_index
    mac_index=$(($mac_index - 1))

    change_mac ${mac_array[$mac_index]}
}

function select_random_mac
{
    count=0
    declare -a mac_array=()
    while read -r line; do
        count=$(expr $count + 1)
        mac_array+=($line)
    done < macList.txt

    if [ $count -eq 0 ]; then
        echo '--- No MACs Found ---'
    fi

    # Generate random number b/w 0 & count
    mac_index=$((RANDOM % count))

    # Change MAC
    change_mac ${mac_array[$mac_index]}
}

function reset_default_mac
{
    echo '\n*** Restting MAC ***\n'
    ip link set $if_name down
    macchanger -p $if_name
    ip link set $if_name up
}

function change_mac
{
    printf '\n*** Changing MAC ***\n'
    ip link set $if_name down
    macchanger -m $1 $if_name
    ip link set $if_name up
}

# /////////////////////////
# Program Starts From Here
# /////////////////////////

#check for root permission
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Get Interface Name From User
printf "Enter Netwok Interface Name : "
read if_name

# validate input value 0 < interface name < 12
if [ ${#if_name} -le 0 ] || [ ${#if_name} -gt 12 ]; then
    echo 'ERROR : Not A Valid Input'
    exit
fi

# While Menu
while true; do
    printf "\n===[ MAC Selector ]===\n"
    printf '\n1) Select MAC from List'
    printf '\n2) Set Random MAC From List'
    printf '\n3) Reset Default MAC'
    printf '\nChoose Other Option To Exit'
    printf '\n\nChoose Option : '
    read option

    if [ "$option" = "1" ]; then
        select_listed_mac
        exit
    elif [ "$option" = "2" ]; then
        select_random_mac
        exit
    elif [ "$option" = "3" ]; then
        reset_default_mac
        exit
    else
        exit
    fi
done