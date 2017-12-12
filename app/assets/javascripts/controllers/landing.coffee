#= require core
#= require helpers/scroller
#= require helpers/landing_splash

###
    Controller specific coffeescript source (for LandingController).

    This file configures the splash screen animations as well as
    Google OAuth2 authentication integration (via GAuth2 class,
    available on window).

    Copyright (c) Harry Felton 2017
###

@splash = new SplashHelper

# Create a method that signs the user out of the gapi auth2
# instance.
@googleSignOut = ->
    @splash.authHelper.auth.signOut()