- [x] finish porting existing tfbot code
  + [x] add http calls for steam group announcements https://github.com/github/hubot/blob/master/docs/scripting.md#making-http-calls
  + [x] check a users auth status if they try do something admin'ey
- [ ] unit testing with hubot-mock-adapter
- [x] document entire pickups script https://github.com/github/hubot/blob/master/docs/scripting.md#documenting-scripts
- [x] encapsulate pickups script https://github.com/github/hubot/blob/master/docs/scripting.md#creating-a-script-package
- [x] remove adverbs from bot responses, ie 'currently'
- [ ] rather than deleting the !top data after every !reset, add it to the brain under an 'all-time' counter
- [ ] With regards to the random maps, it should be made so that the same map should not be chosen twice.
- [ ] clean up the source a little - change control flow structures, use `unless` instead of `if not`, etc.
- [ ] remove any steam group announcement stuff
- [ ] change the `servers` data structure to be dynamically created at runtime using an env var. the format for the env var could be something like: TFLOBBY_GAME_SERVERS=is1/192.168.0.2/12345/192.168.0.2:12345/games/is1_isdabest. plain english: servername/hostaddress/port/tvaddress/serverpass/rcon. many servers can be specified if they are comma separated. parsing this format is trivial.
