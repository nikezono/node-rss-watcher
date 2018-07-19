###
#
# test.coffee
# Author:@nikezono, 2014/06/27
#
###


# dependency
path = require 'path'
assert = require 'assert'

# Feed Repo
feed = "https://github.com/nikezono.atom"

Watcher = require '../lib/watcher'

describe "rss-watcher",->

  it "can compile",(done)->
    watcher = new Watcher(feed)
    assert.notEqual watcher,null
    done()

  it "can raise error if feed url is null",->
    assert.throws ->
      watcher = new Watcher()
    ,Error

  it "can emit error if feed url is invalid",(done)->
    watcher = new Watcher("hoge")
    watcher.run (err,articles)->
      assert.ok err instanceof Error
      done()

  it "#3 最初にまとめて読める",(done)->
    watcher = new Watcher(feed)
    watcher.run (err,articles)->
      assert.ok articles.length > 0
      done()

  it "option",(done)->
    watcher = new Watcher(feed)
    assert.ok watcher.set
      feedUrl:feed
      interval:10000
    watcher.run (err,articles)->
      done()

  it "option #2:関数を引数に取れる",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(frequency)->
        if frequency > 1000
          return frequency-1000
        else
          frequency
    watcher.run (err,articles)->
      done()

  it "option #2:マイナスの値は指定できない",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(freq)->
        return -1000
    watcher.run (err,articles)->
      assert.ok err instanceof Error
      done()

  it "option #2:数値以外を返す関数を登録できない",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(freq)->
        return "hoge"
    watcher.run (err,articles)->
      assert.ok err instanceof Error
      done()

  it "tracks multiple articles with the same pubDate",(done)->
    watcher = new Watcher(feed)
    article1 =
      title: 'first title'
      pubDate: new Date('Wed, 18 Jul 2018 22:45:19 +0000')
    article2 =
      title: 'second title'
      pubDate: article1.pubDate
    article3 =
      title: 'third title'
      pubDate: new Date('Wed, 18 Jul 2018 22:45:20 +0000')
    assert(watcher.isNewArticle(article1),'expected article1 to be new')
    
    watcher.updateLastPubArticle(article1)
    assert(!watcher.isNewArticle(article1),'expected article1 not to be new')
    assert(watcher.isNewArticle(article2),'expected article2 to be new')
    
    watcher.updateLastPubArticle(article2)
    assert(!watcher.isNewArticle(article1),'expected article1 not to be new')
    assert(!watcher.isNewArticle(article2),'expected article2 not to be new')

    assert(watcher.isNewArticle(article3),'expected article3 to be new')
    watcher.updateLastPubArticle(article3)
    assert(!watcher.isNewArticle(article1),'expected article1 not to be new')
    assert(!watcher.isNewArticle(article2),'expected article2 not to be new')
    assert(!watcher.isNewArticle(article3),'expected article3 not to be new')
    done()

  it "stop",(done)->
    watcher = new Watcher(feed)
    watcher.run ->
      watcher.on "stop",->
        done()
      watcher.stop()

  it "stop raise error",->
    watcher = new Watcher(feed)
    assert.throws ->
      watcher.stop()
    ,Error

