class @ProjectsPane
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

        if projectCount and not $panel.hasClass "open"
            $panel
                .stop true
                .addClass "open"
                .show().css
                    opacity: 0,
                    marginTop: "50px"
                .animate
                    marginTop: 0,
                    opacity: 1
                , 250
        else if not projectCount and $panel.hasClass "open"
            $panel
                .stop true
                .animate
                    marginTop: '50px',
                    opacity: 0
                , 150
                .promise().done ->
                    $panel.hide().removeClass "open"

                    $wrapper.find ".notice#no-projects"
                        .fadeIn 250

        setTimeout ->
            $panel.find ".hiding"
                .addClass "hidden"
                .removeClass "hiding"
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
        # TODO
        $placeholder = $ ".column#projects .wrapper .panel#projects .project.placeholder"

        $placeholder.find "input, textarea"
            .attr "disabled", true

        $placeholder.find ".button.placeholder-save"
            .addClass "loading inplace"

        $placeholder.find ".button.placeholder-close"
            .addClass "disabled"


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
        # TODO

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
