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

  timeout 1 bash -c "ping -c 1 $ipAddress &>/dev/null" # Testing connection

  if [ $? -ne 0 ]; then
    echo -e "\n${red}[!]${end}${gray} Connection refused${end}" # No connectivity
    exit 1
  else 
    if [[ $nullSession ]]; then # Null session indicated
      rpcclient -N $ipAddress -U '' -c "getusername" &>/dev/null # Obtaining the current user

      if [ $? -eq 0 ]; then
        userConnect=$(rpcclient -N $ipAddress -U '' -c "getusername" | cut -f 2 -d ":" | cut -f 1 -d "," | sed "s/^ //g") # Null Session is available
        return 0
      fi
  
      echo -e "\n${red}[!]${end}${gray} Null session is not available${end}" # Null Session is not available
      return 1
  
    else # Credentials provided
      rpcclient $ipAddress -U "$username%$password" -c "getusername" &>/dev/null # Obtaining the current user
  
      if [ $? -eq 0 ]; then
        userConnect=$(rpcclient -U "$username%$password" $ipAddress -c "getusername" | cut -f 2 -d ":" | cut -f 1 -d "," | sed "s/^ //g") # Credentials are correct
        return 0
      fi
    fi
  fi
  
  echo -e "\n${red}[!]${end}${gray} Invalid Credentials!${end}" # Invalid credentials
  return 1
}

# Function to check the existence of a group
function checkUserGroupExistence () {
  selectedObject=$(echo "$1" | cut -f 4- -d ' ') # Defining the user/group
  objects="$2"
  filter="$3"

  echo "$objects" | grep -iE "^$selectedObject$" &>/dev/null # Checking if the provided user/group exists

  if [ $? -eq 0 ]; then
    return 0 # The provided group exist, return 0
  fi
  
  return 1 # The provided group does NOT exist, return 1
}

# Help Global Panel (How to use)
function helpGlobalPanel () {
  echo -e "\n${yellow}[i] ${end}${gray}Use: $0 [-u USERNAME -p PASSWORD] [-n] IP_ADDRESS${end}\n"
  echo -e "${gray}   -u, --username\t➜    Set username${end}"
  echo -e "${gray}   -p, --password\t➜    Set password${end}"
  echo -e "${gray}   -n, --null-session\t➜    Connect using a null session${end}"
}

# Help Commands Panel (Available Commands)
function helpPanel () {
  echo -e "\n${yellow}[i] ${end}${gray}Generic Commands:${end}\n"
  echo -e "${gray}   help, h\t\t\t\t➜    Show this help panel${end}"
  echo -e "${gray}   clear, c, CTRL + L ENTER\t\t➜    Clear the screen${end}"
  echo -e "${gray}   exit, e\t\t\t\t➜    Terminate the program${end}"
  echo -e "${gray}   whoami, w\t\t\t\t➜    Who am I executing commands${end}"
  echo -e "${gray}   list prompts, l p\t\t\t➜    List available prompts"
  echo -e "${gray}   prompt NUMBER\t\t\t➜    Change prompt (Show Available Prompts with \"list prompts\")${end}"

  echo -e "\n${yellow}[i] ${end}${gray}Users / Groups Commands:${end}\n"
  echo -e "${gray}   show users, s u\t\t\t➜    Show available users list${end}"
  echo -e "${gray}   show groups, s g\t\t\t➜    Show available group list${end}"
  echo -e "${gray}   show users description, s u d\t➜    Show available description about users"
  echo -e "${gray}   show groups description, s g d\t➜    Show available description about groups"
  echo -e "${gray}   show group members GROUP, s g m\t➜    List the members of a specific group"
  echo -e "${gray}   show user sid USER, s u s\t\t➜    Show the SID of a specific user"

  echo -e "\n${yellow}[i] ${end}${gray}Domain Commands:${end}\n"
  echo -e "${gray}   show domain info, s d i\t\t➜    Show domain info (domain name and domain sid)"
  echo -e "${gray}   show trusted domains, s t d\t\t➜    Show domain trust relationships"
}

# Who Am I
function whoAmI () {
  echo -e "\n${gray}Current User: ${end}${yellow}$userConnect${end}"
}

# Function to change de desired prompt
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

# Defining the available prompts
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

# Displaying available prompts
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

# Show available users or groups list (code reuse)
function showUsersGroups () {
  RpcCommand="$1"
  filter="$2"
  objectInTable="$3"

  # Getting the list of users
  # (both regular expressions with "sed" are because the user names can contain characters like "[" or "]" so,
  # we have to make sure that the regular expression works)

  if [ $nullSession ]; then
    objects=$(rpcclient -N $ipAddress -U '' -c "$RpcCommand" | sed -e "s/$filter:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
  else
    objects=$(rpcclient $ipAddress -U "$username%$password" -c "$RpcCommand" | sed -e "s/$filter:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
  fi

  if [ "$3" == "check" ]; then
    checkUserGroupExistence "$command" "$objects" "$filter" && return 0 || return 1
  else
    echo -e "${green}"
    displayTable "$objects" "$objectInTable" # Display information in a table
    echo -e "${end}"
  fi
}

# Function to show the description of any user and group (this function is the same to "show users description" and "show groups description") - (code reuse)
function showDescription {
  objectToShowDescription="$1"

  if [ $nullSession ]; then # Obtaining the description with a null session
    usersList=$(rpcclient -N $ipAddress -U '' -c "enumdomusers" | sed -e "s/user:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
    groupsList=$(rpcclient -N $ipAddress -U '' -c "enumdomgroups" | sed -e "s/group:\[.*rid:\[/#/g" | tr -d '#]')

  else # Obtaining the description with the credentials supplied
    usersList=$(rpcclient $ipAddress -U "$username%$password" -c "enumdomusers" | sed -e "s/user:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#')
    groupsList=$(rpcclient $ipAddress -U "$username%$password" -c "enumdomgroups" | sed -e "s/group:\[.*rid:\[/#/g" | tr -d '#]')
  fi

  case "$objectToShowDescription" in
    "users") # "show users description"
      echo -e "\n${yellow}[i]${end}${gray} Showing users description${end}"
      describeUsersAndGroups "$usersList" "queryuser" ;;

    "groups") # "show groups description"
      echo -e "\n${yellow}[i]${end}${gray} Showing groups description${end}"
      describeUsersAndGroups "$groupsList" "querygroup"
  esac
}

# Function to obtain the description of a user or group (code reuse)
function describeUsersAndGroups () {
  list="$1" # $usersList / $groupsList
  RpcCommand="$2" # "queryuser" / "querygroup"

  declare -i counter=1
  for object in $(echo $list); do # Iterating for each user / group
    if [ $nullSession ]; then # With Null Session
      description=$(rpcclient -N $ipAddress -U '' -c "$RpcCommand $object" | grep 'Description' | cut -f 2 -d ':' | tr -d '\t') # Obtaining the user / group description
    else # With credentials
      description=$(rpcclient $ipAddress -U "$username%$password" -c "$RpcCommand $object" | grep 'Description' | cut -f 2 -d ':' | tr -d '\t') # Obtaining the user / group description
    fi

    # If the user or group has a description, that description will be shown
    if [ "$description" ]; then
      if [ "$RpcCommand" == "queryuser" ]; then
        showObject="$object"
      elif [ "$RpcCommand" == "querygroup" ]; then
        if [ $nullSession ]; then
          showObject=$(rpcclient -N $ipAddress -U '' -c "querygroup $object" | grep 'Group Name' | cut -f 2 -d ':' | tr -d '\t')
        else
          showObject=$(rpcclient $ipAddress -U "$username%$password" -c "querygroup $object" | grep 'Group Name' | cut -f 2 -d ':' | tr -d '\t')
        fi
      fi

      printf "\n${green}%-20s${end} ${gray}:%s${end}\n" "$showObject" "$description" # Printing description
      counter+=1
    fi
  done
}

# Function to show the members of a group
function showGroupMembers () {
  group=$(echo "$objects" | sed -e "s/group:\[/#/g" -e "s/\] rid:.*/#/g"  | tr -d '#' | grep -iE "^$selectedObject$") # Obtaining real group name

  if [ "$group" ]; then
    echo -e "\n${yellow}[i]${end}${gray} Showing members of${end}${yellow} $group${end}${gray} group. Please wait ...${end}"
  
    if [ $nullSession ]; then
      groupRid=$(rpcclient -N $ipAddress -U '' -c "enumdomgroups" | grep -i "group:\[$group\].*" | sed "s/group:\[$group\] rid:\[//I" | tr -d ']') # All RID group members
  
      for rid in $(rpcclient -N $ipAddress -U '' -c "querygroupmem $groupRid" | tr -d '\t' | grep -oP "rid:\[.*?]" | cut -f 2 -d "[" | tr -d "]"); do
        groupMembers+=$(rpcclient -N $ipAddress -U '' -c "queryuser $rid" | grep "User Name" | cut -f 2 -d ":" | tr '\t' '\n') # Getting the user names of RID members
      done
    else
      groupRid=$(rpcclient $ipAddress -U "$username%$password" -c "enumdomgroups" | grep -i "group:\[$group\].*" | sed "s/group:\[$group\] rid:\[//I" | tr -d ']') # All RID group members
  
      for rid in $(rpcclient $ipAddress -U "$username%$password" -c "querygroupmem $groupRid" | tr -d '\t' | grep -oP "rid:\[.*?]" | cut -f 2 -d "[" | tr -d "]"); do
        groupMembers+=$(rpcclient $ipAddress -U "$username%$password" -c "queryuser $rid" | grep "User Name" | cut -f 2 -d ":" | tr '\t' '\n') # Getting the user names of RID members
      done
    fi
  
    if [ "$groupMembers" ]; then # If there are members in the provided group
      members=$(echo "$groupMembers" | tail -n +2) # Deleting the first \n
    
      echo -e "${green}"
      displayTable "$members" "Miembros" # Displaying all members in a table
      echo -e "${end}"
    else
      echo -e "\n${red}[!]${end}${gray} There are NO members in the specified group${end}"
    fi
    unset groupMembers # Removal of the content of groupMembers to avoid repetition if the user provided the 'show group members' command again
  else
    return 1
  fi
}

# Functino to show the sid of a specific user
function showUserSid () {
  user=$(echo "$command" | cut -f 4- -d " ") # Getting the provided username

  if [ $nullSession ]; then
    sidResult=$(rpcclient -N $ipAddress -U '' -c "lookupnames $user") # Getting result from 'lookupnames $user'
  else
    sidResult=$(rpcclient $ipAddress -U "$username%$password" -c "lookupnames $user") # Getting result from 'lookupnames $user'
  fi

  if [[ $(echo "$sidResult" | grep "NT_STATUS_ACCESS_DENIED") ]]; then # We dont have permissions to display the SID
    echo -e "\n${red}[!]${end}${gray} As ${end}${yellow}$userConnect${end}${gray} dont have permissions to perform this action${end}"
    return
  fi

  sid=$(echo "$sidResult" | cut -f 2 -d " ") # Getting SID from the user provided
  echo -e "\n${gray}SID: ${end}${yellow}$sid${end}"
  return 0
}

# Function to show domain name and domain sid
function showDomainInfo () {
  if [ $nullSession ]; then
    resultDomainInfo=$(rpcclient -N $ipAddress -U '' -c "lsaquery") # Getting result from 'lsaquery'
  else
    resultDomainInfo=$(rpcclient $ipAddress -U "$username%$password" -c "lsaquery") # Getting result from 'lsaquery'
  fi

  domainName=$(echo "$resultDomainInfo" | head -n 1 | sed "s/Domain Name: //g") # Obtaining the value of "Domain Name"
  domainSid=$(echo "$resultDomainInfo" | tail -n 1 | sed "s/Domain Sid: //g") # Obtaining the value of "Domain Sid"

  echo -e "\n${gray}Domain Name${end}:${yellow} $domainName${end}"
  echo -e "${gray}Domain SID${end}:${yellow} $domainSid${end}"
}

# Function to show domain trust relationships
function showTrustedDomains () {
  if [ $nullSession ]; then
    resultTrustedDomains=$(rpcclient -N $ipAddress -U '' -c "enumtrust") # Getting result from "enumtrust"
  else
    resultTrustedDomains=$(rpcclient $ipAddress -U "$username%$password" -c "enumtrust") # Getting resuslt from "enumtrust"
  fi

  if [ "$resultTrustedDomains" ]; then
    trustedDomains=$(echo "$resultTrustedDomains" | grep "Domain Name:" | sed "s/Domain Name: //g")
    displayTable "$resultTrustedDomains" "Trusted Domains"
  else
    echo -e "\n${red}[!]${end}${gray} There is NO trust relationships in the domain${end}"
  fi
}

# Function to display a table with the contents of a variable
function displayTable() {
  local variable="$1"
  local objectInTable="$2"
  local IFS=$'\n' # Internal Field Separator set to newline
  local -a items # Array to store the elements of the variable

  # Convert the variable into an array, splitting by newlines
  read -d '' -ra items <<< "$variable"

  # Calculate the maximum width of the content column
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
while getopts "hu:p:n" arg; do # [Help Panel (-h)] [Username (-u), Password (-p)] [Null Session (-n)]
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
  echo -ne "\n${blue}$prompt ${end}${white}${gray}" && read command  # Command input

  case "$command" in
    "help"|"H"|"h") helpPanel ;; # Command Help Panel
    $'\f'|"clear"|"c") clear ;; # Clear the screen
    "exit"|"e") exit 0 ;; # Exit the program
    "whoami"| "w") whoAmI ;; # Print the current user
    "list prompts"|"l p") showAvailablePrompts ;;
    prompt*) changePrompt "$command" ;; # Change de prompt

    # Showing existing users ($1 = command to execute in RPC; $2 = the filter that grep will use to get all users; 3 = text to represent the column of the object)
    "show users"|"s u") showUsersGroups "enumdomusers" "user" "Username" ;;

    # Showing existing groups ($1 = command to execute in RPC; $2 = the filter that grep will use to get all groups; $3 = text to represent the column of the object)
    "show groups"|"s g") showUsersGroups "enumdomgroups" "group" "Group" ;;

    "show users description"|"s u d") showDescription "users" ;; # Show users description
    "show groups description"|"s g d") showDescription "groups" ;; # Show groups description

    # Display the members of a group (showUsersGroups - $1 = command to execute in RPC; $2 = the filter that grep will use to get all gropus; $3 = entering the conditional that says that it is a single check)
    show\ group\ members\ *|s\ g\ m\ *) showUsersGroups "enumdomgroups" "group" "check" && showGroupMembers "$selectedObject" || echo -e "\n${red}[!]${end}${gray} The specified group does not exist${end}" ;;

    # Display the SID of the user provided (showUsersGroups - $1 = command to execute in RPC; $2 = the filter that grep will use to get all users; $3 = entering the conditional that says that it is a single check)
    show\ user\ sid\ *|s\ u\ s\ *) showUsersGroups "enumdomusers" "user" "check" && showUserSid "$selectedObject" || echo -e "\n${red}[!]${end}${gray} The specified user does not exist${end}" ;;

    "show domain info"|"s d i") showDomainInfo ;; # Show domain info
    "show trusted domains"|"s t d") showTrustedDomains || echo -e "\n${red}[!]${end}${gray}${end}" ;; # Show domain trust relationships
    "") ;;
    *) echo -e "\n${red}[!]${end}${gray} Command NOT recognized. Run \"help\" or \"h\" to display the Help Panel${end}";; # The command does not exist
  esac
done
