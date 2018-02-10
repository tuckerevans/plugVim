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


PLUG_PATH="vim/.vim/pack/$USER/start/"
JOBS=4

#
# helper funcitons
#

set_git() {
	if [[ -n GIT_DIR ]] 
	then
		GIT_DIR = "$HOME/dotfiles"
	fi
}

git_commit() {
	[[ -n GIT_DIR ]] || return 1
	[[ -n COMMIT_MSG ]] || return 1

	return git -C GIT_DIR commit -m"$COMMIT_MSG"
}

#
# subcommand functions
#

cmd_version () {
	cat <<-_EOF
	plug version 0.0.1
	_EOF
}


cmd_usage () {
	cat <<-_EOF
	Usage:
		$PROGRAM install [-odcn] git-repo
		$PROGRAM update [-jc]
		$PROGRAM remove [-odc] plugin-name
		
	More information can be found in the plug(1) man page.
	_EOF
}

cmd_install() {
	while getopts ":ocd:" opt;
	do
		case opt in
			o)
				PLUG_PATH="vim/.vim/pack/$USER/opt/"
				;;
			c)
				COMMIT_MSG="Installed "
				;;
			d)
				GIT_DIR=$OPTARG
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
	[[ -n $GIT_DIR ]] && PLUG_PATH="$GIT_DIR$PLUG_PATH"
	
	LINK=${!OPTIND}
	PLUG_NAME=${LINK##*/}
	FILENAME=${FILENAME%.git}
	FILENAME="$PLUG_PATH$FILENAME"
	echo "Installing $PLUG_NAME..."

	set_git

	if git submodule add $LINK $FILENAME 1> .plug/$(date -Is).log 
	then
		echo "Installed $PLUG_NAME"
		if [[ -n $COMMIT_MSG ]] 
		then
			echo "Commiting Changes..."
			COMMIT_MSG="$COMMIT_MSG$PLUGNAME"
			if git add .gitmodules $FILENAME 1> .plug/$(date -Is).log && \
			   git_commit  1> .plug/$(date -Is).log
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
		case opt in
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

	if git submodule update --remote --merge -j $JOBS 1> .plug/$(date -Is).log
	then 
		echo "Modules updated"
			if [[ -n $COMMIT_MSG ]] 
			then
				echo "Commiting Changes..."
				if git_commit  1> .plug/$(date -Is).log
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
	while getopts ":ocd:" opt;
	do
		case opt in
			o)
				PLUG_PATH="vim/.vim/pack/$USER/opt/"
				;;
			c)
				COMMIT_MSG="Removed "
				;;
			d)
				GIT_DIR=$OPTARG
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
	FILENAME="$PLUG_PATH$NAME"

	if git submodule deinit -f $FILENAME &&\
		git rm -f $FILENAME && \
		rm -rfv ".git/modules/$FILENAME"
	then
		
		if [[ -n $COMMIT_MSG ]] 
		then
			echo "Commiting Changes..."
			COMMIT_MSG="$COMMIT_MSG$PLUGNAME"
			if git_commit  1> .plug/$(date -Is).log
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

echo "t"
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
	remove|delete)
		shift
		cmd_remove "$@"
esac
exit 0
