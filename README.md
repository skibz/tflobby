tflobby [![Build Status](https://travis-ci.org/skibz/tflobby.svg?branch=master)](https://travis-ci.org/skibz/tflobby)
-------

##### abstract

this module was designed to play nicely with [hubot](https://github.com/github/hubot). it's pretty easy to set up and use for your own chat bot and team fortress game servers.

adding and configuring the `hubot-auth` script is recommended if you plan on using this module with (or without) rcon capability. in fact, this script assumes you've assigned `admin`, `officer` and `rcon` roles. let's face it, if you're going to provide a public lobby system, you don't want any old tom, dick or harry playing with your rcon commands or cancelling your lobby while it's still waiting for players.

##### configuration

as outlined in [`src/index.coffee`](https://github.com/skibz/tflobby/blob/master/src/index.coffee), we ought to specify:

- `HUBOT_AUTH_ADMIN` a comma-separated list of nicknames to set as super-admins
- `TFLOBBY_MAPS` a comma-separated list of map names
- `TFLOBBY_POPULAR_MAPS` a comma-separated list of popular maps
- `TFLOBBY_GAME_SERVERS` escaped json array of objects containing the properties `name`, `host`, `port`, `rcon`, `password` and `tv`.
- `TFLOBBY_DEFAULT_SERVER` name of default server corresponding to an entry in `TFLOBBY_GAME_SERVERS`

and remember, this module is yours to do with **as you please** - [public domain](https://github.com/skibz/tflobby/blob/master/UNLICENSE), muddafuckas!
