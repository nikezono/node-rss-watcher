####
#
#  CLI.coffee
#
####


### Module DEPENDENCIES ###
program = require "commander"
colors  = require 'colors'
moment  = require 'moment'

# Color Schema
colors.setTheme
  time: 'grey'
  verbose: 'cyan'
  prompt: 'grey'
  info: 'blue'

color = ["white",'yellow', 'cyan', 'magenta', 'red', 'green', 'blue' ]
cnumber = 0

# define Option
program.version("1.2.0")
  .option("-f, --feed [String]", "RSS/Atom feed URL (required)")
  .option("-i, --interval [Number]", "fetch interval (optional)",parseInt)
  .option("-u, --nourl [Bool]", "Don't show articles url (optional)")
  .option("-s, --site [Bool]", "show sitename (optional)")
  .parse process.argv

path = require 'path'
Watcher = require './watcher'
watcher = new Watcher program.feed

watcher.on 'error',(error)->
  console.error error

watcher.on 'new article',(article)->
  rendering(article)

if program.interval
  watcher.set
    interval:program.interval

watcher.run (err,articles)->
  throw new Error(err) if err

  for article in articles
    rendering(article)

rendering = (article)->
  seed = article.pubDate/1000
  cnumber = seed%color.length
  date  = "[#{moment(article.pubDate).format("(ddd) HH:mm")}]"
  title = article.title
  site  = article.meta.title
  url   = article.meta.link

  text = ""

  text = "#{date.time} #{title[color[cnumber]]}"
  text = text + " - #{site}" if program.site?
  text = text + " #{url.underline}" unless program.nourl?
  console.log text



