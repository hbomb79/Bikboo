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

console.warn("[DEPRECATION NOTICE] nav.coffee is deprecated. Please see issue #1 at GitLab.com/hbomb79/bikboo/issues/1 for more information.")

_missHandler = (event) ->
    $modal = $ 'nav #profile-modal'
    return unless $modal.attr( "data-open" ) is 'true'

    $button = $ "nav a#profile"
    if not ( $modal.is( event.target ) or $modal.has( event.target ).length or $button.is( event.target ) or $button.has( event.target ).length )
        closeProfileModal()

@openProfileModal = ->
    $ 'nav #profile-modal'
        .stop true
        .show()
        .attr 'data-open', 'true'
        .animate
            top: '55px'
            opacity: 1
        , 100

    $( document ).mouseup _missHandler

@closeProfileModal = ->
    $ 'nav #profile-modal'
        .stop true
        .attr "data-open", 'false'
        .animate
            top: '45px'
            opacity: 0
        , 100
        .promise().then ->
            this.hide()

    $( document ).unbind 'mouseup', _missHandler

@toggleProfileModal = ->
    $modal = $ 'nav #profile-modal'

    if ( $modal.attr "data-open" ) is 'true'
        closeProfileModal()
    else
        openProfileModal()


$( document ).on "click", "nav a#profile", (event) ->
    event.preventDefault()
    toggleProfileModal()
