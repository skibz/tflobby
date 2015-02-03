tflobby [![Build Status](https://travis-ci.org/skibz/tflobby.svg?branch=master)](https://travis-ci.org/skibz/tflobby)
-------

##### abstract

this module was designed to play nicely with [hubot](https://github.com/github/hubot). it's pretty easy to set up and use for your own chat bot and team fortress game servers.

adding and configuring the `hubot-auth` script is recommended if you plan on using this module with (or without) rcon capability. in fact, this script assumes you've assigned `admin`, `officer` and `rcon` roles. let's face it, if you're going to provide a public lobby system, you don't want any old tom, dick or harry playing with your rcon commands or cancelling your lobby while it's still waiting for players.

##### configuration

refer to [`src/index.coffee`](https://github.com/skibz/tflobby/blob/master/src/index.coffee) for configuration information.

this module is yours to do with **as you please** - public domain, muddafuckas.
