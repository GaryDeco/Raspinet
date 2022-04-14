#!/bin/bash

#########################################################################################################

# Author: Gary Decosmo
# Date Created: 1/28/2022
# Description: Network Analyzer Configuration Tool 

############################################# MENU CONFIG ###############################################

# set defaults
export NEWT_COLORS='root=,blue
    roottext=black,white
    entry=black,white'

SETUP_WINDOW_TITLE="Network Analyzer Configuration Tool"
MAIN_MENU_TITLE = "Select your destination"
WINDOW_HEIGHT=20
WINDOW_WIDTH=60

############################################# GLOBALS ##################################################

# Global variables
GLOBAL_VARIABLE1="I'm a Global variable" #for example


############################################# EXPORTS ###################################################

# Exports - this is where we need sourcing (. ./setup_script_example.sh)
export EXPORTED_VARIABLE="I'm an Exported variable" # for example


############################################## TEMPLATES ################################################

function show_info_box(){
    whiptail --title "Info:" --backtitle "${SETUP_WINDOW_TITLE}" --msgbox "$1" ${WINDOW_HEIGHT} ${WINDOW_WIDTH}
}

function show_yesno_box(){
    whiptail --title "Conditional action:" --backtitle "${SETUP_WINDOW_TITLE}" --yesno "$1" ${WINDOW_HEIGHT} ${WINDOW_WIDTH}
}

function show_input_box(){
    whiptail --title "User input:" --backtitle "${SETUP_WINDOW_TITLE}" --inputbox "$1" ${WINDOW_HEIGHT} ${WINDOW_WIDTH} 3>&1 1>&2 2>&3
}

############################################## EXAMPLES ################################################

function wait_for_keypress(){
  local color=`tput setaf 4`
  local reset=`tput sgr0`
  local message="Press any key to continue..."

  if [[ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]]; then
     read "?${color}${message}${reset}"
  elif [[ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]]; then
     read -p "${color}${message}${reset}"
  else
     read -p "${color}${message}${reset}"
  fi
}

function example_step1(){
    show_info_box "This is how we can show some info box, for example a global var: ${GLOBAL_VARIABLE1}"
}

function example_step2(){
    if show_yesno_box "Shall I do some conditional action?"; then
        echo "work is done!"
        wait_for_keypress
    fi
}

example_step1
example_step2








