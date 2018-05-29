#!/usr/bin/env bash
CURRENT_DIR="$(dirname "$0")"
#source "$CURRENT_DIR/.config.sh"

BOLDRED="\e[1;31m"
NC="\e[0m"

regex="#assign ([^= ]*)[ ]*="
#regex="#assign [^=]*[ ]*="
basedir="$WS_FTL/www"
literals="$basedir/includes/_lite*"
vars=()
i=0
egrep -i "$regex" $literals | while read line; do
    if [[ $line =~ $regex ]]; then
        var="${BASH_REMATCH[1]}"
        #printf 'find %s -name '*.ftl' -exec cat {} \; | grep -c "\${%s}"' "$basedir" "$var"
        count=$(find $basedir -name '*.ftl' -exec cat {} \; | grep -c "\${$var}")
        if [ $count == 0 ]; then
            printf "${BOLDRED}%-40s${NC}:NOT USED\n" "$var"
        else
            printf "%-40s:used\n" "$var"
        fi
        #vars=("${vars[@]}" "a")
        #printf '%s' "$var"
    fi
done
#printf '\n%s\n' "${#vars[@]}"
    
#find /d/Trabajo/WS-DEV/_shared/plantillas/www -name '*.ftl' -exec cat {} \; | grep -c "\${pieDireccion}"