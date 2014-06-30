process.env.NODE_PATH = '/usr/local/lib/node_modules'

cp = require 'child_process'

task 'compile','compile automate', ->
  cp.spawn "coffee"
    , [ "-o", "./lib", "-cw", "-b", "./src"]
      ,{ stdio: 'inherit' }
