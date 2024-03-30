#!/bin/bash

DISCORD_BRANCH="stable"    # canary | ptb | stable ; Replace with one of this values
INSTALL_PATH="/mnt/SSD/Programs" # the real path up to, but not including, the Discord directory ; Replace this with your path
DOWNLOADS_PATH="$HOME/Downloads" # your desired download location ; The archive will be removed after update, so it doesn't matter what you set this to ; Defaults to the Downloads directory

# ----> !! Do not Edit !!
DISCORD_BUILD_INFO="$INSTALL_PATH/Discord/resources/build_info.json"
DISCORD_API="https://discord.com/api/updates/$DISCORD_BRANCH?platform=linux"
DISCORD_DOWNLOAD="https://discord.com/api/download?platform=linux&format=tar.gz"

DESKTOP_LINKS_PATH="$HOME/.local/share/applications"

install_discord() {
	if [ ! -d "$DOWNLOADS_PATH" ]; then
		printf "\33[1;35m[ERROR]\33[0m \$DOWNLOADS_PATH does not exist at the specified path\n"
		xdg-open "$0"
		exit 1
	fi
	if [ ! -d "$INSTALL_PATH" ]; then
		printf "\33[1;35m[ERROR]\33[0m \$DISCORD_PATH does not exist at the specified path\n"
		xdg-open "$0"
		exit 1
	fi
# ----> Download Discord
	DISCORD_TAR="$DOWNLOADS_PATH/discord-$EXTRN_VERSION.tar.gz"
	wget -O $DISCORD_TAR $DISCORD_DOWNLOAD
# ----> Extract & Replace
	tar -xzf $DISCORD_TAR --overwrite -C $INSTALL_PATH
# ----> Remove Tar
	rm -rf $DISCORD_TAR
}

run_discord() {
	if [ ! -e "$INSTALL_PATH/Discord/Discord" ]; then
		printf "\33[1;35m[ERROR]\33[0m \$INSTALL_PATH does not exist at the specified path\n"
		xdg-open "$0"
		exit 1
	fi
# ----> Run Discord
	"$INSTALL_PATH/Discord/Discord" &
	printf "[INFO] Discord ready to open\n"
}

# ----> Find Desktop Link
if [ ! -f $"$DESKTOP_LINKS_PATH/discoed.desktop" ]; then
	printf "\33[1;35m[ERROR]\33[0m Missing 'discoed.desktop' link from quick launcher\n"
	# get current directory
	# copy .desk to ../applications
	# edit the values with the current_working_directory .sh and .png
	# print created quick launcher link
	xdg-open "$DESKTOP_LINKS_PATH"
	exit 1
fi

# ----> Web Server Query
EXTRN_JSON=$(curl -s $DISCORD_API)
EXTRN_VERSION=$(echo $EXTRN_JSON | grep -o '"name": "[^"]*"' | sed 's/"name": "\(.*\)"/\1/')
printf "[INFO] Latest Build Version: %s\n" $EXTRN_VERSION

LOCAL_VERSION="null"
if [ -f "$DISCORD_BUILD_INFO" ]; then
# ----> Discord Client Query
	LOCAL_JSON=$(cat $DISCORD_BUILD_INFO)
	LOCAL_VERSION=$(echo $LOCAL_JSON | grep -o '"version": "[^"]*"' | sed 's/"version": "\(.*\)"/\1/')
fi
printf "[INFO] Client Build Version: %s\n" $LOCAL_VERSION

# ----> Compare Values
if [[ $LOCAL_VERSION = $EXTRN_VERSION ]]; then
	printf "\33[1;36m[STATUS]\33[0m Up to date\n"
else
	printf "\33[1;33m[STATUS]\33[0m \33[1;35m<!>\33[0m Update needed\n"
	install_discord
fi

run_discord
