# Description:
#   Est-ce que c'est bientot le weekend ?
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot estcequecestbientotleweekend
#
# Author:
#   mattboll
http = require 'http'
cheerio = require 'cheerio'

module.exports = (robot) ->

  robot.respond /estcequecestbientotleweekend/i, (msg)->
    http.get { host: 'estcequecestbientotleweekend.fr' }, (res) ->
      data = ''
      res.on 'data', (chunk) ->
          data += chunk.toString()
      res.on 'end', () ->
          $ = cheerio.load(data)
          p = $("p")
          np = p.text()
          np = np.replace /\s/g, " "
          np = np.replace /\ \ */g, " "
          msg.send np
