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
            .on "click", "#{placeholder} .placeholder-close", (event) =>
                do @removePlaceholder
            .on "click", "#{placeholder} #new-help", (event) =>
                do @revealPlaceholderHelp
            .on "click", "#{placeholder} #close-help", (event) =>
                do @hidePlaceholderHelp
            .on "click", "#{placeholder} .placeholder-save", (event) =>
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
        projectCount = $panel.find(".project:not(.closing)").length

        $wrapper.find ".notice, .loading"
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
                , 250
                .promise().done ->
                    $panel.hide().removeClass "open"

                    $wrapper.find ".notice#no-projects"
                        .fadeIn 250

        setTimeout ->
            $panel.find ".closing"
                .remove()
        , 250

    ##
    # Spawns an empty project which can be edited live inside the project panel.
    #
    # When the user is happy with their project, they can hit 'Save' and push the
    # project to the server.
    spawnPlaceholder: ->
        $panel = $ ".column#projects .wrapper .panel#projects"
        return console.debug "Ignoring request to spawn placeholder; placeholder already found inside panel!" if $panel.find(".project.placeholder").length

        $placeholder = $ """
            <div class="project placeholder">
                <div class="help-content">
                    <a href="#" id="close-help" class="top-right-nav">&#10006;</a>

                    <h2 class="title">You needed help?</h2>
                    <span>Don't worry, we're here to help!</span>

                    <h3 class="sub">Cannot submit</h3>
                    <p>We work hard to fight against technical problems, but sometimes a couple squeeze by. If you're experiencing issues, please try <a href="#">clearing your cache</a>. Still doesn't work? Try again in a little while before <a href="#">contacting us</a>.</p>

                    <h3 class="sub">Re-Captcha Code</h3>
                    <p>For most users, captcha codes won't appear when creating a project; however if our system detects unusual activity we may prompt you to confirm you're not human.</p>

                    <h3 class="sub">Other problems</h3>
                    <p>Experiencing other issues with our form? No worries. Use the <a href="projects/new">older version</a> instead</p>
                </div>
                <div class="content">
                    <form>
                        <a href="#" id="new-help" class="top-right-nav">Help</a>
                    
                        <h2 class="title">New project</h2>
                        <span class="about">A project is where you'll plan your videos, upload your assets, and render your videos. Creating a project is free and easy, so why wait?</span>
                    
                        <h3 class="sub">Name</h3>
                        <input type="text" placeholder="Lorem ipsum">
                    
                        <h3 class="sub">Description</h3>
                        <textarea name="desc" cols="20" rows="5" placeholder="An optional description of your project"></textarea>
                    
                        <div class="footer">
                            <span>I agree to this websites <a href="/terms">terms of service</a></span>
                            <input type="checkbox">
                    
                            <div class="right">
                                <a href="#" class="button sub placeholder-close">Cancel</a>
                                <a href="#" class="button placeholder-save">Create project</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        """

        $placeholder.prependTo $panel
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

    ##
    # Remove placeholder
    #
    # Removes the placeholder project from the list.
    removePlaceholder: ->
        window.location.hash = ""
        $ ".column#projects .wrapper .panel#projects .project.placeholder"
            .addClass "closing"

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
