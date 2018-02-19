# Define top-level method that scrolls to an object
# specified by a jQuery string
@scrollToTarget = (target, time) ->
    return console.error "Unable to scroll to target #{target}. Target
        doesn't exist in DOM -- refactor query and retry
        (must be a jQuery string)" unless $( target ).length

    $ "html, body"
        .animate
            scrollTop: $( target ).offset().top or 0
            time or 750


# Assign some jQuery event handlers to facilitate
# scrolling on click handlers.
$( document ).on "click", "a[data-scroll]", ( event ) ->
    do event.preventDefault if event

    scrollToTarget $( this ).attr("data-scroll"), Number $( this ).attr( "data-scroll-time" )
