##
# DEPRECATION NOTICE
# 9a19b2 (redesign) - dash.v1 - 18.04.2018
# ------------------
#
# This coffee script file has been deprecated because the
# users dashboard is being redesigned, using AngularJS instead of manual Ajax techniques.
#
# Usage of this file should be avoided. Once a removal date has been scheduled,
# this code will be commented out; Any site functionality relying on this CoffeeScript
# will fail at this time.
#
# Files `require`ing this file, should actively make efforts to remove this `require` BEFORE
# the file is removed
#
# THIS CHUNK HAS NO SCHEDULED REMOVAL DATE - See issue #1 for updates
#
# Copyright (c) Harry Felton 2018
#

console.warn("[DEPRECATION NOTICE] scroller.coffee has been deprecated. Please see issue #1 at GitLab.com/hbomb79/bikboo/issues/1 for more information.")

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
