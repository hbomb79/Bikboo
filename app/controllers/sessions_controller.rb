class SessionsController < ApplicationController
    ##
    # Rendering a new session 'form' is much the same as simply
    # logging the user in via OAuth.
    #
    # Paths that might render such an action are instead redirected
    # to /auth/google -- where the OAuth flow begins
    #
    # Once the flow completes (and is successful), the 'create' action
    # will be executed.
    def new; end

    ##
    # The OAuth flow was successful, we are now authenticated
    # with a provider (Google).
    #
    # Check the Authorizations for a provider with the same
    # uid. If one is found, log in to the user associatted.
    #
    # If none is found, create a new Authorization model
    # linking to a new user (created from the provider payload).
    #
    # If the email is already in use, reject the authentication
    # request and bail out.
    #
    # *redirects user to the 'continue' parameter (unless it is an
    # absolute URL, in which case the user is redirected to root '/')
    def create
        # First, check if an Authorization exists for this uid and provider.
        omniauth = request.env['omniauth.auth']
        info = omniauth['info']

        continue_url = request.env['omniauth.params']['continue']
        redirect_path = (url_absolute? continue_url) ? '/' : ( continue_url or "/" )

        @auth = Authorization.where( provider: omniauth['provider'], uid: omniauth['uid'] ).first
        if @auth
            # If we found an authorization, then sign in the user attached (user_id)
            user = User.where( id: @auth.user_id ).first
            if user
                session[:user_id] = @auth.user_id

                flash.notice = "Signed in!"
            else
                @auth.destroy!

                flash.alert = "Unable to sigin. Dwindling authentication methods. Please try again"
            end
        else
            # No authorization found. Sign up using the details provided by the provider

            # First; check that a user with the same email address doesn't already exist,
            # and that the email in question is valid.
            if not verify_google_email
                # Reject new sesssion! The Google email provided has not been verified
                flash.alert = "Failed to signup. Email address (#{info['email']}) has not been verified. Please verify this email on Google and retry"
            elsif User.where( email: info['email'] ).first
                # The email is already attached to an account. Reject this
                # sign in attempt (TODO: provide a user fix for this, there's no
                # way to sign in to their account if this clause is executed).
                flash.alert = "Unable to sign up; email address is already in use."
            else
                # No user exists with this email, and the email is verified. Create a new user.
                user = User.create( email: info['email'], name: info['name'], image_url: info['image'] )
                if user and not user.new_record?
                    # Created and saved user. Create a authorization attached to this user
                    new_auth = Authorization.create( uid: omniauth['uid'], provider: omniauth['provider'], user_id: user.id )

                    if new_auth and not new_auth.new_record?
                        session[:user_id] = new_auth.user_id

                        flash.notice = "Signed up and logged in. Welcome!"
                    else
                        flash.alert = "Failed to signup, server error. Please try again later"
                    end
                else
                    flash.alert = "Failed to signup, server error. Please try again later"
                end
            end
        end

        redirect_to redirect_path
    end

    ##
    # Destroy the session by setting the 'user_id' key to 'nil'.
    #
    # * redirects user to root
    def destroy
        session[:user_id] = nil
        redirect_to '/', notice: 'Signed out'
    end

private
    ##
    # Return 'true' if the provider is NOT Google. Otherwise, return true only if the
    # email is verified.
    def verify_google_email
        omniauth = request.env['omniauth.auth']
        omniauth['provider'] != 'google' or omniauth['extra']['id_info']['email_verified']
    end
end
