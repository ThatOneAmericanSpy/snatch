#!/bin/bash

cmd="$1"
pkg="$2"

confirm() {
    while true; do
        echo "$1"
        read -p "" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

if [ "$cmd" == "-S" ]; then
    if [ "$(curl -s https://aur.archlinux.org/rpc/v5/info?arg[]="$pkg" | jq '.resultcount')" == 0 ]; then
        echo "No package named ${pkg}"
        exit 1
    fi

    if confirm "Install package? (y/n)"; then
        echo "Fetching..."
        git clone "https://aur.archlinux.org/${pkg}.git"
        cd "$pkg"
        makepkg -si
        if confirm "Clear leftover build files? (y/n)"; then
            cd ..
            rm -rf ./"$pkg"
        fi
        echo "Installed package successfully"
    else
        echo "Canceled"
        exit 0
    fi
elif [ "$cmd" = "-U" ]; then
    if [ "$EUID" -ne 0 ]; then
        exec sudo "$0" "$@"
    fi
    echo "Checking AUR for updates..."
    for p in $(pacman -Qqme); do
        if [[ $p == *-debug ]]; then
            continue
        fi
        echo -en "\033[KChecking $p...\r"
        old=$(pacman -Q $p | sed 's/.* //')
        new=$(curl --compressed -s "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=$p" | jshon -e results -a -e Version | awk -F\" '{print $2}')
        if [ $new ]; then
            cmp=$(vercmp $new $old)
            if [ "$cmp" -eq 1 ]; then
                echo -e "\033[K$p $old -> $new\033[K"
                git clone "https://aur.archlinux.org/$p.git"
                if cd "$p"; then
                    makepkg -si
                    rm -rf "$p" # cleaning everything up
                    cd ..
                fi
            else
                echo -e "\033[0;34m"$p is up to date"\033[0m"
            fi
        else
            echo -e "\033[0;31m$p $old -> Not Found\033[0m"
        fi
    done
    echo "Checking pacman repositories for updates..."
    sudo pacman -Syu
    exit 0

else
    echo "
    Correct Syntax:

        -S | Install package
        -U | Upgrade package
    "
    exit 1
fi

