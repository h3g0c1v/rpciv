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
  echo -e "\n\n${red}[!]${end}${gray} Exiting ...\n${end}"
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

    echo -e "\n${red}[!]${end}${gray} Null session is not available${end}"
    return 1

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
  echo -e "${gray}   help, h\t\t\t\t➜    Show this help panel${end}"
  echo -e "${gray}   clear, c\t\t\t\t➜    Clear the screen${end}"
  echo -e "${gray}   exit, e\t\t\t\t➜    Terminate the program${end}"
  echo -e "${gray}   whoami, w\t\t\t\t➜    Who am I executing commands${end}"
  echo -e "${gray}   list prompts, l p\t\t\t➜    List available prompts"
  echo -e "${gray}   prompt NUMBER\t\t\t➜    Change prompt (Show Available Prompts with \"list prompts\")${end}"

  echo -e "\n${yellow}[i] ${end}${gray}Users / Groups Commands:${end}\n"
  echo -e "${gray}   show users, s u\t\t\t➜    Show available users list${end}"
  echo -e "${gray}   show groups, s g\t\t\t➜    Show available group list${end}"
  echo -e "${gray}   show users description, s u d\t➜    Show available description about users"
  echo -e "${gray}   show groups descriptions, s g d\t➜    Show available description about groups"
}

# Who Am I
function whoAmI () {
  echo -e "\n${gray}Current User: ${end}${yellow}$userConnect${end}"
}

function changePrompt () {

  case "$command" in
    prompt\ [0-7])
      declare -i num=$(echo "$command" | awk '{print $2}')
      definePrompts
      
      selectedPrompt="prompt$num"
      prompt=${!selectedPrompt}

      return 0 ;;
    *) echo -e "\n${red}[!] ${end}${gray}You must specify the desired prompt. Example: ${end}${yellow}prompt 1${end}"; return 1 ;;
  esac
}

function definePrompts () {
  prompt1="[$userConnect] >"
  prompt2ToShow="╭─[$userConnect] \n           ╰─> "
  prompt2="╭─["$userConnect"] \n╰─>"
  prompt3="$userConnect@tool:~$"
  prompt4="[0x\\$userConnect]"
  prompt5="[🌟 $userConnect] ~>"
  prompt6="<< $userConnect >> $"
  prompt7="[💻 $userConnect] >"
}

function showAvailablePrompts () {
  definePrompts

  echo -e "\n${yellow}[i] ${end}${gray} Available Prompts:${end}\n"

  declare -i counter=1
  for promptType in "$prompt1" "$prompt2ToShow" "$prompt3" "$prompt4" "$prompt5" "$prompt6" "$prompt7"; do
    echo -e "${gray}  [$counter]  ➜${end}   ${blue}$promptType${end} ${gray}command${end}\n"

    counter+=1
  done

  return $counter
}

# Show available users list
function showUsersGroups () {
  command="$1"
  filter="$2"
  objectInTable="$3"

  # Getting the list of users
  # (both regular expressions with "sed" are because the user names can contain characters like "[" or "]" so,
  # we have to make sure that the regular expression works)

  if [ $nullSession ]; then
    objects=$(rpcclient -N $ipAddress -U '' -c "$command" | sed -e "s/$filter:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
  else
    objects=$(rpcclient $ipAddress -U "$username%$password" -c "$command" | sed -e "s/$filter:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
  fi

  echo -e "${green}"
  displayTable "$objects" "$objectInTable"
  echo -e "${end}"
}

# Function to show th description of any user and group
function showDescription {
  objectToShowDescription="$1"

  if [ $nullSession ]; then
    usersList=$(rpcclient -N $ipAddress -U '' -c "enumdomusers" | sed -e "s/user:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
    groupsList=$(rpcclient -N $ipAddress -U '' -c "enumdomgroups" | sed -e "s/group:\[.*rid:\[/#/g" | tr -d '#]')
  else
    usersList=$(rpcclient $ipAddress -U "$username%$password" -c "enumdomusers" | sed -e "s/user:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
    groupsList=$(rpcclient $ipAddress -U "$username%$password" -c "enumdomgroups" | sed -e "s/group:\[.*rid:\[/#/g" | tr -d '#]')
  fi

  case "$objectToShowDescription" in
    "users") 
      echo -e "\n${yellow}[i]${end}${gray} Showing users description${end}"
      describeUsersAndGroups "$usersList" "queryuser" ;;

    "groups")
      echo -e "\n${yellow}[i]${end}${gray} Showing groups description${end}"
      describeUsersAndGroups "$groupsList" "querygroup"
  esac
}

function describeUsersAndGroups () {
  list="$1"
  RpcCommand="$2"

  declare -i counter=1
  for object in $(echo $list); do
    if [ $nullSession ]; then
      description=$(rpcclient -N $ipAddress -U '' -c "$RpcCommand $object" | grep 'Description' | cut -f 2 -d ':' | tr -d '\t')
    else
      description=$(rpcclient $ipAddress -U "$username%$password" -c "$RpcCommand $object" | grep 'Description' | cut -f 2 -d ':' | tr -d '\t')
    fi

    if [ "$description" ]; then
      if [ "$RpcCommand" == "queryuser" ]; then
        showObject="$object"
      elif [ "$RpcCommand" == "querygroup" ]; then
        if [ $nullSession ]; then
          showObject=$(rpcclient $ipAddress -U "$username%$password" -c "querygroup $object" | grep 'Group Name' | cut -f 2 -d ':' | tr -d '\t')
        else
          showObject=$(rpcclient $ipAddress -U "$username%$password" -c "querygroup $object" | grep 'Group Name' | cut -f 2 -d ':' | tr -d '\t')
        fi
      fi

      printf "\n${green}%-20s${end} ${gray}:${end} ${green}%s${end}\n" "$showObject" "$description"
      counter+=1
    fi
  done
}

# Function to display a table with the contents of a variable
function displayTable() {
  local variable="$1"
  local objectInTable="$2"
  local IFS=$'\n' # Internal Field Separator set to newline
  local -a items # Array to store the elements of the variable

  # Convert the variable into an array, splitting by newlines
  read -d '' -ra items <<< "$variable"

  # Calculate the maximum width of the content column (including the header "Username")
  local max_length=8 # Minimum width to fit "Username"
  for item in "${items[@]}"; do
    if (( ${#item} > max_length )); then
      max_length=${#item}
    fi
  done

  # Set the table width (6 characters for "No.", max_length for "Username", and 4 for spaces and borders)
  local table_width=$((6 + max_length + 3))

  # Function to print a horizontal line
  print_line() {
    printf "+%s+\n" "$(printf '%*s' "$table_width" | tr ' ' '-')"
  }

  # Function to print a row
  print_row() {
    printf "| %-6s %-*s |\n" "$1" "$max_length" "$2"
  }

  # Print the table
  print_line
  print_row "No." "$objectInTable"
  print_line

  local count=1
  for item in "${items[@]}"; do
    print_row "$count" "$item"
    ((count++))
  done

  print_line
}

# MAIN
# **************************************************************************************************** 
declare -i parameter_counter=0 # Counter to control de parameters

# Getting parameters
while getopts "hu:p:n" arg; do
  case $arg in
      h) helpGlobalPanel; exit 0;; # Help Script Panel
      u) username="$OPTARG"; let parameter_counter+=1;;
      p) password="$OPTARG"; let parameter_counter+=2 ;;
      n) nullSession=true; let parameter_counter+=4 ;; # Define a Null Session
  esac
done

# Checks
# ----------------------------------------------------------------------------------------------------
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

if [[ ! $ipAddress ]]; then # Checking the correct IP address
  echo -ne "${red}[!]${end}${gray} IP Address is required${end}\n"
  helpGlobalPanel
  exit 1
fi

checkConnection || exit 1 # Check the RPC connection
# End of checks
# ----------------------------------------------------------------------------------------------------

prompt="[$userConnect] >" # Default prompt - [USERNAME] > 

while true; do
  echo -ne "\n${blue}$prompt ${end}${white}" && read command # Command input

  case "$command" in
    "help"|"H"|"h") helpPanel ;; # Command Help Panel
    $'\f'|"clear"|"c") clear ;;
    "exit"|"e") exit 0 ;;
    "whoami"| "w") whoAmI ;; # Print the current user
    "list prompts"|"l p") showAvailablePrompts ;;
    prompt*) changePrompt "$command" ;; # You can change de prompt
    "show users"|"s u") showUsersGroups "enumdomusers" "user" "Username" ;; # Showing existing users
    "show groups"|"s g") showUsersGroups "enumdomgroups" "group" "Group" ;; # Showing existing groups 
    "show users description"|"s u d") showDescription "users" ;;
    "show groups descriptions"|"s g d") showDescription "groups" ;;
    "");;
    *) echo -e "\n${red}[!]${end}${gray} Command NOT recognized${end}"; helpPanel;;
  esac
done
