#!/bin/bash

DISCORD_BRANCH="stable"    # canary | ptb | stable ; Replace with one of this values
INSTALL_PATH="/mnt/SSD/Programs" # the real path up to, but not including, the Discord directory ; Replace this with your path
DOWNLOADS_PATH="$HOME/Downloads" # your desired download location ; The archive will be removed after update, so it doesn't matter what you set this to ; Defaults to the Downloads directory

# ----> !! Do not Edit !!
DISCORD_BUILD_INFO="$INSTALL_PATH/Discord/resources/build_info.json"
DISCORD_API="https://discord.com/api/updates/$DISCORD_BRANCH?platform=linux"
DISCORD_DOWNLOAD="https://discord.com/api/download?platform=linux&format=tar.gz"
DESKTOP_LINKS_PATH="$HOME/.local/share/applications"
DESKTOP_FILE_PATH="$DESKTOP_LINKS_PATH/discoed.desktop"
CWD=$(dirname $(realpath "$0"))
LOG_FILE_PATH="$CWD/discoed.log"

log_data() {
	DATA="$1"
	NOW=$(date "+%d-%m-%Y %H:%M")
	printf "[%s] %s\n" "$NOW" "$DATA" >> "$LOG_FILE_PATH"
}

warn_error() {
	ERROR="$1"
	printf "\33[1;35m[ERROR]\33[0m %s\n" "$ERROR"
	log_data "<ERROR> $ERROR"
	xdg-open "$LOG_FILE_PATH"
	exit 1
}

install_discord() {
	if [ ! -d "$DOWNLOADS_PATH" ]; then
		ERROR="\$DOWNLOADS_PATH does not exist at the specified path"
		xdg-open "$0"
		warn_error "$ERROR"
	fi
	if [ ! -d "$INSTALL_PATH" ]; then
		ERROR="\$INSTALL_PATH does not exist at the specified path"
		xdg-open "$0"
		warn_error "$ERROR"
	fi
# ----> Download Discord
	DISCORD_TAR="$DOWNLOADS_PATH/discord-$EXTRN_VERSION.tar.gz"
	wget -O $DISCORD_TAR $DISCORD_DOWNLOAD
	if [ ! $? -eq 0 ]; then
		ERROR="wget failed to retrieve discord tarball"
		warn_error "$ERROR"
	fi
# ----> Extract & Replace
	tar -xzf $DISCORD_TAR --overwrite -C $INSTALL_PATH
	if [ ! $? -eq 0 ]; then
		ERROR="tar failed to extract or replace the contents at the specified path"
		warn_error "$ERROR"
	fi
# ----> Remove Tar
	rm -rf $DISCORD_TAR
	if [ ! $? -eq 0 ]; then
		ERROR="rm failed to remove the temporary tar file downloaded"
		warn_error "$ERROR"
	fi
	log_data "<INFO> Discord updated to the latest version $EXTRN_VERSION"
}

run_discord() {
	if [ ! -e "$INSTALL_PATH/Discord/Discord" ]; then
		ERROR="Discord executable does not exist at the specified path"
		xdg-open "$0"
		warn_error "$ERROR"
	fi
# ----> Run Discord
	"$INSTALL_PATH/Discord/Discord" &
	printf "[INFO] Discord ready to open\n"
}

# ----> Find Desktop Link
if [ ! -f "$DESKTOP_FILE_PATH" ]; then
	MESSAGE="Missing 'discoed.desktop' link from quick launcher"
	printf "[INFO] %s\n" "$MESSAGE"
	log_data "<INFO> $MESSAGE"
# ----> Copy Desktop Link
	cp "$CWD/discoed.desktop" "$DESKTOP_LINKS_PATH"
	if [ ! $? -eq 0 ]; then
		ERROR="cp failed to copy the 'discoed.desktop' file to its destination path"
		warn_error "$ERROR"
	fi
# ----> Check Path	
	if [ ! -f "$DESKTOP_LINKS_PATH/discoed.desktop" ]; then
		ERROR="Falied to create desktop link"
		warn_error "$ERROR"
	fi
	MESSAGE="Desktop link created successfully"
	printf "[INFO] %s\n" "$MESSAGE"
	log_data "<INFO> $MESSAGE"
# ----> Update Desktop Link
	sed -i "s|{discoed.sh}|$CWD/discoed.sh|g" "$DESKTOP_FILE_PATH"
	sed -i "s|{discoed.png}|$CWD/discoed.png|g" "$DESKTOP_FILE_PATH"
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