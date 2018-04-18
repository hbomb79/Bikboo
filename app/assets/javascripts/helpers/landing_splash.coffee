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

class @SplashHelper
    constructor: ->
        console.warn("[DEPRECATION NOTICE] landing_splash.coffee is deprecated. Please see issue #1 at GitLab.com/hbomb79/bikboo/issues/1 for more information.")
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
