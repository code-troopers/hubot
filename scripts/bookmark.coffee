# Description:
#   Manage your links. Links get stored in the robot brain.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot link <url> as <description> - add a url to the robot brain
#   hubot link me for <description> - find a link by description
#   hubot list links - List all of the links that are being tracked
#
# Author
#   mm53bar, adapted by mattboll

module.exports = (robot) ->
        
  robot.respond /link (http(s?)\:\/\/\S+) as (.+)/i, (msg) ->
    url = msg.match[1]
    description = msg.match[3]    
    bookmark = new Bookmark url, description
    link = new Link robot
  
    link.add bookmark, (err, message) ->
      if err?
        msg.reply "I have a vague memory of hearing about that link sometime in the past."
      else
        msg.reply "I've stuck that link into my robot brain." 
        
  robot.respond /link me for (.+)/i, (msg) ->
    description = msg.match[1]
    link = new Link robot
    
    link.find description, (err, bookmark) ->
      if err?
        msg.send "#{err}"
      else
        msg.send bookmark.url
           
  robot.respond /list links/i, (msg) ->
    link = new Link robot
    
    link.list (err, message) ->
      if err?   
        msg.reply "Links? What links? I don't remember any links."       
      else
        msg.reply message

# Classes

class Link
  constructor: (robot) ->
    robot.brain.data.links ?= []
    @links_ = robot.brain.data.links

  all: (bookmark) ->
    if bookmark
      @links_.push bookmark
    else
      @links_

  add: (bookmark, callback) ->
    result = []
    @all().forEach (entry) ->
      if entry
        if entry.url is bookmark.url
          result.push bookmark
    if result.length > 0
      callback "Bookmark already exists"
    else
      @all bookmark
      callback null, "Bookmark added"    

  list: (callback) ->
    if @all().length > 0
      resp_str = "These are the links I'm remembering:\n\n"
      for bookmark in @all()
        if bookmark
          resp_str += bookmark.description + " (" + bookmark.url + ")\n"
      callback null, resp_str    
    else
      callback "No bookmarks exist"

  find: (description, callback) ->
    result = []
    @all().forEach (bookmark) ->
      if bookmark && bookmark.description
        if RegExp(description, "i").test bookmark.description
          result.push bookmark
    if result.length > 0
      callback null, result[0]
    else
      callback "No results found"

class Bookmark
  constructor: (url, description) ->
    @url = url
    @description = description

  encodedUrl: ->
    encodeURIComponent @url

  encodedDescription: ->
    encodeURIComponent @description
