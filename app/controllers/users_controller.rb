class UsersController < ApplicationController
    before_action :require_login, except: :get_current_user

    def show; end

    # def edit; end

    def get_current_user
        render :json => {
            user: ( current_user ? current_user.as_json : false )
        }
    end
end
