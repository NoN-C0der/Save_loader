# Save_loader

Garry's Mod save loader for dedicated servers with a GUI menu and ULX integration.

## Features
- GUI menu listing server saves.
- ULX command + access flag to limit usage to admins.
- Server-side validation and save loading.

## Installation
1. Copy the `save_loader` folder into your server's `garrysmod/addons/` directory.
2. Restart the server.

## Usage
- ULX admins can open the menu with `!loadmenu` or `ulx loadmenu`.
- Access is controlled by ULX permission `save_loader` (defaults to admins).
- The addon loads `.gms` files from `garrysmod/saves` on the server.

## Notes
- The addon issues the `load <save>` console command on the server.
- Make sure your saves are compatible with the current map.
