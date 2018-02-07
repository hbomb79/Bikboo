#= require core
#= require helpers/nav


##
# Handles the recent activity pane.
# - Shows a 'Load More' button if there are more notifications
# - Shows a notice telling the user there are no more notifications if that's the case
#
# On page load, up to 10 recent notifications are loaded in to the pane. If the user scrolls
# to the bottom of this list, more notifications (up to 10) will load automatically. The new
# notifications have no date requirment (ie: they could be non-recent notifications).
#
# If, on load, there are no recent notifications (but there ARE non-recent notifications),
# a 'Show Older' button will be visible which, when clicked, will remove the date restrictions.
# From then on, the pane will function the same as usual.
_checkRecentActivity = (event) ->
    $(".column#notifications .wrapper .notice").fadeIn() unless $( ".column#notifications .wrapper .notification" ).length

##
# This AJAX request will probe the server for notification information.
#
# The response will include the total amount of notifications, whether or not
# they are recent, and how many were provided.
#
# Using this information, the client can 'bump' the offset count up
# so that new notifications are provided next time.
#
# There exists two endpoints for notification content. /notifications, and
# /notifications/recent.
#
# Both accept a 'limit' and 'offset' URL param. By default, both return
# unlimited notifications with an offset of zero (0).
_probeUserActivity = (event) ->
    console.debug 'NYI'


$( document ).ready ->
    delegatedTarget = ".column#notifications .wrapper .notification-dismiss"

    do _checkRecentActivity

    $ "body"
        .on "click", delegatedTarget, (event) ->
            if $( this ).hasClass "removing"
                console.warn "This notification is already being removed!"

                event.stopPropagation()
                event.preventDefault()

                return false

            $( this ).addClass "removing"

        .on "ajax:success", delegatedTarget, (event, data, status, xhr) ->
            $( event.target ).parents ".notification"
                .animate
                    marginLeft: '100%',
                    opacity: 0
                , 200
                .promise().done ->
                    $( this ).slideUp( 100 ).promise().done ->
                        $( this ).remove()
                        do _checkRecentActivity

        .on "ajax:error", delegatedTarget, (event, xhr, status, error) ->
            console.error "FAILED to destroy notification"
            alert "Unable to destroy notification. Please try again later."

            $( event.target ).removeClass "removing"

        .on "ajax:complete", delegatedTarget, (event) ->
            console.debug "NYI"
