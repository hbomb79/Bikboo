class ApplicationController < ActionController::Base
    SITE_NAME = "Bikboo"
    protect_from_forgery with: :exception

    before_action :validate_session

private
    ##
    # Redirects the user to the signin page (root [/]), with a 'continue'
    # URL parameter pointing to 'to_access' if provided, or '/' if not provided
    #
    # Use of absolute URLs here is discouraged as it opens up possibility
    # of malicious redirect paths. When rendering signin buttons, the 'continue'
    # argument to 'auth/google' should be filtered.
    def require_login(to_access: false)
        unless current_user
            respond_to do |format|
                format.html { redirect_to( "/?continue=#{to_access or request.fullpath}", alert: "You must be logged in to access this page. Please sign in with Google." ) }
                format.json do
                    render :json => { error: 'Unauthorized request. User must be logged in before JSON endpoint can be utilized', content: 'Failed' }, status: :unauthorized
                end
            end
        end
    end

    ##
    # Returns 'true' if the url provided is absolute, unless a block
    # is provided. If a block is provided, the block will be executed
    # with the 'url' if it's absolute, or 'false' if it's relative
    #
    # Allows controllers to ensure that the 'continue' URL pointing
    # to this site, and not a phishing site, etc...
    def url_absolute?(url)
        if block_given?
            yield url, ( /^https?:\/\//i.match? url ) ? url : false
        else
            /^https?:\/\//i.match? ( url )
        end
    end

    def current_user
        @user ||= User.find_by_id_and_auth_token( session[:user_id], session[:auth_token] ) if session[:user_id] and session[:auth_token]
    end

    ##
    # A session is automatically invalidated (the user is logged out)
    # if the auth_token in the session does not match the auth_token
    # in the database that's attached to the user_id
    def validate_session
        user_id = session[:user_id]
        auth_token = session[:auth_token]

        if user_id and auth_token and ( user_id == cookies.encrypted[:user_id] and auth_token == cookies.encrypted[:auth_token] )
            # Use find_by_id to avoid ActiveRecord::RecordNotFound exception
            user = User.find_by_id user_id

            unless user and user.auth_token == auth_token
                destroy_session
                
                redirect_to '/', alert: "Session invalidated; your user has been logged out of all devices. Please log in again."
            end
        elsif user_id or auth_token
            destroy_session
        end
    end

    def destroy_session(silent=false)
        return unless current_user
        current_user_id = current_user.id

        reset_session
        cookies.delete :user_id
        cookies.delete :auth_token

        ActionCable.server.broadcast "user_status:#{current_user_id}", { action: "destroy_session" } unless silent
    end

    helper_method :current_user, :url_absolute?
end
