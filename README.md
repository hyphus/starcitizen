# Star Citizen Settings

`set-sc-settings.ps1` allows you to automatically configure your Star Citizen settings and keybinds without having to import or manually change anything in game.

It's a quick hacky script that works on my machine. Hopefully it'll work for you as well.

## Usage

Change the settings in `set-sc-settings.ps1` to whatever you want to have configured. Current settings are found in `attributes.xml` under your user profile.
If you've exported keybinds (mine are in `layout_hotas_exported.xml`) you can point the script at that xml document and it will import them directly, no need to load a profile.
It will also generate a `USER.cfg` for you as well.

Once you have your settings configured just right click the script and select `Run with PowerShell`.

The only prerequisite is you have to have opened the game to the menu at least once before running this script.
Otherwise some necessary files/directory structure doesn't exist.

Also, if you run the script more than once it will duplicate your keybinds. Easiest way to run this is just to blow away the user folder and start fresh.