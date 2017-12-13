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

# Add click handler to body (listening for clicks on
# a-tags that have 'data-scroll' set.)
$( document ).on "turbolinks:load", ->
    $( "body" ).on "click", "a[data-scroll]", ( event ) ->
        # When clicked, the value of 'data-scroll' is used as
        # a jQuery query string and passed to window.scrollToTarget
        do event.preventDefault if event

        scrollToTarget $( this ).attr("data-scroll"), Number $( this ).attr( "data-scroll-time" )

$( window ).load ->
    setTimeout ->
        unless $( window.location.hash ).length
            $ 'html, body'
                .scrollTop( 0 )
        else
            scrollToTarget( window.location.hash )
    , 10
