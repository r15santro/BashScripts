#!/bin/bash

# -------------------------------
# Defining variables and array
# -------------------------------
user=$(whoami)
fmt_hosts=( evt-fmt1-usw2.bintray.com evt-fmt2-euc1.bintray.com evt-fmt2-usw2.bintray.com evt-fmt3-euc1.bintray.com )
#fmt_hosts=( evt-fmt1-usw2.bintray.com )
alert_hosts=( evt-proc2-dal evt-proc3-dal evt-proc4-dal evt-proc5-dal evt-proc6-dal )
alert_host_count=${#alert_hosts[@]}


# ----------------------------------------------
# function to check validity of the input host
# ----------------------------------------------
check_host(){
for loop in "${!alert_hosts[@]}"; do
  if [[ "$1" = "${alert_hosts[loop]}" ]];
  then
    echo "$1 is a valid host"
    break
  elif [[ $loop -eq $(($alert_host_count - 1)) ]];
  then
    echo "You entered an invalid hostname"
    pause
  else
    continue
  fi
done
}


# ----------------------------------
# functions for actual work
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

one(){
	read -p "Enter the full hostname having alerts: " alert_host
  check_host $alert_host
  for host in ${fmt_hosts[@]}
  do
     echo "======================================="
     echo "Executing task in $host...."
     echo "======================================="
     ssh -t $user@${host} 'sudo cat /etc/nutcracker/nutcracker.yml; sudo sed -i -e  '/"$alert_host"/s/^/\#/' /etc/nutcracker/nutcracker.yml; echo "Restarting the twemproxy container after editing nutcracker.yml...."; sudo docker restart btevtfmt_twemproxy_1; sudo docker ps; sudo cat /etc/nutcracker/nutcracker.yml'
  done
  pause
}

two(){
  read -p "Enter the full hostname having alerts: " alert_host
  check_host $alert_host
  for host in ${fmt_hosts[@]}
  do
    echo "======================================="
    echo "Executing task in $host...."
    echo "======================================="
    ssh -t $user@${host} 'sudo cat /etc/nutcracker/nutcracker.yml; sudo sed -i -e  '/"$alert_host"/s/^\#//' /etc/nutcracker/nutcracker.yml; echo "Restarting the twemproxy container after editing nutcracker.yml...."; sudo docker restart btevtfmt_twemproxy_1; sudo docker ps; sudo cat /etc/nutcracker/nutcracker.yml'
  done
  pause
}


# function to display menus
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Remove host from twemproxy"
	echo "2. Put host to twemproxy"
	echo "3. Exit"
}

# read input from the keyboard and take a action
read_options(){
	local choice
	read -p "Enter choice [ 1 - 3] " choice
	case $choice in
		1) one ;;
		2) two ;;
		3) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}

# -------------------------------
# trap ctrl-c and call ctrl_c()
# -------------------------------

trap ctrl_c INT

function ctrl_c() {
        echo "User pressed CTRL-C .. Exit from the program"
        exit
}

# -----------------------------------
# infinite loop
# ------------------------------------
while true
do

	show_menus
	read_options
done
