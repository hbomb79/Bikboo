/*	Core application sproket includer.
	
	Includes various required scripts, such as rails unobstructive JS wrapper and jQuery

	This JS script *should* be required by ALL controller javascript files (.coffee, .js).
	If this convention is followed, then this file will be available on every page. Therefore,
	any logic placed here will be executed on those pages.

	Controller-specific JS may make the decision to exclude the core.js file -- while
	not reccomended, this could be a reality. In this instance, logic here will
	not be included in the served JS and therefore not executed on those pages. 

	Copyright (c) Harry Felton 2017 */

//= require rails-ujs
//= require jquery
//= require jquery_ujs
//= require helpers/notices
//= require helpers/scroller

$(document).ready(function(){
    $(".google-auth-link").on( "click", function(){
        $(this).addClass( "loading inplace" );
    });
});
