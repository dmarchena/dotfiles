#!/usr/bin/env bash
BASEDIR="$DOTFILES_HOME/dev/"
source "$BASEDIR/.config.sh"

alias dev="$BASEDIR/dev.sh"

alias ftls="xpl $WS_FTL"
alias ftlclean="$BASEDIR/ftlclean.sh"

alias fullxml="edit $FULL_XML"
alias libertyxml="edit $LIBERTY_XML"

alias docs="cd $DEV_DOCS"
alias ddocs="cd $DESA_DOCS"

jenk() {
	POSITIONAL=()
	jenkURL="http://192.168.100.227:9080"
	while [[ $# -gt 0 ]]; do
		key="$1"
		case $key in
			-p)
			jenkURL="https://pljenci1.vitoria-gasteiz.org:8443/"
			shift
			;;
			*)    # unknown option
			POSITIONAL+=("$1") # save it in an array for later
			shift # past argument
			;;
		esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters
	if [[ -z $1 ]]; then
		brws "$jenkURL"
	else
		brws "$jenkURL/job/$1"
	fi
}

ws() {
	if [ -d "/d/Trabajo/WS/$1" ]
  		then
			cd /d/Trabajo/WS/$1
	else
		cd $WS_BASHPATH/$1
	fi
}

wsx() {
	ws $1
	xpl
}