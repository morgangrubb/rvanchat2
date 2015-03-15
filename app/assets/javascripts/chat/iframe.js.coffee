resizeIframe = ->
  totalAvailable = $(window).height()

  # Find all the children of the parent element
  allChildren = $('#candyContainer').parent().children()

  #  Get the heights of every one that isn't the one we're interested in
  otherHeights = 0;
  allChildren.each (i) ->
    $element = $(this)
    if !$element.is('#candyContainer') && $element.is(":visible")
      otherHeights += $element.outerHeight(true)

  # Set our new height
  $('#candyContainer iframe').height(totalAvailable - otherHeights - 20)

$ ->
  if $('#candyContainer').length > 0
    $(window).resize(resizeIframe)
    resizeIframe()
