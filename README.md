tflobby
=======

this module was designed to play nicely with [hubot](https://github.com/github/hubot). it's pretty easy to set up and use for your own chat bot and team fortress game servers.

##### configuration

+ `HUBOT_AUTH_ADMIN`: comma-separated list of nicknames
+ `TFLOBBY_MAPS`: comma-separated list of available maps
+ `TFLOBBY_POPULAR_MAPS`: comma-separated list of popular maps (they must be present in TFLOBBY_MAPS)
+ `TFLOBBY_GAME_SERVERS`: stringified json. schema: `{ "servername": { "name": string, "host": string, "port": integer, "tv": string, "password": string, "rcon": string } }`
+ `TFLOBBY_DEFAULT_SERVER`: string corresponding to TFLOBBY_GAME_SERVERS servername

adding and configuring the `hubot-auth` script is recommended if you plan on using this module with (or without) rcon capability. in fact, this script assumes you've assigned `admin`, `officer` and `rcon` roles. let's face it, if you're going to provide a public lobby system, you don't want any old tom, dick or harry playing with your rcon commands or cancelling your lobby while it's still waiting for players.

this module is yours to do with **as you please** - public domain, muddafuckas.
