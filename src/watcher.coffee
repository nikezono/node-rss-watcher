###
#
# watcher.coffee
#
# Author:@nikezono
#
####

{EventEmitter} = require 'events'
parser = require 'parse-rss'

fetchFeed = (feedUrl,callback)=>
  parser feedUrl,(err,articles)=>
    return callback err,null if err?

    articles.sort (a,b)->
      return a.pubDate/1000 - b.pubDate/1000

    return callback null,articles


# Feed Watcher. Allocate one watcher per single feed
class Watcher extends EventEmitter

  constructor:(feedUrl)->
    throw new Error("arguments error.") if not feedUrl or feedUrl is undefined
    super()

    @feedUrl = feedUrl
    @interval = null
    @lastPubDate = null
    @lastPubTitle = null
    @timer = null
    @watch = =>

      fetch = =>
        fetchFeed @feedUrl,(err,articles)=>
          return @emit 'error', err if err

          for article in articles
            if (@lastPubDate is null and @lastPubTitle is null) or
            (@lastPubDate <= article.pubDate / 1000 and @lastPubTitle isnt article.title)
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

    initialize = (callback)=>
      fetchFeed @feedUrl,(err,articles)=>
        return callback new Error(err),null if err? and callback?
        @lastPubDate = articles[articles.length-1].pubDate / 1000
        @lastPubTitle = articles[articles.length-1].title
        @timer = @watch()
        return callback null, articles if callback?

    # if mean interval for updating feed does not set, calculate it by current feed object.
    if not @interval or typeof @interval is 'function'
      fetchFeed @feedUrl, (error, articles)->
        if error?
          return callback new Error(error),null if callback?

        sumOfUpdateDiff = 0
        prevUpdate = Date.now()
        for article in articles
          sumOfUpdateDiff += prevUpdate - article.pubDate
          prevUpdate = article.pubDate
        interval = sumOfUpdateDiff / articles.length

        if typeof @interval is 'function'
          @interval = @interval(interval)
        else
          @interval = interval

        if isNaN(@interval / 1)
          return callback new Error("interval object isn't instanceof Number"),null if callback?
        if @interval < 0
          return callback new Error("interval can't be negative value"),null if callback?

        return initialize(callback)
    else
      return initialize(callback)

  stop:=>
    if not @timer
      throw new Error("RSS-Watcher isnt running now")

    clearInterval(@timer)
    @emit 'stop'



module.exports = Watcher
