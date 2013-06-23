module.exports =
  controls: [
    type    : "button"
    text    : "Date"
    command : "date"
  ,
    type    : "button"
    text    : "Who am I?"
    command : "whoami"
  ,
    type    : "button"
    text    : "Ping my IP"
    command : (req) ->
      "ping -c1 #{req.ip}"
  ,
    type    : "button"
    text    : "fubar"
    command : "bad_command"
  ,
    type    : "button"
    text    : "host"
    command : (req, opts) ->
      cmd = "host "
      cmd += "-v " if opts.verbose
      cmd += "google.com"
  ,
    type  : "checkbox"
    label : "Verbose"
    opt   : "verbose"
  ]
