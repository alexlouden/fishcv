module.exports = (grunt) ->
  grunt.initConfig
  
    pkg: grunt.file.readJSON("package.json")
    
    # Check Coffee
    coffeelint:
      app: ['src/**/*.coffee']
      options:
        'no_trailing_whitespace':
          level: 'warn'
        'max_line_length':
          value: 100
          level: 'warn'
          
    # Coffee -> JS
    coffee:
      build:
        files:
          'dist/js/fishcv.js': 'src/**/*.coffee'
      
        options:
          sourceMap: false
          join: true
          bare: true
          
    # Copy JS
    copy:
      js:
        files:
          [{expand: true, cwd: 'src/js/', src: ['*.js'], dest: 'dist/js/', filter: 'isFile'},
           {expand: true, cwd: 'src/images/', src: ['*'], dest: 'dist/images/', filter: 'isFile'}]
          
    # SASS -> CSS
    compass:
      options:
        sassDir: "src/css"
        cssDir: "dist/css"
        raw: 'preferred_syntax = :sass\n'
      debugsass: true
    
    # Minify HTML
    htmlmin:
      dist:
        options:
          removeComments: true,
          collapseWhitespace: true,
          removeEmptyAttributes: true,
          removeCommentsFromCDATA: true,
          removeRedundantAttributes: true,
          collapseBooleanAttributes: true 
        files:
          'dist/index.html': 'src/index.html'

    # Clean directories
    clean:
      build: ["dist"]
    
    # Server
    connect:
      server:
        options:
          port: 3000,
          base: 'dist/'

    # Watch
    watch:
      livereload:
        files: ["dist/**/*", "dist/*"]
        options:
          livereload: true
      js:
        files: ["Gruntfile.coffee", "src/**/*.coffee", "src/**/*.js"]
        tasks: ["coffeelint","coffee", "copy"]
      style:
        files: ["src/**/*.sass", "src/**/*.css"]
        tasks: ["compass"]
      html:
        files: ["src/**/*.html"]
        tasks: ["htmlmin"]
        
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-htmlmin"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-watch"
  
  grunt.registerTask "build", ["coffeelint", "coffee", "copy", "compass", "htmlmin"]
  
  grunt.registerTask "dev", ["clean:build", "build", "connect", "watch"]
  grunt.registerTask "default", ["dev"]
  
  