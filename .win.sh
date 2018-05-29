#!/usr/bin/env bash
alias hosts="vim /c/Windows/System32/drivers/etc/hosts"

brws() {
    $(/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe $@ &)
}

nativepath() {
	sed -e 's_^/\(.\)_\U\1:_' -e 's_/_\\_ g' <<<$*
}

xpl() {
	OPENDIR=$1
	if [[ -z $OPENDIR ]]; then
        OPENDIR="."
    fi
    if [[ -d $OPENDIR ]]; then
        explorer $(nativepath $OPENDIR)
    elif [[ -f $OPENDIR ]]; then
        explorer $(nativepath $(dirname "${OPENDIR}"))
    else
        echo "$OPENDIR is not valid"
        exit 1
    fi
}