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

watcher = null

describe "rss-watcher",->

  it "can compile",(done)->
    watcher = require path.resolve 'lib','watcher'
    assert.notEqual watcher,null
    done()

  it "can set rss feed",(done)->
    assert.ok watcher.set(feed)
    done()

  it "can raise error if feed url is invalid",(done)->
    watcher.set 'hoge'
    watcher.run()
    watcher.on 'error',->
      done()

  it "最初にまとめて読める",(done)->
    watcher.set feed
    watcher.run()
    watcher.on "pub",->
      done()
