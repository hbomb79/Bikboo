#= require core
#= require helpers/google_auth2
#= require helpers/scroller

###
    Controller specific coffeescript source (for LandingController).

    This file configures the splash screen animations as well as
    Google OAuth2 authentication integration (via GAuth2 class,
    available on window).

    Copyright (c) Harry Felton 2017
###

_replacePrompt = (animate) ->
    #TODO: Fade out Google sign in prompt and replace with dashboard link when logged in

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

# Create a method that signs the user out of the gapi auth2
# instance.
@googleSignOut = ->
    auth.auth.signOut()