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
    assert.throws ->
      watcher.run()
    ,Error
    done()

  it "最初にまとめて読める",(done)->
    watcher = new Watcher(feed)
    watcher.run ->
      watcher.once "new article",(article)->
        done()

  it "option",->
    watcher = new Watcher(feed)
    assert.ok watcher.set
      feedUrl:feed
      interval:10000

  it "stop",(done)->
    watcher = new Watcher(feed)
    watcher.run (run)->
      watcher.on "stop",->
        done()
      watcher.stop()

  it "stop raise error",->
    watcher = new Watcher(feed)
    assert.throws ->
      watcher.stop()
    ,Error
