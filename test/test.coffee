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

  it "最初にまとめて読める",(done)->
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

