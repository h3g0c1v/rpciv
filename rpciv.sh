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

function checkConnection () {
  if [[ $nullSession ]]; then
    rpcclient -N $ipAddress -U '' -c "getusername" &>/dev/null
    
    if [ $? -eq 0 ]; then
      userConnect=$(rpcclient -N $ipAddress -U '' -c "getusername" | cut -f 2 -d ":" | cut -f 1 -d "," | sed "s/^ //g")
      return 0
    fi

  else
    rpcclient $ipAddress -U "$username%$password" -c "getusername" &>/dev/null 

    if [ $? -eq 0 ]; then
      userConnect=$(rpcclient -U "$username%$password" $ipAddress -c "getusername" | cut -f 2 -d ":" | cut -f 1 -d "," | sed "s/^ //g")
      return 0
    fi
  fi 

  echo -e "\n${red}[!]${end}${gray} Invalid Credentials!${end}"
  return 1
}

# Help Global Panel
function helpGlobalPanel () {
  echo -e "\n${yellow}[i] ${end}${gray}Use: $0 [-u USERNAME -p PASSWORD] [-n] IP_ADDRESS${end}\n"
  echo -e "${gray}   -u, --username\t➜    Set username${end}"
  echo -e "${gray}   -p, --password\t➜    Set password${end}"
  echo -e "${gray}   -n, --null-session\t➜    Connect using a null session${end}"
}

# Help Commands Panel
function helpPanel () {
  echo -e "\n${yellow}[i] ${end}${gray}Generic Commands:${end}\n"
  echo -e "${gray}   help, h\t\t\t➜    Show this help panel${end}"
  echo -e "${gray}   clear, c\t\t\t➜    Clear the screen${end}"
  echo -e "${gray}   exit, e\t\t\t➜    Terminate the program${end}"
  echo -e "${gray}   whoami, w\t\t\t➜    Who am I executing commands${end}"

  echo -e "\n${yellow}[i] ${end}${gray}Users / Groups Commands:${end}\n"
  echo -e "${gray}   show users, s u\t\t➜    Show available users list${end}"
  echo -e "${gray}   show groups, s g\t\t➜    Show available group list${end}"
  echo -e "${gray}   show user info, s u i\t➜    Show information about available username / rid${end}"
  echo -e "${gray}   show group info, s g i\t➜    Show information about available groupname / rid${end}"
}

# Show available users list
function showUsers () {
  echo "showUsers"
}

# Who Am I
function whoAmI () {
  echo -e "\n${gray}Current User: ${end}${yellow}$userConnect${end}"
}

# Main
declare -i parameter_counter=0

# Getting parameters
while getopts "hu:p:n" arg; do
  case $arg in
      h) helpGlobalPanel; exit 0;;
      u) username="$OPTARG"; let parameter_counter+=1;;
      p) password="$OPTARG"; let parameter_counter+=2 ;;
      n) nullSession=true; let parameter_counter+=4 ;;
  esac
done

if [[ ("$username" || "$password") && $nullSession ]]; then
  echo -ne "\n${red}[!]${end}${gray} Null Session is not compatible with -u and -p${end}\n"
  helpGlobalPanel
  exit 1
fi

if [[ $parameter_counter -eq 1 || $parameter_counter -eq 2 || $parameter_counter -gt 4 ]]; then
  echo -ne "\n${red}[!]${end}${gray} Bad used\n${end}"
  helpGlobalPanel
  exit 1
fi

shift $((OPTIND -1)) && ipAddress="$1"

if [[ ! $ipAddress ]]; then
  echo -ne "${red}[!]${end}${gray} IP Address is required${end}\n"
  helpGlobalPanel
  exit 1
fi

checkConnection || exit 1 # Check the RPC connection

while true; do
  echo -ne "\n${blue}[$userConnect] > ${end}${white}" && read command

  case "$command" in
    "help"|"H"|"h") helpPanel ;;
    $'\f'|"clear"|"c") clear ;;
    "exit"|"e") exit 0 ;;
    "whoami"| "w") whoAmI ;;
    "show users"|"s u") showUsers ;;
  esac
done
