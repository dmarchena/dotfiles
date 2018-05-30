#!/usr/bin/env bash
export NC='\033[0m'

# BASIC COLORS
export RED='\033[00;31m'
export GREEN='\033[00;32m'
export YELLOW='\033[00;33m'
export BLUE='\033[00;34m'
export MAGENTA='\033[00;35m'
export CYAN='\033[00;36m'
export WHITE='\033[00;37m'

# LIGHTENED
export LRED='\033[01;31m'
export LGREEN='\033[01;32m'
export LYELLOW='\033[01;33m'
export LBLUE='\033[01;34m'
export LMAGENTA='\033[01;35m'
export LCYAN='\033[01;36m'
export WHITE='\033[01;37m'

# BOLDS
export BRED='\033[02;31m'
export BGREEN='\033[02;32m'
export BYELLOW='\033[02;33m'
export BBLUE='\033[02;34m'
export BMAGENTA='\033[02;35m'
export BCYAN='\033[02;36m'
export BGWHITE='\033[02;37m'

# BACKGROUND COLORS
export BGRED='\033[41m'
export BGGREEN='\033[42m'
export BGYELLOW='\033[43m'
export BGBLUE='\033[44m'
export BGMAGENTA='\033[45m'
export BGCYAN='\033[46m'
export BGWHITE='\033[47m'

palette() {
    for((i=16; i<256; i++)); do
        printf "\e[48;5;${i}m%03d" $i;
        printf '\e[0m';
        [ ! $((($i - 15) % 6)) -eq 0 ] && printf ' ' || printf '\n'
    done
}