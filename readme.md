# Discoed

> [!NOTE]
> This script only works on manually installed Discord using the `.tar.gz` option

Most Auto-Update scripts don't actually update the program.
Instead they increment the `build_info.json` until Discord stops showing the Update popup.

This script is not that. This will actually update to the latest build, if you have installed Discord manually using the `.tar.gz` option.

> [!IMPORTANT]
> Make sure you have the following tools installed:

- curl
- wget
- tar

There are a few variables which need to be updated inside the script as well as inside the `.desktop` file

```sh
# discoed.sh

DISCORD_BRANCH=...
DISCORD_PATH=...
DOWNLOADS_PATH=...

# each variable is commented and explained within the file

# ----

# discoed.desktop

Exec=...
Icon=...
```
