# Description:
#   Stores the brain in Postgres
#
# Configuration:
#   DATABASE_URL
#
# Notes:
#   Run the following SQL to setup the table and column for storage.
#
#   CREATE TABLE hubot (
#     id CHARACTER VARYING(1024) NOT NULL,
#     storage TEXT,
#     CONSTRAINT hubot_pkey PRIMARY KEY (id)
#   );
#  insert into hubot values('1', '{}');
#
# Author:
#   Yannick Schutz

Postgres = require 'pg'

# sets up hooks to persist the brain into postgres.
module.exports = (robot) ->

  database_url = process.env.DATABASE_URL

  if !database_url?
    throw new Error('pg-brain requires a DATABASE_URL to be set.')

  client = new Postgres.Client(database_url)
  client.connect()

  query = client.query("SELECT storage FROM hubot LIMIT 1")
  client.on "error", (err) ->
    robot.logger.error err
  query.on 'row', (row) ->
    if row['storage']?
      robot.logger.error "pg-brain loading."
      robot.brain.mergeData JSON.parse(row['storage'].toString())
      robot.logger.error "pg-brain loaded."


  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET storage = $1", [JSON.stringify(data)])
    query.on 'error', (error) ->
      robot.logger.error error
    
  robot.brain.on 'close', ->
    client.end()

