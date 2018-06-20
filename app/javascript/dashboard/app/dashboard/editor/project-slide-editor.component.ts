import { Component, OnInit, Input, HostBinding,
         OnDestroy, EventEmitter, HostListener } from '@angular/core'

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { interval } from 'rxjs/observable/interval';
import { switchMap } from 'rxjs/operators';
import 'rxjs/add/observable/interval';

// import { trigger, style, animate, transition, query, stagger } from '@angular/animations';

import { ProjectData } from '../../interfaces';

import { LoggerService } from '../../services/logger.service';
import { ProjectService } from '../../services/project.service';

/*
 * This class uses a drag and drop slide editor; I'm using jQuery-UI for this.
 * I'm not sure if Angular has an elegant way to manage this, so for now, jQuery it is
 *
 * It seems so wrong... sorry.
 */

import $ from 'jquery'

@Component({
    selector: 'app-project-slide-editor',
    template: `
    <div class="wrapper" id="slide-container">
        <!-- TODO: Handle slides created
        <div class="slide new-placeholder">
        </div>-->
    </div>

    <div class="slide-editor">
        <div id="workspace">

        </div>
    </div>
    `,
    animations: []
})
export class ProjectSlideEditorComponent implements OnInit, OnDestroy {
    protected onDestroy$ = new EventEmitter<void>();
    protected htmlString:string = "<div class='test'><a href='#'>Foobar</a></div>";

    questionMarkSrc = require("images/question-mark.png");

    @Input() projectData:ProjectData;

    constructor(
        private logger: LoggerService,
        private projectService: ProjectService
    ) {}

    ngOnInit() {
        // Create the jQuery callbacks and whatnot.
        this.onResize();
    }

    ngOnDestroy() {
        this.onDestroy$.emit();
    }

    @HostListener('window:resize')
    onResize() {
        let scale = 1;
        const containerWidth = $(".content").width();
        const containerHeight = $(".content").height();
        const contentWidth = $(".slide-editor").width();
        const contentHeight = $(".slide-editor").height();

        if( containerWidth < contentWidth || containerHeight < contentHeight ) {
            scale = Math.min( Math.min( containerWidth / contentWidth, containerHeight / contentHeight ), 1 );
        }

        $(".slide-editor").css("transform", `translate( -50%, -50% ) scale(${scale})`);
    }
}
