express = require("express")
http    = require("http")
path    = require("path")
_       = require("underscore")
exec    = require("child_process").exec
cliff   = require("cliff")
config  = require("./config")

app = express()
app.configure ->
  app.set "port", process.env.PORT or 8080
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.logger("dev")
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  
commands = config.buttons
commands.forEach (obj, i) -> obj.id = i

console.log "Initialized with commands:"
console.log cliff.stringifyObjectRows commands.map((obj) ->
  obj = _.clone(obj)
  obj.command = "[Function]"  if _.isFunction(obj.command)
  obj
), ["text", "command", "id"], ["red", "blue", "green"]

app.post "/execute/:id", (req, res) ->
  cmdId = +req.params.id
  cmd   = _.findWhere commands, id: cmdId

  unless cmd
    console.log "Command not found"
    return res.send 404

  command = if _.isFunction(cmd.command)
    cmd.command(req)
  else
    cmd.command

  console.log "Running command `" + command + "`"
  resp = "$ " + command + "\n"

  exec command, (err, stdout) ->
    if err
      resp += err.toString()
      console.log err.toString()
    else
      resp += stdout
      console.log stdout

    res.send resp

app.get "/", (req, res) ->
  res.render "index",
    commands: commands
