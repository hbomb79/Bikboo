include ActionView::Helpers::DateHelper

class ProjectsController < ApplicationController
    before_action :require_login

    def index
        respond_to do |format|
            format.html
            format.json do
                # render :json => {
                #     content: render_to_string( current_user.projects.order!( 'updated_at DESC' ), :formats => [:html] ),
                #     update_script: render_to_string( :formats => [:js] ),
                #     section_id: 'projects',
                #     section_title: 'Projects',
                #     title: 'Dashboard'
                # }
                render :json => {
                    content: render_to_string( :layout => false, :formats => [:html] ),
                    title: 'Dashboard',
                    sub_title: 'Projects'
                }
            end
        end
    end

    def show
        @project = Project.find params[:id]
    end

    def new
        @project = Project.new
    end

    def create
        title_field = ( params[:title] and !params[:title].empty? )
        terms_field = ( params[:tos] and params[:tos] == "on" )
        if not ( title_field and terms_field )
            respond_to do |format|
                format.html { redirect_to new_project_path, alert: "Failed to create project. Required fields (title and terms of service) not filled!" }
                format.js { render :json => { error: "Failed to create project, required fields not filled", field_error: true, fields: { :title => title_field, :tos => terms_field }, params: params }, status: :internal_server_error }
            end
        else
            begin
                project = Project.create!(user_id: session[:user_id], title: params[:title].truncate( 25, :omission => ''), desc: params[:desc].truncate( 250, :omission => "... (truncated)" ))

                if project and not project.new_record?
                    respond_to do |format|
                        format.html { redirect_to project, notice: "Project created!" }
                        format.json { render :json => { notice: "Project created!", project_id: project.id, params: params }, status: :ok }
                    end
                else
                    respond_to do |format|
                        format.html { redirect_to new_projects_path, alert: "Failed to create project. Server error occurred. Please try again later" }
                        format.json { render :json => { error: "Failed to create project. Server error occurred. Please try again later" }, status: :internal_server_error }
                    end
                end
            rescue ActiveRecord::InvalidRecord
                respond_to do |format|
                    format.html { redirect_to new_projects_path, alert: "Failed to create project, validation failed." }
                    format.json { render :json => { error: "Failed to create project, validation failed." }, status: :internal_server_error }
                end
            end
        end
    end

    def get_metadata
        payload = { project_count: current_user.projects.count, projects: {} }
        projects = payload[:projects]
        current_user.projects.each do |project|
            projects[project.id] = { raw: project.updated_at.to_s, formatted: time_ago_in_words( project.updated_at ) }
        end

        render :js => render_to_string( :locals => { :payload => payload } ), status: :ok
    end

private
    def construct_payload
        return current_user.projects
    end
end
