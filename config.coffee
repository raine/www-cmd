module.exports =
  buttons: [
    text    : "Date"
    command : "date"
  ,
    text    : "Who am I?"
    command : "whoami"
  ,
    text    : "Ping my IP"
    command : (req) ->
      "ping -c1 #{req.ip}"
  ,
    text    : "fubar"
    command : "bad_command"
  ]
