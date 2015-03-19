$ ->
  reveal = (event) ->
    event.preventDefault() if event.preventDefault?

    source = $('#reveal a')
    return unless source.length == 1

    href = source[0].getAttribute('href')

    $('#reveal').html(
      """
        <i class="fa fa-spinner fa-pulse"></i> Loading
      """
    )
    $('#connect code').html(
      """
        <i class="fa fa-spinner fa-pulse"></i> Loading
      """
    )

    $('#reveal').load href, ->
      $('.reveal-user-name').html($('.src-user-name').html())
      $('.reveal-user-password').html($('.src-user-password').html())
      $('.reveal-user-jid').html($('.src-user-jid').html())
      $('.reveal-room-name').html($('.src-room-name').html())
      $('.reveal-room-host').html($('.src-room-host').html())
      $('.reveal-room-jid').html($('.src-room-jid').html())

  $('#connect').on 'click', 'code', reveal
  $('#reveal').on 'click', 'a', reveal
