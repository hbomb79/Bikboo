class ApplicationController < ActionController::Base
    SITE_NAME = "Bikboo"
    protect_from_forgery with: :exception

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
            flash.alert = "You must be logged in to access this page. Please sign in with Google."
            redirect_to to_access ? "/?continue=#{to_access}" : "/"
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
        @user ||= User.where( id: session[:user_id] ).first if session[:user_id]
    end

    helper_method :current_user, :url_absolute?
end
