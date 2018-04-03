##
# An awesome little bit of CoffeeScript that does a few things, more or less in this order:
#
# - On page load, the URL used to access this page is used to determine which type of content is being viewed
# - Depending on the type of content, an AJAX request is submitted to the server for the information
# - The returned JSON helps to structure the page, including but not limited to the title and section layout
# - When a link is clicked, the action is caught here and causes the next page to be loaded via AJAX
# - Once the next page information is loaded, the old content is animated out, replaced, and animated back in
#

class @AjaxLoader
    refreshingInterval: false
    targetURL: false

    constructor: ->
        do @refreshTargetURL
        do @loadContent

    refreshTargetURL: ->
        path = window.location.pathname
        if path.match /dashboard\/project\/(\d+)/i
            # Project overview
        else if path.match /dashboard\/?$/i
            # Dashboard
            @targetURL = "/api/projects"
        else
            console.error "[FATAL] Unable to load page, unable to map URL to valid RESTful endpoint! Check URL and try again."
            window.location = "/dashboard"

    updateDOMFromPayload: (payload, meta='') ->
        $("[data-ajax-meta='#{meta}']").each ->
            scopedPayload = if $(this).attr "data-ajax-scope" then payload[ $(this).attr "data-ajax-scope" ] else payload

            match = ( $(this).attr( "data-ajax-attr-pair" ) or "" ).match /([^,\s]+)/g
            if match
                match.forEach (pair) =>
                    sides = pair.match /[^:]+/g
                    if sides.length is 1
                        $(this).html( scopedPayload[ sides[ 0 ] ] )
                    else if sides.length is 2
                        $(this).attr( sides[0], scopedPayload[ sides[ 1 ] ] )
                    else
                        console.warn("Malformed data-ajax-attr-pair, pair #{pair} is invalid on element #{this}")

    refreshData: ->
        $.ajax
            url: "#{@targetURL}/metadata"
            method: 'get'
            dataType: 'text'
            error: (xhr, state, display) =>
                console.error "[FATAL] AJAX request to load project metadata failed! #{state}, #{display}. XHR dump follows"
                console.debug xhr

                clearInterval @refreshingInterval
            success: (scriptText, xhr) =>
                eval( scriptText )( this )

    loadContent: ->
        clearInterval @refreshingInterval
        return console.warn "Unable to load content, no target URL available on ajaxLoader" unless @targetURL

        $.ajax
            url: @targetURL
            method: 'get'
            dataType: 'json'
            error: (xhr, state, display) =>
                console.error "[FATAL] AJAX request to load project fragments failed! #{state}, #{display}. XHR dump follows"
                console.debug xhr
            success: (payload) =>
                updateScript = eval( payload.update_script )

                $("main section.page-viewer, .ajax-insert").stop( true ).fadeOut( 250 )
                setTimeout =>
                    @updateDOMFromPayload( payload )
                    updateScript( payload.content )

                    $("main section.page-viewer").attr( "id", payload.section_id ).stop( true ).fadeIn( 150 )
                    $(".ajax-insert").stop( true ).fadeIn( 150 )

                    do @startDataRefresh
                , 150

    reloadContent: ->
        clearInterval @refreshingInterval
        $ "section#projects .content .projects"
            .fadeOut( 250 ).promise().done =>
                $ "section#projects .content .loading"
                    .fadeIn( 150 ).promise().done =>
                        do @loadContent
                        notices.queue "A change in your projects was detected, we've reloaded your dashboard automatically to reflect the new changes"

    startDataRefresh: ->
        clearInterval @refreshingInterval
        @refreshingInterval = setInterval =>
            do @refreshData
        , 6000
