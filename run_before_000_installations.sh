#!/bin/bash
set -eu

OS=$(( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1)




if [ $OS = '"Solus"' ]
then
	sudo eopkg upgrade -y
	sudo eopkg install neofetch git tmux -y
	clear
	
	neofetch
fi

if [ $OS = '"Debian"' ]
then
	# TODO
	echo "TODO"
fi
