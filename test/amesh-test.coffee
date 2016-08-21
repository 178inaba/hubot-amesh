Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/amesh.coffee')

describe 'amesh', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'not set env', ->
    @room.user.say('inaba', '@hubot amesh').then =>
      expect(@room.messages).to.eql [
        ['inaba', '@hubot amesh']
        ['hubot', 'Please set env HUBOT_AMESH_IMGUR_CLIENT_ID']
      ]

  it 'hears orly', ->
    @room.user.say('bob', 'just wanted to say orly').then =>
      expect(@room.messages).to.eql [
        ['bob', 'just wanted to say orly']
        ['hubot', 'yarly']
      ]
