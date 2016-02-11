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
#   hubot random trooper - get one trooper
#   hubot loser - get a random loser
#
# Author:
#   mattboll

troopers = [
  'cgatay',
  'rlucas',
  'benou',
  'jojo',
  'nanak',
  'mattboll',
  'vmaubert'
]
loosers = troopers.concat([
  'mbitard',
  'tdebarochez'
])

reply = (list) ->
  '@' + list[Math.floor(Math.random() * list.length)]

module.exports = (robot) ->
  robot.respond /random trooper/i, (msg) ->
    msg.reply(reply(troopers.filter((nick) -> nick != msg.message.user.name)))
  robot.respond /random looser/i, (msg) ->
    msg.reply(reply(loosers.filter((nick) -> nick != msg.message.user.name)))
