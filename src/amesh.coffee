# Description
#   A hubot script that does the things
#
# Configuration:
#   HUBOT_AMESH_IMGUR_CLIENT_ID - Your imgur client id.
#
# Commands:
#   hubot amesh - Send amesh image Link.
#
# Notes:
#   The script requires ImageMagick.
#
# Author:
#   178inaba <178inaba@users.noreply.github.com>

fs = require 'fs'
os = require 'os'
path = require 'path'

async = require 'async'
gm = require('gm').subClass imageMagick: true
moment = require 'moment'
require 'moment-round'
momentTz = require 'moment-timezone'
request = require 'request'
sprintf = require('sprintf-js').sprintf

baseUrl = 'http://tokyo-ame.jwa.or.jp/'
mapPath = 'map/map000.jpg'
mskPath = 'map/msk000.png'
meshFmt = 'mesh/000/%s.gif'
saveFilenameFmt = '%s.png'
imgurOpts = {
  url: 'https://api.imgur.com/3/image.json'
  headers: {}
  formData: {}
  json: true
}

module.exports = (robot) ->
  robot.respond /amesh/, (res) ->
    main res

main = (res) ->
  clientID = process.env.HUBOT_AMESH_IMGUR_CLIENT_ID
  if !clientID
    console.error 'Please set env HUBOT_AMESH_IMGUR_CLIENT_ID.'
    return

  imgurOpts.headers.Authorization = 'Client-ID ' + clientID

  fileName = getFilename()
  fs.mkdir getSaveDir(), (err) ->
    if err && err.code != 'EEXIST'
      console.error err.message
      return

    async.mapValues
      map: baseUrl + mapPath
      mesh: baseUrl + sprintf meshFmt, fileName
      msk: baseUrl + mskPath
      (url, key, callback) ->
        dlImg url, callback
      (err, results) ->
        composite results.map, results.mesh, results.msk, fileName, res

composite = (map, mesh, msk, fileName, res) ->
  saveFile = getSaveDir() + sprintf saveFilenameFmt, fileName
  gm(map)
    .composite(mesh)
    .write saveFile, (err) ->
      gm(saveFile)
        .composite(msk)
        .write saveFile, (err) ->
          upload saveFile, res

upload = (uploadFile, res) ->
  imgurOpts.formData.image = fs.createReadStream(uploadFile)
  request.post imgurOpts, (err, resp, body) ->
    console.log body
    console.log err
    res.send body.data.link

dlImg = (url, callback) ->
  filePath = getSaveDir() + path.basename url
  request.get {url: url, encoding: null}, (err, resp, body) ->
    fs.writeFile filePath, body, 'binary' if !err && resp.statusCode == 200
    callback null, filePath

getFilename = ->
  moment(momentTz().tz('Asia/Tokyo'))
    .floor(5, 'minutes')
    .format('YYYYMMDDHHmm')

getSaveDir = ->
  os.tmpdir() + path.sep + 'hubot-amesh' + path.sep
