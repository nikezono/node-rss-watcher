'use strict'

module.exports = (grunt) ->

  _ = require 'underscore'
  require 'coffee-errors'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-notify'

  grunt.registerTask 'test',     [ 'coffeelint','coffee', 'mochaTest:spec' ]
  grunt.registerTask 'travis',   [ 'test' ]
  grunt.registerTask 'default',  [ 'test', 'watch' ]

  grunt.initConfig

    coffeelint:
      options:
        max_line_length:
          value: 100
        indentation:
          value: 2
        newlines_after_classes:
          level: 'error'
        no_empty_param_list:
          level: 'error'
        no_unnecessary_fat_arrows:
          level: 'ignore'
      dist:
        files: [
          { expand: yes, cwd: 'test/', src: [ '*.coffee' ] }
          { expand: yes, cwd: './', src: [ '*.coffee' ] }
          { expand: yes, cwd: 'models/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'config/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'events/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'src/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'public/', src: [ '**/*.coffee' ] }
        ]

    watch:
      options:
        interrupt: yes
      dist:
        files: [
          '*.coffee'
          'models/**/*.coffee'
          'events/**/*.coffee'
          'config/**/*.coffee'
          'src/**/*.coffee'
          'public/**/*.{coffee,js,jade}'
          'test/**/*.coffee'
        ]
        tasks: [ 'coffeelint','coffee','mochaTest:spec' ]

    coffee:
      multiple:
        expand:true
        cwd:'src'
        src:'*.coffee'
        dest:'lib/'
        ext:'.js'

    mochaTest:
      spec:
        options:
          reporter:"spec"
          timeout: 50000
          colors: true
        src: ['test/**/*.coffee']
