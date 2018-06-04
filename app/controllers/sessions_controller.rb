class SessionsController < ApplicationController
    ##
    # The OAuth flow was successful, we are now authenticated
    # with a provider (Google).
    #
    # Check the Authorizations for a provider with the same
    # uid. If one is found, log in to the user associated.
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

        provider = omniauth['provider']
        uid = omniauth['uid']

        @auth = Authorization.find_by_provider_and_uid provider, uid
        if @auth
            begin
                user = User.find @auth.user_id
                signin_user user

                flash.notice = "Signed in!"
            rescue ActiveRecord::RecordNotFound
                @auth.destroy!
                flash.alert = "Unable to sign in. Authorization points to missing user account. Please try again now that dwindling authentications have been destroyed."
            end
        else
            # No authorization found. Sign up using the details provided by the provider

            # First; check that a user with the same email address doesn't already exist,
            # and that the email in question is valid.
            if not verify_google_email
                # Reject new session! The Google email provided has not been verified
                flash.alert = "Failed to sign up. Email address (#{info['email']}) has not been verified. Please verify this email on Google and retry"
            elsif User.find_by_email info['email']
                # The email is already attached to an account. Reject this
                # sign in attempt (TODO: provide a user fix for this, there's no
                # way to sign in to their account if this clause is executed).
                flash.alert = "Unable to sign up; email address is already in use."
            else
                # No user exists with this email, and the email is verified. Create a new user.
                user = User.create( email: info['email'], name: info['name'], image_url: info['image'] )
                if user and not user.new_record?
                    # Created and saved user. Create a authorization attached to this user
                    new_auth = Authorization.create( uid: uid, provider: provider, user_id: user.id )

                    if new_auth and not new_auth.new_record?
                        signin_user user

                        flash.notice = "Signed up and logged in. Welcome!"
                    else
                        flash.alert = "Failed to signup, server error. Please try again later"
                    end
                else
                    flash.alert = "Failed to signup, server error. Please try again later"
                end
            end
        end

        redirect_to flash.alert ? root_url : redirect_path
    end

    ##
    # Destroy the session by setting the 'user_id' key to 'nil'.
    #
    # * redirects user to root
    def destroy
        # If the get param 'revoke' is provided, the users authentication token is regenerated
        # logging them out of all devices
        if params[:revoke] then
            logger.warn "Session destruction confirmed; authentication token regenerated."
            current_user.generate_auth_token
            destroy_session true
        else
            destroy_session
        end

        # Redirect the user back to root with a notice indicating sign out successful.
        respond_to do |format|
            format.html { redirect_to '/', notice: 'Signed out' }
            format.json do
                render :json => {
                    content: 'Signed out!'
                }, status: :ok
            end
        end
    end

private
    ##
    # Return 'true' if the provider is NOT Google. Otherwise, return true only if the
    # email is verified.
    def verify_google_email
        omniauth = request.env['omniauth.auth']
        omniauth['provider'] != 'google' or omniauth['extra']['id_info']['email_verified']
    end

    ##
    # Sign in the user object passed
    # by issuing (or generating) an access
    # token for that user.
    def signin_user( user )
        raise "Invalid arguments passed. Expected 'user' model instance. Refusing to sign in user." unless user

        user.generate_auth_token unless user.auth_token

        reset_session
        session[:auth_token] = user.auth_token
        session[:user_id] = user.id

        # WebSockets don't have access to 'session', so we need to use cookies
        # I'm leaving 'session' above as is; it will still be used to invalidate
        # user sessions.
        cookies.encrypted[:user_id] = user.id
        cookies.encrypted[:auth_token] = user.auth_token
    end
end
