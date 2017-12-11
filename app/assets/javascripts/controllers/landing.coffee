# Require the core.js file, which will include some important scripts for us to use.
#= require core

# Require the google authentication helper; used later as a simple wrapper for
# connecting to the OAuth2 via 'gapi'.
#= require 'google_auth2'

# Define some listener methods which will help keep track of sign in changes.
signInChange = (isSignedIn) ->
    console.log "Signin state has changed. Is user signed in: #{isSignedIn}"

    #TODO: Process the users login, by replacing the login button with a
    # 'Open Dashboard' button instead (also, provide an option to logout
    # somewhere in the UI, calling `auth.auth.signOut()`)

userChange = (user) ->
    console.log "Sign in user has changed. New user: #{user}"

# Create a new GAuth2 helper instance, passing the listener
# methods, along with 'true' (which tells the instance to
# initalise the gapi.auth2 authinstance ASAP).
auth = new GAuth2( signInChange, userChange, true )


@googleSignOut = ->
    auth.auth.signOut()