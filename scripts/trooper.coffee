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

module.exports = (robot) ->
  robot.respond /random trooper/i, (msg) ->
    msg.reply trooper 7
  robot.respond /random looser/i, (msg) ->
    msg.reply trooper 9

trooper = (max) ->
  num = Math.floor(Math.random() * max)
  switch num
    when 0
      "@cgatay"
    when 1
      "@rlucas"
    when 2
      "@benou"
    when 3
      "@jojo"
    when 4
      "@nanak"
    when 5
      "@mattboll"
    when 6
      "@vmaubert"
    when 7
      "@mbitard"
    when 8
      "@tdebarochez"

