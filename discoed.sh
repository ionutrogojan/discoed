#!/bin/bash

DISCORD_BRANCH="stable"    # canary | ptb | stable ; Replace with one of this values
INSTALL_PATH="/mnt/SSD/Programs" # the real path up to, but not including, the Discord directory ; Replace this with your path
DOWNLOADS_PATH="$HOME/Downloads" # your desired download location ; The archive will be removed after update, so it doesn't matter what you set this to ; Defaults to the Downloads directory

# ----> !! Do not Edit !!
DISCORD_BUILD_INFO="$INSTALL_PATH/Discord/resources/build_info.json"
DISCORD_API="https://discord.com/api/updates/$DISCORD_BRANCH?platform=linux"
DISCORD_DOWNLOAD="https://discord.com/api/download?platform=linux&format=tar.gz"
DESKTOP_LINKS_PATH="$HOME/.local/share/applications"
CWD=$(dirname $(realpath "$0"))

log_data() {
	DATA="$1"
	NOW=$(date "+%d-%m-%Y %H:%M")
	printf "[%s] %s\n" "$NOW" "$DATA" >> "$CWD/discoed.log"
}

install_discord() {
	if [ ! -d "$DOWNLOADS_PATH" ]; then
		ERROR="\$DOWNLOADS_PATH does not exist at the specified path"
		printf "\33[1;35m[ERROR]\33[0m %s\n" "$ERROR"
		log_data "<ERROR> $ERROR"
		xdg-open "$CWD/discoed.log"
		xdg-open "$0"
		exit 1
	fi
	if [ ! -d "$INSTALL_PATH" ]; then
		ERROR="\$INSTALL_PATH does not exist at the specified path"
		printf "\33[1;35m[ERROR]\33[0m %s\n" "$ERROR"
		log_data "<ERROR> $ERROR"
		xdg-open "$CWD/discoed.log"
		xdg-open "$0"
		exit 1
	fi
# TODO: check if all of these exit succesfully and log the errors if not
# ----> Download Discord
	DISCORD_TAR="$DOWNLOADS_PATH/discord-$EXTRN_VERSION.tar.gz"
	wget -O $DISCORD_TAR $DISCORD_DOWNLOAD
# ----> Extract & Replace
	tar -xzf $DISCORD_TAR --overwrite -C $INSTALL_PATH
# ----> Remove Tar
	rm -rf $DISCORD_TAR
	log_data "<INFO> Discord updated to the latest version $EXTRN_VERSION"
}

run_discord() {
	if [ ! -e "$INSTALL_PATH/Discord/Discord" ]; then
		ERROR="Discord executable does not exist at the specified path"
		printf "\33[1;35m[ERROR]\33[0m %s\n" "$ERROR"
		log_data "<ERROR> $ERROR"
		xdg-open "$CWD/discoed.log"
		xdg-open "$0"
		exit 1
	fi
# ----> Run Discord
	"$INSTALL_PATH/Discord/Discord" &
	printf "[INFO] Discord ready to open\n"
}

# ----> Find Desktop Link
if [ ! -f "$DESKTOP_LINKS_PATH/discoed.desktop" ]; then
	MESSAGE="Missing 'discoed.desktop' link from quick launcher"
	printf "[INFO] %s\n" "$MESSAGE"
	log_data "<INFO> $MESSAGE"
# ----> Copy Desktop Link
	cp "$CWD/discoed.desktop" "$DESKTOP_LINKS_PATH"
# ----> Check Path	
	if [ ! -f "$DESKTOP_LINKS_PATH/discoed.desktop" ]; then
		log_data "<ERROR> Falied to create desktop link"
		xdg-open "$CWD/discoed.log"
		exit 1
	fi
	MESSAGE="Desktop link created successfully"
	printf "[INFO] %s\n" "$MESSAGE"
	log_data "<INFO> %s" "$MESSAGE"
# ----> Update Desktop Link
	sed -i "s|{discoed.sh}|$CWD/discoed.sh|g" "$DESKTOP_LINKS_PATH/discoed.desktop"
	sed -i "s|{discoed.png}|$CWD/discoed.png|g" "$DESKTOP_LINKS_PATH/discoed.desktop"
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
	printf "\33[1;36m[INFO]\33[0m Up to date\n"
else
	MESSAGE="Update needed"
	printf "\33[1;33m[WARN]\33[0m \33[1;35m<!>\33[0m %s\n" "$MESSAGE"
	log_data "<WARN> $MESSAGE $LOCAL_VERSION >> $EXTRN_VERSION"
	install_discord
fi

run_discord