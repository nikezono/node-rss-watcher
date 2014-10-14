###
#
# watcher.coffee
#
# Author:@nikezono
#
####

{EventEmitter} = require 'events'
parser = require 'parse-rss'

class Watcher extends EventEmitter

  constructor:(feedUrl)->
    throw new Error("arguments error.") if not feedUrl or feedUrl is undefined
    @feedUrl = feedUrl
    @interval = null
    @lastPubDate = null
    @lastPubTitle = null
    @timer = null
    @watch = =>

      fetch = =>
        request @feedUrl,(err,articles)=>
          return @emit 'error', err if err

          for article in articles
            if (@lastPubDate is null and @lastPubTitle is null) or
            (@lastPubDate <= article.pubDate/1000 and @lastPubTitle isnt article.title)
              @emit 'new article',article
              @lastPubDate = article.pubDate / 1000
              @lastPubTitle = article.title

      return setInterval ->
        fetch(@feedUrl)
      ,@interval*1000


  set:(obj)->
    flag = false
    if obj.feedUrl?
      @feedUrl  = obj.feedUrl if obj.feedUrl?
      flag = true
    if obj.interval?
      @interval = obj.interval if obj.interval?
      flag = true
    return flag

  run:(callback)=>

    # 正常系 #
    initialize = (callback)=>
      request @feedUrl,(err,articles)=>
        return callback new Error(err),null if err? and callback?
        @lastPubDate = articles[articles.length-1].pubDate / 1000
        @timer = @watch()
        return callback null,articles if callback?

    # 更新頻度を取得して利用 #
    if not @interval or typeof @interval is 'function'
      frequency = require 'rss-frequency'
      frequency @feedUrl,(error,interval)=>

        if error?
          return callback new Error(error),null if callback?

        if typeof @interval is 'function'
          @interval = @interval(interval)
        else
          @interval = interval

        if isNaN(@interval / 1)
          return callback new Error("interval object isnt instanceof Number"),null if callback?
        if @interval / 1 < 0
          return callback new Error("interval has given negative value"),null if callback?

        return initialize(callback)
    else
      return initialize(callback)

  stop:=>
    if not @timer
      throw new Error("RSS-Watcher isnt running now")

    clearInterval(@timer)
    @emit 'stop'

request = (feedUrl,callback)=>
  parser feedUrl,(err,articles)=>
    return callback err,null if err?

    articles.sort (a,b)->
      return a.pubDate/1000 - b.pubDate/1000

    return callback null,articles

module.exports = Watcher
