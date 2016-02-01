# Description:
#   Allows Hubot to roll humans
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot assign random url - create a card with url in odj / PR with a random user
#   hubot assign random url not user - create a card with url in odj / PR with a random user but not user
#
# Author:
#   mattboll

{spawn} = require 'child_process'

module.exports = (robot) ->
  robot.respond /assign random (.+)/i, (msg) ->
    ls = spawn 'bin/trello', msg.match[1].split(' ')
    # receive all output and process
    ls.stdout.on 'data', (data) -> msg.reply data.toString().trim()
    # receive error messages and process
    ls.stderr.on 'data', (data) -> msg.reply data.toString().trim()
