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
    @timer = null
    @watch = (url,interval)=>

      fetch = (feedUrl)=>
        parser feedUrl,(err,articles)=>
          return @emit 'error', err if err

          articles.sort (a,b)->
            return a.pubDate/1000 - b.pubDate/1000

          for article in articles
            if not @lastPubDate or @lastPubDate < article.pubDate/1000
              @emit 'new article',article
              @lastPubDate = article.pubDate / 1000

      fetch(url)
      return setInterval ->
        fetch(url)
      ,interval


  set:(obj)->
    flag = false
    if obj.feedUrl?
      @feedUrl  = obj.feedUrl if obj.feedUrl?
      flag = true
    if obj.interval?
      @interval = obj.interval if obj.interval?
      flag = true
    return flag

  run:(done)=>

    if not @interval or typeof @interval is 'function'
      frequency = require 'rss-frequency'
      frequency @feedUrl ,(error,interval)=>
        if error
          return done new Error(error)

        if typeof @interval is 'function'
          @interval = @interval(interval)
        else
          @interval = interval

        if isNaN(@interval / 1)
          return done new Error("interval object isnt instanceof Number") if done?
        if @interval / 1 <= 100
          return done new Error("interval is too narrow or negative value") if done?

        @timer = @watch @feedUrl,@interval
        return done() if done?

    else
      @timer = @watch @feedUrl,@interval
      return done() if done?

  stop:->
    if not @timer
      throw new Error("RSS-Watcher isnt running now")

    clearInterval(@timer)
    @emit 'stop'

module.exports = Watcher
