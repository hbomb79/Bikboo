class User < ApplicationRecord
    has_many :authorizations, dependent: :destroy
    has_many :projects
    has_many :notifications
    validates :name, :email, :image_url, :presence => true

    def first_name
        name.match /(\w+)/
    end

    def generate_auth_token
        until update( auth_token: SecureRandom.uuid )
            puts "WARNING: Regenerating auth_token for user #{name}. Failed to update. Likely due to auth_token not being unique."
        end
    end

    ##
    # If the user has recent activity to show, it is returned.
    #
    # If not, boolean 'false' is returned.
    def get_recent_activity( limit: 10, offset: 0 )
        return @recent if @recent and @recent.any?

        latest_activity = get_activity( limit: limit, offset: offset )

        # Filter out non-recent activity
        recent = latest_activity.where( "created_at >= ? ", 1.week.ago )

        @recent = recent.any? ? recent : false
    end

    ##
    # Returns a maximum of 10 activity entries, starting at the offset given
    # (if not given, starts at zero)
    #
    # This facilitates the 'Load more' functionality in the dashboard 'Recent Activity' pane.
    def get_activity( offset: 0, limit: 10 )
        Notification.offset( offset ).order( created_at: :desc ).limit( limit )
    end
end
