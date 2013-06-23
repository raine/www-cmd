serializeControls = ->
  _.object $("input").toArray().map (e) ->
    $this = $(e)
    name  = $this.attr 'name'

    if $this.is "[type='checkbox']"
      val = $this.prop "checked"
    else if $this.is "[type='text']"
      val = $this.val()

    [ name, val ]

$ ->
  $stdout = $(".stdout")
  showOutput = (stdout) ->
    $stdout.show()
    $stdout.find("pre").text stdout

  $("button").click ->
    cmdId = $(this).attr("data-command-id")
    $.post "/execute/" + cmdId, serializeControls(), (output) ->
      showOutput output
      console.log output


