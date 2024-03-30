# Discoed

<p align="center"><image src="https://raw.githubusercontent.com/ionutrogojan/discoed/main/discoed.png" width=256px/></p>

> [!NOTE]
> This script only works on manually installed Discord using the `.tar.gz` option

Most Auto-Update scripts don't actually update the program.
Instead they increment the `build_info.json` until Discord stops showing the Update popup.

This script is not that. This will actually update to the latest build using the `.tar.gz` option, install Discord if it's missing and create a `.desktop` link for quick launch from your launcher of choice.

> [!IMPORTANT]
> Make sure you have the following tools installed:

- curl
- wget
- tar
- realpath
- grep
- sed

There are a few variables which need to be updated inside the script file.
The script will warn and open itself to update the values if it fails.
It will also create and update a `.log` file and append any useful information.

```sh
# discoed.sh

DISCORD_BRANCH=...
DISCORD_PATH=...
DOWNLOADS_PATH=...

# each variable is commented and explained within the file
```