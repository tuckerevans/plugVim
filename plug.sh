#!/bin/bash

#This script installs vim plugins using git submodules.
#
#
#MIT License
#
#Copyright (c) 2018 Tucker Evans
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

if [[ !(-d ~/.plug ) ]] 
then
	mkdir ~/.plug
fi

PLUG_PATH=".vim/pack/$USER/start/"
VIM_PATH="vim"
JOBS=4
LOG_FILE=~/.plug/$(date -Is).log
GIT_DIR="$HOME/dotfiles"
PROGRAM="plug"
touch $LOG_FILE

#
# helper funcitons
#

git_commit() {
	[[ -n GIT_DIR ]] || return 1
	[[ -n COMMIT_MSG ]] || return 1

	return git -C GIT_DIR commit -m"$COMMIT_MSG" >> $LOG_FILE
}

#
# subcommand functions
#

cmd_version () {
	cat <<-EOF
	plug version 0.0.1
	EOF
}


cmd_usage () {
	cmd_version
	cat <<-EOF
	Usage:
	        $PROGRAM install [-orn] [-g GIT REPO] [-d .vim LOCATION] git-repo
	                Install plugin located at git-repo.
	        $PROGRAM update [-c] [-j NUMBER OF THREADS] [-g GIT REPO]
	                Update all git modules
	        $PROGRAM remove [-oc] [-g GIT REPO] [-d .vim LOCATION] plugin-name
	                Remove plugin.
	        $PROGRAM list [-g GIT REPO]
	                List installed plugins.
	        $PROGRAM help
	                Show this text.
	        $PROGRAM version
	                Show version information.

	More information can be found in the plug(1) man page.
	EOF
}

cmd_install() {
	while getopts ":ocg:d:" opt;
	do
		case $opt in
			o)
				PLUG_PATH="vim/.vim/pack/$USER/opt/"
				;;
			c)
				COMMIT_MSG="Installed "
				;;
			g)
				GIT_DIR=$OPTARG
				;;
			d)
				VIM_PATH=$OPTARG
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return
				;;
			:)
				echo "Option -$OPTARG requerys an argument"
				;;
		esac
	done
	
	LINK=${!OPTIND}
	PLUG_NAME=${LINK##*/}
	FILENAME=${PLUG_NAME%.git}
	FILENAME="$VIM_PATH/$PLUG_PATH$FILENAME"
	echo "Installing $PLUG_NAME...at $FILENAME"


	if git -C $GIT_DIR submodule add --depth 1 $LINK $FILENAME >> $LOG_FILE
	then
		echo "Installed $PLUG_NAME"
		if [[ -n $COMMIT_MSG ]] 
		then
			echo "Commiting Changes..."
			COMMIT_MSG="$COMMIT_MSG$PLUGNAME"
			if git -C $GIT_DIR add .gitmodules $FILENAME >> $LOG_FILE && \
			   git_commit  >> $LOG_FILE
			then
				echo "Changes Commited"
			else 
				echo "Error committing changes"
				return 1
			fi
		fi
	else 
		exit 1
	fi 

	echo "Installed $PLUG_NAME"
	return 0
}

cmd_update() {
	while getopts ":jc" opt;
	do
		case $opt in
			c)
				COMMIT_MSG="Updated Submodules"
				;;
			j)
				JOBS=$OPTARG
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return
				;;
			:)
				echo "Option -$OPTARG requerys an argument"
				;;
		esac
	done

	echo "Updating modules..."

	if git -C $GIT_DIR submodule update --remote --merge -j $JOBS >> $LOG_FILE
	then 
		echo "Modules updated"
			if [[ -n $COMMIT_MSG ]] 
			then
				echo "Commiting Changes..."
				if git_commit  >> $LOG_FILE
				then
					echo "Changes Commited"
				else 
					echo "Error committing changes"
					return 1
				fi
			fi
	else 
		exit 1
	fi

	echo "Updated modules"
	return 0
}

cmd_remove() {
	while getopts ":ocd:g:" opt;
	do
		case $opt in
			o)
				PLUG_PATH="vim/.vim/pack/$USER/opt/"
				;;
			c)
				COMMIT_MSG="Removed "
				;;
			g)
				GIT_DIR=$OPTARG
				;;
			d)
				VIM_PATH=$OPTARG
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return
				;;
			:)
				echo "Option -$OPTARG requerys an argument"
				;;
		esac
	done
	
	NAME="${!OPTIND}"
	FILENAME="$VIM_PATH/$PLUG_PATH$NAME"

	if git -C $GIT_DIR submodule deinit -f $FILENAME >> $LOG_FILE &&\
		git -C $GIT_DIR rm -f $FILENAME >> $LOG_FILE&& \
		rm -rfv ".git/modules/$FILENAME" >> $LOG_FILE
	then
		
		if [[ -n $COMMIT_MSG ]] 
		then
			echo "Commiting Changes..."
			COMMIT_MSG="$COMMIT_MSG$PLUGNAME"
			if git_commit  >> $LOG_FILE
			then
				echo "Changes Commited"
			else 
				echo "Error committing changes"
				return 1
			fi
		fi
	else 
		echo "Error removing $NAME"
		exit 1
	fi

	echo "$NAME removed"
	return 0
}

cmd_list() {
	while getopts ":ocg:" opt;
	do
		case $opt in
			g)
				GIT_DIR=$OPTARG
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				return
				;;
			:)
				echo "Option -$OPTARG requires an argument"
				;;
		esac
	done
	if [[ -f "$GIT_DIR/.gitmodules" ]] 
	then
		echo "Installed in \"start\""
		grep -E 'path.*start' "$GIT_DIR/.gitmodules" | sed 's/.*=*\//\t/'
	
		echo "Installed in \"opt\""
		grep -E 'path.*opt' "$GIT_DIR/.gitmodules" | sed 's/.*=*\//\t/'
	else
		echo "No submodules in $GIT_DIR"
	fi
}

case "$1" in 
	install|add)
		shift
		cmd_install "$@"
		;;
	help|--help)
		shift
		cmd_usage "$@"
		;;
	version|--version|-v)
		shift
		cmd_version "$@"
		;;
	ls|list|show)
		shift
		cmd_list "$@"
		;;
	update)
		shift
		cmd_update "$@"
		;;
	rm|remove|delete)
		shift
		cmd_remove "$@"
esac
exit 0
