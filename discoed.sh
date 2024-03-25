#!/bin/bash

DISCORD_BRANCH="stable"    # canary | ptb | stable ; Replace with one of this values
DISCORD_PATH="/mnt/SSD/Programs" # the real path up to, but not including, the Discord directory ; Replace this with your path
DOWNLOADS_PATH="$HOME/Downloads" # your desired download location ; The archive will be removed after update, so it doesn't matter what you set this to ; Defaults to the Downloads directory

# ----> !! Do not Edit !!
DISCORD_BUILD_INFO="$DISCORD_PATH/Discord/resources/build_info.json"
DISCORD_API="https://discord.com/api/updates/$DISCORD_BRANCH?platform=linux"
DISCORD_DOWNLOAD="https://discord.com/api/download?platform=linux&format=tar.gz"

# ----> Discord Client Query
   LOCAL_JSON=$(cat $DISCORD_BUILD_INFO)
LOCAL_VERSION=$(echo $LOCAL_JSON | grep -o '"version": "[^"]*"' | sed 's/"version": "\(.*\)"/\1/')

printf "[INFO] Client Build Version: %s\n" $LOCAL_VERSION

# ----> Web Server Query
   EXTRN_JSON=$(curl -s $DISCORD_API)
EXTRN_VERSION=$(echo $EXTRN_JSON | grep -o '"name": "[^"]*"' | sed 's/"name": "\(.*\)"/\1/')

printf "[INFO] Latest Build Version: %s\n" $EXTRN_VERSION

# ----> Compare Values
if [[ $LOCAL_VERSION = $EXTRN_VERSION ]]; then
	printf "\33[1;36m[STATUS]\33[0m Up to date\n"
else
	printf "\33[1;33m[STATUS]\33[0m \33[1;35m<!>\33[0m Update needed\n"
# ----> Download Discord
	DISCORD_TAR="$DOWNLOADS_PATH/discord-$EXTRN_VERSION.tar.gz"
	wget -O $DISCORD_TAR $DISCORD_DOWNLOAD
# ----> Extract & Replace
	tar -xzf $DISCORD_TAR --overwrite -C $DISCORD_PATH
# ----> Remove Tar
	rm -rf $DISCORD_TAR
fi

# ----> Run Discord
"$DISCORD_PATH/Discord/Discord" &
