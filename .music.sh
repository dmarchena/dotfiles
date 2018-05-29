#!/usr/bin/env bash

#------------------------------------------------------------------------------
# MUSIC
#------------------------------------------------------------------------------
alias music="xpl I:"
alias vlc="/c/Program\ Files/VideoLAN/VLC/vlc.exe"

fmusic() {
	MUSIC_BASEPATH="/i/Música"
	# Recuperar argumentos
	# https://stackoverflow.com/a/14203146
	###############################################################################
	SHOW_FULL_PATH=false
	POSITIONAL=()
	while [[ $# -gt 0 ]] 
	do
		key="$1"
		case $key in
			-p|--path)
				SHOW_FULL_PATH=true
				shift # past argument
				;;
			*)    # unknown option
				POSITIONAL+=("$1") # save it in an array for later
				shift # past argument
				;;
		esac
	done
	set -- "${POSITIONAL[@]}" # restore positional parameters

	NAMEBLOB="*$(sed -e 's/\s/\*/g' <<<$@)*"
	RESULTS="$(find $MUSIC_BASEPATH -type d -iname "$NAMEBLOB" 2>/dev/null)"
	if [[ -n $RESULTS ]]
		then
		if [[ "$SHOW_FULL_PATH" == "true" ]]
			then
			echo "$RESULTS"
		else
			while read line;
				do echo "${line##*/}"
			done <<< "$RESULTS"
		fi
	else
		echo ":( Lo siento tío. No hay discos que contengan \"$@\"."
	fi
}

listen() {
    BOLDGREEN="\e[1;32m"
    NC="\e[0m"
	album="$(fmusic --path "$@" | head -n 1)"
	if [[ -n $album ]] 
		then
		printf "Va a sonar:\n\n${BOLDGREEN}${album##*/}${NC}\n\n"
		vlcpid=$(ps aux | grep 'vlc' | awk '{print $1}')
		if [ -n "$vlcpid" ]
			then
			# If vlc is opened, close it
			kill -9 $vlcpid
		fi
		echo "¡Sube el volumen y a disfrutar!"
		(vlc "$(nativepath $album)" &)
	else
		echo "No se han encontrado ningún álbum para: $@"
	fi
}