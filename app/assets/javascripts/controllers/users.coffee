#= require core
#= require helpers/nav
#= require helpers/activity_pane
#= require helpers/projects_pane

$( document ).ready =>
    @activityPane = new ActivityPane
    @projectsPane = new ProjectsPane
