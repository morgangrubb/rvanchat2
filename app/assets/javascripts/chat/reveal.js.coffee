captureRevealClicks = ->
  $('#reveal').on 'click', 'a', (event) ->
    event.preventDefault()
    href = event.target.getAttribute('href')
    $('#reveal').html(
      """
        <i class="fa fa-spinner fa-pulse"></i> Loading
      """
    )
    $('#reveal').load(href)

$(captureRevealClicks)
