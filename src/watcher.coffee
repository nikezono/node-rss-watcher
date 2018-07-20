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
    @lastPubTitles = []
    @timer = null
    @watch = =>

      fetch = =>
        fetchFeed @feedUrl,(err,articles)=>
          return @emit 'error', err if err

          for article in articles
            if @isNewArticle(article)
              @emit 'new article',article
              @updateLastPubArticle(article)

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

  updateLastPubArticle:(article)=>
    newPubDate = article.pubDate / 1000
    if @lastPubDate == newPubDate
      @lastPubTitles.push(article.title)
    else
      @lastPubTitles = [article.title]
    @lastPubDate = newPubDate

  isNewArticle:(article)=>
    return (@lastPubDate is null and @lastPubTitles.length == 0) or
            (@lastPubDate <= article.pubDate/1000 and article.title not in @lastPubTitles)

  run:(callback)=>

    initialize = (callback)=>
      fetchFeed @feedUrl,(err,articles)=>
        return callback new Error(err),null if err? and callback?
        @lastPubDate = articles[articles.length-1].pubDate / 1000
        @lastPubTitle = articles[articles.length-1].title
        @timer = @watch()
        return callback null, articles if callback?

    if not @interval
      @interval = 60 * 5 # 5 minutes... it's heuristic

    return initialize(callback)

  stop:=>
    if not @timer
      throw new Error("RSS-Watcher isnt running now")

    clearInterval(@timer)
    @emit 'stop'



module.exports = Watcher
