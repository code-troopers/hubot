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
#   hubot ls - list
#
# Author:
#   mattboll

{spawn} = require 'child_process'

module.exports = (robot) ->
  robot.respond /exec (.+)/i, (msg) ->
    msg.reply 'coucou'
    ls = spawn msg.match[1].split(' ')[0], msg.match[1].split(' ').slice(1, -1)
    # receive all output and process
    ls.stdout.on 'data', (data) -> msg.reply data.toString().trim()
    # receive error messages and process
    ls.stderr.on 'data', (data) -> msg.reply data.toString().trim()
