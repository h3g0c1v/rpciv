#!/bin/bash

# Author: H3g0c1v
# GitHub: https://github.com/h3g0c1v/
# LinkedIn: https://www.linkedin.com/in/h%C3%A9ctor-civantos-cid-aka-hegociv-5ab997212/

# Colours
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;310m\033[1m"

# Ctrl + C
function ctrl_c () {
  echo -e "\n\n${red}[!]${end}${gray} Saliendo ...\n${end}"
  exit 1
}

trap ctrl_c SIGINT

# Help Panel
function helpPanel () {
  echo -e "\n${yellow}[i] ${end}${gray}Generic Commands:${end}\n"
  echo -e "${gray}   help, h\t\t\t➜    Show this help panel${end}"
  echo -e "${gray}   clear, c\t\t\t➜    Clear the screen"
  echo -e "${gray}   whoami, w\t\t\t➜    Who am I executing commands${end}"

  echo -e "\n${yellow}[i] ${end}${gray}Users / Groups Commands:${end}\n"
  echo -e "${gray}   show users, s u\t\t➜    Show available users list${end}"
  echo -e "${gray}   show groups, s g\t\t➜    Show available group list${end}"
  echo -e "${gray}   show user info, s u i\t➜    Show information about available user${end}"
  echo -e "${gray}   show group info, s g i\t➜    Show information about available group${end}"

}

# Show available users list
function showUsers () {
  echo "showUsers"
}

# Main
while true; do
  echo -ne "\n${blue}[command] > ${end}${white}" && read command
  case $command in 
    "help"|"H"|"h") helpPanel;;
    "show users"|"s u") showUsers;;
  esac
done
