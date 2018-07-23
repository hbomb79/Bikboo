class HelpController < ApplicationController
    def index
        respond_to do |format|
            format.html
            format.json do
                render :json => {
                    content: render_to_string( :layout => false, :formats => [:html] ),
                    title: 'Help Centre',
                    sub_title: params[:category],
                    breadcrumbs: [ ['Help', '/help' ] ]
                }
            end
        end
    end

    def show
        respond_to do |format|
            format.html
            format.json do
                render :json => {
                    content: render_to_string( :layout => false, :formats => [:html] ),
                    title: 'Help Centre',
                    sub_title: params[:page],
                    breadcrumbs: [ [ 'Help', '/help/' ], [ params[:category], "/help/#{params[:category]}" ] ]
                }
            end
        end
    end
end
