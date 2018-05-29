import { Component, OnInit, OnDestroy,
         EventEmitter, ViewChild, ElementRef, AfterViewInit } from '@angular/core'

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { interval } from 'rxjs/observable/interval';
import { switchMap } from 'rxjs/operators';
import 'rxjs/add/observable/interval';

import { LoggerService } from '../services/logger.service';
import { ProjectService } from '../services/project.service';

import $ from 'jquery';

@Component({
    selector: 'app-project-create',
    template: `
    <form action="/api/projects" data-remote="true" method="post" #projectCreate>
        <section id="title">
            <label for="title">Title</label>
            <input type="text" name="title">
        </section>
        <section id="desc">
            <label for="desc">Description</label>
            <textarea placeholder="This field is optional" name="desc"></textarea>
        </section>
        <section id="tos">
            <input type="checkbox" id="agree-terms">
            <span for="agree-terms">I agree to the <a href="#">terms and conditions of service</a>.</span>
        </section>
        <section id="submit">
            <input type="submit" name="commit" value="Create Project" class="button" data-disable-with="Create Project">
        </section>
    </form>
    `
})
export class ProjectCreateComponent implements AfterViewInit {
    protected onDestroy$ = new EventEmitter<void>();

    @ViewChild("projectCreate") formElement:ElementRef;

    constructor(private logger: LoggerService, private projectService: ProjectService) { }

    ngAfterViewInit() {
        console.log( $(this.formElement) );
        $( this.formElement.nativeElement ).on("ajax:error", (event:any) => {
            (window as any).detail = event;

            if( ( typeof event.detail[0] ) == "object" && event.detail[0].error ) {
                this.creationError( event.detail );
            } else {
                (window as any).notices.queue("We couldn't create a project for you; something's wrong on our end. Rest assured that we're working on a fix as fast as we can!", true);
                console.error("[FATAL] Uncaught exception: Unable to create a project due to unidentifiable error (no JSON response from server REST endpoint). Dump follows");
                console.log( event );
            }
        }).on("ajax:success", (event, xhr) => {
            console.log("SUCCESS");
            this.creationSuccess( event.detail );
        });
    }

    protected creationError( details:any ) {
        if( details.field_error ) {
            // Highlight invalid fields (found in details.fields)
        }

        (window as any).notices.queue(details[0].error, true)
    }

    protected creationSuccess( details:any ) {

    }
}
