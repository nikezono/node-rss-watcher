'use strict'

module.exports = (grunt) ->

  _ = require 'underscore'
  require 'coffee-errors'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-blanket'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-coveralls'

  grunt.registerTask 'test',     [ 'coffeelint', 'mochaTest:spec' ]
  grunt.registerTask 'coverage', [ 'clean', 'blanket', 'copy','mochaTest:coverage' ]
  grunt.registerTask 'ci',       [ 'clean', 'blanket', 'copy','mochaTest:coverdump','coveralls']
  grunt.registerTask 'travis',   [ 'test','ci']
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
        tasks: [ 'test','coffee','copy:bin' ]

    coffee:
      multiple:
        expand:true
        cwd:'src'
        src:'*.coffee'
        dest:'lib/'
        ext:'.js'

    clean:
      coverage:
        src: ['coverage/']

    copy:
      coverage:
        src: ['test/**']
        dest: 'coverage/'

    blanket:
      coverage:
        files:'coverage/lib':['lib/']

    mochaTest:
      spec:
        options:
          reporter:"spec"
          timeout: 10000
          colors: true
        src: ['test/**/*.coffee']

      coverage:
        options:
          reporter:"html-cov"
          timeout: 10000
          captureFile: 'coverage/coverage.html'
          quiet:true
        src: ['coverage/test/**/*.coffee']

      coverdump:
        options:
          reporter: 'mocha-lcov-reporter'
          timeout: 10000
          quiet: true
          captureFile: 'coverage/lcov.info'
        src: ['coverage/test/**/*.coffee']

    coveralls:
      all:
        src:'coverage/lcov.info'




