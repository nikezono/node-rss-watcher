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
    @feedUrl  = obj.feedUrl if obj.feedUrl?
    @interval = obj.interval if obj.interval? && obj.interval > 100
    return true

  run:(done)=>
    if not @feedUrl
      throw new Error("Feed Url Not Found")

    # Freq
    if not @interval
      frequency = require 'rss-frequency'
      frequency @feedUrl ,(error,interval)=>
        if error
          throw new Error(error)
        @interval = interval

        @timer = @watch @feedUrl,@interval
        done() if done?

    else
      @timer = @watch @feedUrl,@interval
      done() if done?

  stop:->
    if not @timer
      throw new Error("RSS-Watcher isnt running now")

    clearInterval(@timer)
    @emit 'stop'

module.exports = Watcher
