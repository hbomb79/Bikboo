#= require core
#= require helpers/nav
#= require helpers/ajax_loader

window.addEventListener 'load', =>
    # @activityPane = new ActivityPane
    # @projectsPane = new ProjectsPane
    @ajaxLoader = new AjaxLoader
, false
