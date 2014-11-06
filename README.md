tflobby
=======

this module was designed to play nicely with hubot.

if you'd like to specialise this module for your own means, then you'd have to decouple the hubot variables expected to be present in each function.

otherwise, it's pretty easy to set up and use for your own chat bot and game servers. just have a look in `src/lobby.coffee` and change the game servers listed in the `servers` variable to reflect the servers you'd like to be available.

also, note the environment variables expected to be present in the `servers` variable. they aren't required, but if you have an rcon password, you can add it and then administer your server via the chat bot. rcon operations are limited to map change, player roster reporting and arbitrary text messaging at the moment.

it's highly recommended to configure the `hubot-auth` script if you plan on using this module with (or without) rcon capability. if you're going to set up a public lobby system, you don't want any old tom, dick or harry playing with your rcon commands or cancelling your lobby while it's still waiting for players.

this module is yours to do with _as you please_ - public domain, muddafuckas.
