##
# A class that responds using JSON (only). HTML responses will NOT be provided
# when interfacing with this class.
# 
class NotificationsController < ApplicationController
    # Uses the NotificationsController require_login private method,
    # NOT the ApplicationController version.
    before_action :require_login

    ##
    # Returns notifications for the
    # currently signed in user.
    #
    # If no user is signed in, the request will fail.
    # This failure is handled by the classes before_action.
    def index
        render :json => current_user.notifications, status: :ok
    end

    ##
    # Marks the provided notification as read. Removing the highlight.
    #
    # This will fail if the notification provided is not
    # attached to the signed in user.
    def update
        # TODO: Determine if this action is actually needed (notifications may not need a read state)
    end

    ##
    # Destroy/dismiss the notification using the ID provided.
    #
    # This will fail if the notification found using the ID
    # is not attached to the signed in user.
    def destroy
        notification = Notification.find params[:id]

        if notification.user_id != current_user.id then
            render :json => { error: "Unauthorized request. Notification with ID #{params[:id]} is not attached to this user" }, status: :unauthorized
        else
            begin
                notification.destroy!
            rescue ActiveRecord::RecordNotDestroyed
                render :json => { error: "Unable to destroy notification. ActiveRecord::RecordNotDestroyed caught during destruction"}, status: :internal_server_error
            else
                render :json => { info: "Notification destroyed" }, status: :ok
            end
        end
    rescue ActiveRecord::RecordNotFound
        render :json => { error: "Invalid request. Notification with ID #{params[:id]} not found" }, status: :bad_request
    end

private
    def require_login
        unless current_user
            render :json => { error: "Unauthorized request" }, status: :unauthorized
        end
    end
end
