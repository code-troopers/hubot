# Description:
#   Allows Hubot to store a chat history in ElasticSearch and make searches by http calls
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_ELASTICSEARCH_URL
#
# Commands:
#   hubot show [<lines> lines of] history - Shows <lines> of history, otherwise all history
#   hubot search <keyword> - Search history for lines containing keyword
#
# Author:
#   wubr, adapted by mattboll
require 'http'

class History
  constructor: (@robot, @keep) ->
    @cache = []
    @robot.brain.on 'loaded', =>
      if @robot.brain.data.history
        @robot.logger.info "Loading saved chat history"
        @cache = @robot.brain.data.history

  add: (msg, message) ->
    @cache.push message
    while @cache.length > @keep
      @cache.shift()
    @robot.brain.data.history = @cache
    #msg.http(process.env.HUBOT_ELASTICSEARCH_URL)
    #    .post(JSON.stringify(message)) (err, res, body) ->
    #      if err
    #        msg.send "couldn't save history : #{err}"

  show: (lines) ->
    if (lines > @cache.length)
      lines = @cache.length
    reply = 'Showing ' + lines + ' lines of history:\n'
    reply = reply + @entryToString(message) + '\n' for message in @cache[-lines..]
    return reply

  entryToString: (event) ->
    return '[' + event.hours + ':' + event.minutes + '] ' + event.name + ': ' + event.message

  clear: ->
    @cache = []
    @robot.brain.data.history = @cache

class HistoryEntry
  constructor: (@name, @message) ->
    @time = new Date()
    @hours = @time.getHours()
    @minutes = @time.getMinutes()
    if @minutes < 10
      @minutes = '0' + @minutes

module.exports = (robot) ->

  options = 
    lines_to_keep: 10

  history = new History(robot, options.lines_to_keep)

  robot.hear /(.*)/i, (msg) ->
    historyentry = new HistoryEntry(msg.message.user.name, msg.match[1])
    history.add msg,historyentry

  robot.respond /show ((\d+) lines of )?history/i, (msg) ->
    if msg.match[2]
      lines = msg.match[2]
    else
      lines = 10
    msg.send history.show(lines)

  robot.respond /search (.*)/i, (msg) ->
    msg.http(process.env.HUBOT_ELASTICSEARCH_URL + "/_search?q=" + msg.match[1])
        .get() (err, res, body) ->
          if err
            msg.send "No result : #{err}"
          else
            data = null
            try
              data = JSON.parse body.toString()
              data.hits.hits.forEach (elem, i) ->
                elemDate = elem._source.time.replace /T/, " "
                elemDate = elemDate.replace /:..\..*/, ""
                msg.send "<#{elemDate}> #{elem._source.name} #{elem._source.message}" 
            catch error
              msg.send "Ran into an error parsing JSON :("
