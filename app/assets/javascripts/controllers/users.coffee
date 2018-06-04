#= require core
#= require helpers/nav
#= require helpers/activity_pane
#= require helpers/projects_pane

window.addEventListener 'load', =>
    @activityPane = new ActivityPane
    @projectsPane = new ProjectsPane
, false
