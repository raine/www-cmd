express = require "express"
http    = require "http"
path    = require "path"
_       = require "underscore"
exec    = require("child_process").exec
cliff   = require "cliff"
fs      = require "fs"
coffee  = require "coffee-script"

try
  config  = require "./config"
catch e
  console.log "Can't find the config file config.coffee"
  process.exit()

fs.readFile "./src/www-cmd.coffee", "utf8", (err, data) ->
  compiled = coffee.compile data
  fs.writeFile "./public/www-cmd.js", compiled, (err) ->
    console.log "compiled."

app = express()
app.configure ->
  app.set "port", process.env.PORT or 8080
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.locals._ = _

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

controls = config.controls
commands = _.where controls, { type: "button" }
commands.forEach (obj, i) -> obj._id = i

console.log "Initialized with commands:"
console.log cliff.stringifyObjectRows commands.map((obj) ->
  obj = _.clone(obj)
  obj.command = "[Function]"  if _.isFunction(obj.command)
  obj
), ["text", "command", "_id"], ["red", "blue", "green"]

parseOpts = (opts) ->
  for key, value of opts
    control =  _.findWhere _.flatten(controls), opt: key

    switch control.type
      when 'checkbox'
        opts[key] =
          switch value
            when 'true'  then true
            when 'false' then false
            else value
      when 'select'
        opts[key] = control.options[+value]

  opts

app.post "/execute/:id", (req, res) ->
  cmdId = +req.params.id
  cmd   = _.findWhere commands, _id: cmdId
  opts  = parseOpts req.body

  unless cmd
    console.log "Command not found"
    return res.send 404

  command = if _.isFunction(cmd.command)
    cmd.command req, opts
  else
    cmd.command

  console.log "Running command `" + command + "`"
  resp = "$ " + command + "\n"

  exec command, (err, stdout, stderr) ->
    if err
      console.log err.stack
      console.log "Error code: #{err.code}"
      console.log "Signal received: #{err.signal}"

    console.log "Child Process STDOUT: #{stdout}"
    console.log "Child Process STDERR: #{stderr}"

    if err
      resp += err.toString()
      console.log err.toString()
    else
      resp += stdout
      console.log stdout

    res.send resp

app.get "/", (req, res) ->
  res.render "index",
    controls: controls
