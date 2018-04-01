class @ProjectsPane
    errorState: false
    isLoading: false
    constructor: ->
        # Assign event handlers to handle opening, closing, pushing and discarding
        # of projects.

        $( "a.new-project" ).on "click", (event) =>
            do @spawnPlaceholder

            window.location.hash = "!create"
            event.preventDefault()

        placeholder = ".column#projects .wrapper .panel#projects .project.placeholder"
        $ "body"
            .on "click", "#{placeholder} .placeholder-close:not(.disabled)", (event) =>
                do @removePlaceholder
            .on "click", "#{placeholder} #new-help", (event) =>
                do @revealPlaceholderHelp
            .on "click", "#{placeholder} #close-help", (event) =>
                do @hidePlaceholderHelp
            .on "click", "#{placeholder} .placeholder-save:not(.loading)", (event) =>
                do @pushPlaceholder

    ##
    # On refresh, checks to see if any projects are loaded. If so,
    # makes them visible and fades out the active notice.
    #
    # Otherwise, the notice will appear. If a niche situation occurs,
    # a notice specifically for that situation may appear instead of a
    # 'Nothing here' notice.
    refresh: ->
        $wrapper = $ ".column#projects .wrapper"
        $panel = $wrapper.find ".panel#projects"
        projectCount = $panel.find(".project:not(.hidden):not(.hiding)").length

        $wrapper.find ".notice"
            .fadeOut 250

        if @isLoading
            @hidePanel ->
                $wrapper.find ".notice.loading"
                    .fadeIn 250
        else if projectCount and not $panel.hasClass "open"
            do @showPanel
        else if not projectCount and $panel.hasClass "open"
            @hidePanel ->
                $wrapper.find ".notice#no-projects"
                    .fadeIn 250

        setTimeout ->
            $panel.find ".hiding"
                .addClass "hidden"
                .removeClass "hiding"
        , 250

    hidePanel: (done) ->
        $panel = $ ".column#projects .wrapper .panel#projects"
        $panel
            .stop true
            .animate
                marginTop: '50px',
                opacity: 0
            , 150
            .promise().done ->
                $panel.hide().removeClass "open"

                do done if done

    showPanel: ->
        $ ".column#projects .wrapper .panel#projects"
            .stop true
            .addClass "open"
            .show().css
                opacity: 0,
                marginTop: "50px"
            .animate
                marginTop: 0,
                opacity: 1
            , 250

    ##
    # Spawns an empty project which can be edited live inside the project panel.
    #
    # When the user is happy with their project, they can hit 'Save' and push the
    # project to the server.
    spawnPlaceholder: ->
        $panel = $ ".column#projects .wrapper .panel#projects"
        return console.debug "Ignoring request to spawn placeholder; placeholder already visible inside panel!" if $panel.find(".project.placeholder:visible").length

        if $panel.find(".project:not(.placeholder):not(.hidden)").length
            #TODO: handle spawning when other projects are present to avoid the placeholder simply appearing
            # when the .hidden class is removed.
        else
            $panel.find ".placeholder"
                .removeClass "hidden"

        setTimeout ->
            $panel.find ".placeholder form input:visible:first"
                .focus()
        , 250

        do @refresh

    ##
    # Once the project is saved, it's ID will be returned. This script will then
    # reload the projects available to the user. If any *other* new projects are
    # found, they could be ordered above the one just created.
    #
    # The newly created project will be highlighted briefly to indicate a success
    # to the user.
    pushPlaceholder: ->
        $placeholder = $ ".column#projects .wrapper .panel#projects .project.placeholder"
        data = $placeholder.find("form").serialize()

        $placeholder.find "input, textarea"
            .attr "disabled", true
        $placeholder.find ".button.placeholder-save"
            .addClass "loading inplace"
        $placeholder.find ".button.placeholder-close"
            .addClass "disabled"

        $.ajax
            url: '/projects'
            dataType: 'json'
            method: 'POST'
            data: data
            complete: (event) =>
                console.log "complete"
                $placeholder.find "input, textarea"
                    .attr "disabled", false
                $placeholder.find ".button.placeholder-save"
                    .removeClass "loading inplace"
                $placeholder.find ".button.placeholder-close"
                    .removeClass "disabled"

            success: (payload, state, xhr) =>
                console.log "SUCCESS"
                console.log payload
                console.log state

                notices.queue "Created project!"
                do @removePlaceholder
            error: (xhr, state, display) =>
                console.error "Ajax error while pushing new project. #{state}, #{display}. XHR dump follows"
                console.debug xhr

                response = xhr.responseJSON
                notices.queue( "Unable to create new project: #{response and response.error or display} (#{xhr.status})", true )


    ##
    # Remove placeholder
    #
    # Removes the placeholder project from the list.
    removePlaceholder: ->
        window.location.hash = ""

        $panel = $ ".column#projects .wrapper .panel#projects"

        if $panel.find(".project:not(.placeholder):not(.hidden)").length
            #TODO: Handle removal of placeholder when other projects are present
            # Simply adding the 'hidden' class will cause it to instantly disappear.
        else
            $panel.find ".project.placeholder"
                .addClass "hiding"

        do @refresh

    ##
    # Fetches the list of projects which is then used to update the DOM
    #
    # The DOM element is to REPLACE the '.wrapper .panel#projects' div.
    #
    # If, before fetching, a placeholder project exists inside the panel
    # the placeholder project will be preserved and reinserted in to the new
    # panel in time for DOM rendering.
    # 
    # Callbacks
    # ---------
    #
    # A number of callbacks can be provided to this function allowing for
    # better control of Ajax functionality.
    # 
    # - completeCallback: A callback executed when the Ajax request completes (see jQuery documentation for information on 'complete' Ajax callbacks)
    # - successCallback: A callback executed when the Ajax request succeeds (see jQuery documentation for information on 'success' Ajax callbacks)
    # - errorCallback: A callback executed when the Ajax request errors (see jQuery documentation for information on 'error' Ajax callbacks)
    # - insertionCallback: A callback executed just before the DOM is updated with the new projects panel. Use this callback to adjust the information inside
    fetchProjects: (completeCallback, successCallback, errorCallback, insertionCallback) ->
        # Create a fetch request for project list
        $.ajax
            url: '/projects'
            dataType: 'json'
            method: 'GET'
            complete: (event) =>
                # Fetch complete!
                #TODO: Figure out if I need this or not

            success: (payload, state, xhr) =>
                # Successful fetch of the project information.
                $panel = $ "<div class='panel' id='projects'></div>"

                # Synthesize a panel containing the projects

                # Replace the current panel with the new one

                # Force an update of the panel
                
            error: (xhr, state, display) =>
                

    ##
    # If a placeholder exists, the help screen will appear over the form
    revealPlaceholderHelp: ->
        $placeholder = $ ".column#projects .wrapper .panel#projects .project.placeholder"
        if $placeholder.length
            $placeholder.find ".help-content"
                .stop true
                .show()
                .css
                    opacity: 0,
                    marginTop: "50px"
                .addClass "shown"
                .animate
                    opacity: 1,
                    marginTop: 0
                , 150

    ##
    # If a placeholder exists, the help screen will disappear (if shown) from
    # above the form
    hidePlaceholderHelp: ->
        $placeholder = $ ".column#projects .wrapper .panel#projects .project.placeholder"
        if $placeholder.length
            $help_content = $placeholder.find ".help-content"
            if $help_content.hasClass "shown"
                $help_content
                    .stop true
                    .animate
                        opacity: 0
                        marginTop: "55px"
                    , 150
                    .promise().done ->
                        $help_content
                            .hide()
                            .removeClass "shown"
