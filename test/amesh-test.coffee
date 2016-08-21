Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

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

  it 'normal', ->
    nock('http://tokyo-ame.jwa.or.jp')
      .get('/map/map000.jpg')
      .replyWithFile(200, __dirname + '/img/map000.jpg')
      .get('/map/msk000.png')
      .replyWithFile(200, __dirname + '/img/msk000.png')
      .get(/\/mesh\/000\/.*\.gif/)
      .replyWithFile(200, __dirname + '/img/000000000000.gif')

    nock('https://api.imgur.com')
      .post('/3/image.json')
      .reply(200,
        data:
          id: 'xxxxxxx'
          deletehash: 'xxxxxxxxxxxxxxx'
          link: 'http://i.imgur.com/xxxxxxx.png'
      )

    process.env.HUBOT_AMESH_IMGUR_CLIENT_ID = 'test_client_id'
    @room.user.say('inaba', '@hubot amesh').then =>
      expect(@room.messages).to.eql [
        ['inaba', '@hubot amesh']
        ['hubot', 'http://i.imgur.com/xxxxxxx.png']
      ]
