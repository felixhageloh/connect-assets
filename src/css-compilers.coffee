# the standard css compilers
path = require 'path'
libs = {}

exports.addPlugin = (name, plugin) ->
  libs[name] = plugin

exports.styl =
  optionsMap: {}
  compileSync: (sourcePath, source) ->
    result = ''
    callback = (err, js) ->
      throw err if err
      result = js

    libs.stylus or= require 'stylus'
    libs.bootstrap or= try require 'bootstrap-stylus' catch e then (-> ->)
    libs.nib or= try require 'nib' catch e then (-> ->)
    libs.bootstrap or= try require 'bootstrap-stylus' catch e then (-> ->)
    options = @optionsMap[sourcePath] ?=
      filename: sourcePath
    libs.stylus(source, options)
        .use(libs.bootstrap())
        .use(libs.nib())
        .use(libs.bootstrap())
        .use(libs.stylusExtends)
        .set('compress', @compress)
        .set('include css', true)
        .render callback
    result

exports.less =
  optionsMap:
    optimization: 1
    silent: false
    paths: []
    color: true

  compileSync: (sourcePath, source) ->
    result = ""
    libs.less or= require 'less'
    options = @optionsMap
    options.filename = sourcePath
    options.paths = [path.dirname(sourcePath)].concat(options.paths)
    options.syncImport = true
    compress = @compress ? false

    callback = (err, tree) ->
      throw err if err
      result = tree.toCSS({compress: compress})

    new libs.less.Parser(options).parse(source, callback)
    result