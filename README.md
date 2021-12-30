English Translation by MonkeyWhisper

# qb-bossmenu
New bossmenu converted to qb-menu and qb-input.
qb-bossmenu and qb-gangmenu converted to qb-menu, merged into a single resource, and saves the account in the database.
I have converted the function that looks for server-side players, so that I can have more information about the players nearby.
I rewrote most of the events.
if there are any problems or other, do not hesitate to contact me or to open a pool request

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-logs](https://github.com/qbcore-framework/qb-logs)
- [qb-input](https://github.com/qbcore-framework/qb-input)
- [qb-menu](https://github.com/qbcore-framework/qb-menu)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory)
- [qb-clothing](https://github.com/qbcore-framework/qb-clothing)

## Screenshots
![qbmenu](https://i.imgur.com/QThNGUz.png)
![qbinput](https://i.imgur.com/syuyXJ7.png)

## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Import `qb-bossmenu.sql` in your database
- Edit config.lua with coords
- Add the following code `ensure qb-bossmenu` to your server.cfg/resouces.cfg

## ATTENTION
### YOU NEED TO CREATE A COLUMN IN DATABASE WITH NAME OF SOCIETY IN BOSSMENU TABLE OR GANG IN GANGMENU TABLE
![database](https://i.imgur.com/JZnEK4M.png)
