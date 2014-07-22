rss-watcher [![Build Status](https://travis-ci.org/nikezono/node-rss-watcher.png)](https://travis-ci.org/nikezono/node-rss-watcher)[![Coverage Status](https://coveralls.io/repos/nikezono/node-rss-watcher/badge.png)](https://coveralls.io/r/nikezono/node-rss-watcher)
---

[![NPM](https://nodei.co/npm/rss-watcher.png)](https://nodei.co/npm/rss-watcher/)

## What is it
`RSS-Watcher` is Small Library for RSS/Atom Feed Reader

##install

####NPM INSTALL:

    npm install rss-watcher

####package.json:

```
{
  "dependencies":{
    "rss-watcher": "*"
  }
}
```

## Usage

    Watcher = require 'rss-watcher'
    feed = 'http://github.com/nikezono.atom'

    watcher = new Watcher(feed)

    watcher.on 'new article',(article)->
      console.log article

    watcher.run (err,articles)->
      console.error err if err
      console.log articles # current articles


### option

    watcher = new Watcher(feed)
    watcher.set
      feed:feed # feed url
      interval: 60  # request per interval seconds. default:avarage update frequency

### functional option

    watcher.set
      interval: (avarage)->
        return 60 * 3 if avarage < 60 * 3 # ex:Throttle HTTP Access


### exposed events

    watcher.on "error",(error)->
      console.error error

    watcher.on "new article",(article)->
      console.log article # article object

    watcher.on "stop", ->
      console.log 'stop'

    watcher.stop()

## CLI tool

    > rss-watcher 'http://github.com/nikezono.atom' -i 20000 # 20000s interval

### Image

![gyazo](http://gyazo.com/35357bf10711857403eaa7abe6b70037.png)


## Test

Spec Report:

    npm -i -g grunt grunt-cli
    grunt test

Coverage dump:

    grunt coverage
    open coverage.html

