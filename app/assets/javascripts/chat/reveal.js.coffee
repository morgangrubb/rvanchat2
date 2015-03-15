captureRevealClicks = ->
  $('#reveal a').click (event) ->
    event.preventDefault()
    $('#reveal').load('#{reveal_path}')

$(captureRevealClicks)
