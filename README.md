rss-watcher [![Build Status](https://travis-ci.org/nikezono/node-rss-watcher.png)](https://travis-ci.org/nikezono/node-rss-watcher)
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

    watcher = require 'rss-watcher'
    feed = 'http://github.com/nikezono.atom'

    watcher.set feed

    watcher.run 20000 # request interval. default is [frequency](http://github.com/nikezono/node-rss-frequency)
    watcher.on "pub",(article)->
      console.log article

## CLI tool

    > rss-watcher 'http://github.com/nikezono.atom' -i 20000 # 20000s interval

