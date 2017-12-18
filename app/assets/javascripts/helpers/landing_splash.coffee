###
    A coffeescript 'partial', abstracting away the splash screen
    animations.

    Copyright (c) Harry Felton 2017
###

class @SplashHelper
    constructor: ->
        $( document ).ready =>
            $ '#learn-more'
                .on 'click', (event) =>
                    # Stop the link from travelling to the provided 'href'
                    event.preventDefault()
                    # Stop other click handlers (namely the scroller bind on
                    # 'a[data-scroll]' (delegated to body) from catching this event)
                    event.stopPropagation()

                    do @revealMore

    revealMore: ->
        alert "This feature is not yet implemented (NYI). It will be implemented once full-development is given the green light."

    concealMore: ->