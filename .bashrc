CURRENT_DIR="$(dirname "$0")"
DOTFILES_HOME="/d/Trabajo/dmarchena/.dotfiles"

export DEV_HOME="/d/DEV-WAS8"
export MVN_HOME="$DEV_HOME/VG2017/apache-maven-3.5.0"
export WSDEV_HOME="/d/Trabajo/WS-DEV"

alias subl="(/c/Program\ Files/Sublime\ Text\ 3/sublime_text.exe . &)"
alias code="(/c/Program\ Files/Microsoft\ VS\ Code/Code.exe . &)"

alias mvn="JAVA_HOME=\"/d/DEV-WAS8/TOOLS/jdk1.7.0_80-sun/\" $MVN_HOME/bin/mvn -s /D/DEV-WAS8/CONF/m2/settings.xml"
alias dev="$DOTFILES_HOME/dev/dev.sh"

alias home="cd ~/"

alias music="xpl I:"
alias vlc="/c/Program\ Files/VideoLAN/VLC/vlc.exe"
alias sudo="cygstart --action=\"runas /user:admapl\""

alias hosts="vim /c/Windows/System32/drivers/etc/hosts"

alias docs="cd $DEV_HOME/website/docs"
alias ddocs="cd //dintranet2.vitoria-gasteiz.org/DEPLOY_ESTATICO_Y_COMUN/docs"

function xpl {
	OPENDIR=$1
	if [[ -z $OPENDIR ]] 
		then 
			explorer .
	else
		explorer $OPENDIR
	fi
}

function ws {
	if [ -d "/d/Trabajo/WS/$1" ]
  		then
			cd /d/Trabajo/WS/$1
	else
		cd $WSDEV_HOME/$1
	fi
}

function wsx {
	ws $1
	xpl
}

function winpath {
	sed -e 's_^/\(.\)_\U\1:_' -e 's_/_\\_ g' <<<$*
}

source "$DOTFILES_HOME/music.sh"
