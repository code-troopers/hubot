# Description:
#   Watch your language!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   whitman, jan0sch

module.exports = (robot) ->

  words = [
    'bitch',
    'cock',
    'dick',
    'fuck',
    'scheisse',
    'schlampe',
    'connard',
    'batard',
    'pute',
    'fred',
    'fmorin'
  ]
  regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\s|\\.|\\?|!|$)', 'i');

  robot.hear regex, (msg) ->
    msg.send 'You have been fined one credit for a violation of the verbal morality statute.'
