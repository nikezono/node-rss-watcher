###
#
# test.coffee
# Author:@nikezono, 2014/06/27
#
###


# dependency
path = require 'path'
assert = require 'assert'

# Feed to test
# FIXME use something does not emit http request,
#       such as mock or stub
feed = "https://github.com/nikezono/node-rss-watcher/commits/master.atom"

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

  it "can return error if feed url is invalid",(done)->
    watcher = new Watcher("hoge")
    watcher.run (err,articles)->
      assert.ok(err instanceof Error)
      done()

  it "does not emit any event at first launch",(done)->
    watcher = new Watcher(feed)
    watcher.run (err,articles)->
      console.log err
      assert.ok(0 < articles.length)
      done()

  it "can pass option 'interval' for fetch interval",(done)->
    watcher = new Watcher(feed)
    begin = Date.now()
    assert.ok watcher.set
      feedUrl:feed
      interval:1000
    watcher.run (err,articles)->
      assert.ok(1000 < Date.now - begin)
      done()

  it "can pass option 'interval' as function object",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(frequency)->
        if frequency > 1000
          return frequency-1000
        else
          frequency
    watcher.run (err,articles)->
      done()

  it "can't pass negative value as option 'interval'",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(freq)->
        return -1000
    watcher.run (err,articles)->
      assert.ok err instanceof Error
      done()

  it "can't pass function that returns not a number",(done)->
    watcher = new Watcher(feed)
    watcher.set
      interval:(freq)->
        return "hoge"
    watcher.run (err,articles)->
      assert.ok err instanceof Error
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

