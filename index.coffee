fs   = require 'fs'
Path = require 'path'

module.exports = (robot) ->
  path = Path.resolve __dirname, 'scripts'
  fs.exists path, (exists) ->
    if exists
      for file in fs.readdirSync(path)
        robot.loadFile path, file
        robot.parseHelp Path.join(path, file)
