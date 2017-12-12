###
    A helper class for use by JS that wishes to easily make use of Google
    sign in integration.

    Automatically attaches listeners and creates the auth2 instance.

    Copyright (c) Harry Felton 2017
###

class @GAuth2
    constructor: (signInListener, userListener, autoInit) ->
        @signInListener = ( typeof signInListener is 'function' ) and signInListener or (state) ->
            console.warn "Uncaught GAuth2 event (isSignedIn). New state: #{state}"

        @userListener = ( typeof userListener is 'function' ) and userListener or (user) ->
            console.warn "Uncaught GAuth2 event (currentUser). New user: #{user}"
            console.debug user.getBasicProfile() if user

        # Once the Google API has loaded the 'auth2' library, initialise the auth instance
        gapi.load( 'auth2', @init if autoInit )

    init: =>
        return console.warn "Already initialised" if @auth

        # Create our auth instance, passing our clientID and the relevant scopes
        @auth = gapi.auth2.init {
            client_id: '1050814368819-l2v81ut67vi65016ced1mstv5j2uepou.apps.googleusercontent.com',
            scope: 'profile'
        }

        # If for some reason this didn't work, bail out
        return console.error 'No auth instance. Platform failed to load. gapi-auth2' unless @auth

        # Assign the two listeners if the helper method received them
        @auth.isSignedIn.listen @signInListener if @signInListener
        @auth.currentUser.listen @userListener if @userListener
