import { Component, OnInit, Input, HostBinding,
         ElementRef, OnDestroy, EventEmitter } from '@angular/core'

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { interval } from 'rxjs/observable/interval';
import { switchMap } from 'rxjs/operators';
import 'rxjs/add/observable/interval';

import { trigger, style, animate, transition, query, stagger } from '@angular/animations';

import { ProjectMetadata } from '../interfaces';

import { LoggerService } from '../services/logger.service';
import { ProjectService } from '../services/project.service';

@Component({
    selector: 'app-project-viewer',
    template: `
    <section id="error" *ngIf="fetchError">
        <h2 class="section-title">Fetch Failed</h2>
        <p>We were unable to fetch project information from the remote server, please try again later.</p>
        <p>Error message received: <code>{{fetchError}}</code></p>
    </section>
    <section id="project" *ngIf="!fetchError">
        <h2 class="section-title">{{sectionTitle}}</h2>
        <div class="content">
            <div class="loading" *ngIf="isFetching" [@loadingPlaceholders]>
                <p>Loading...</p>
            </div>
            <div class="project" *ngIf="projectMetadata && !isFetching" >
                <div id="top-row">
                    <div class="project-metadata">
                        <!-- Information about project, ability to change title/desc -->
                        <div id="project-title"><h2>Title</h2><span>{{projectMetadata.title}}</span></div>
                        <div id="project-desc"><h2>Desc</h2><span>{{projectMetadata.desc}}</span></div>
                    </div>
                    <div class="project-submission">
                        <!-- A separate tile for submitting the project for creation, or seeing the reason it was rejected -->
                        <p>You cannot submit your project yet because you don't have any slides</p>
                    </div>
                </div>
                <div class="project-slides">
                    <!-- Preview of all slides in the project, including a way to open the slide editor -->
                </div>
            </div>
        </div>
    </section>
    `,
    animations: [
        trigger('loadingPlaceholders', [
            transition(':enter', [
                style({opacity: 0}),
                animate('100ms ease-out', style({opacity: 1}))
            ]),
            transition(':leave', [
                style({opacity: 1}),
                animate('100ms ease-in', style({opacity: 0}))
            ])
        ])
    ]
})
export class ProjectViewerComponent implements OnInit {
    projectID:string = '';
    projectMetadata:ProjectMetadata;

    isFetching:boolean = false;

    fetchError:string = '';

    protected onDestroy$ = new EventEmitter<void>();
    protected void$ = of<void>(undefined);

    get sectionTitle() : string {
        return this.isFetching ? "Fetching Project" : "Project Breakdown"
    }

    constructor(
        private el: ElementRef,
        private logger: LoggerService,
        private projectService: ProjectService
    ) {
        // Embedded component service doesn't apply property bindings so
        // the projectID must be fetched manually from the element.
        this.projectID = el.nativeElement.attributes.project.value;
    }

    ngOnInit() {
        this.isFetching = true
        this.queryProjectInfo(() => {
            this.isFetching = false;

            Observable
                .interval(60000)
                .do(() => this.queryProjectInfo() )
                .takeUntil(this.onDestroy$)
                .subscribe();
        })
    }

    ngOnDestroy() {
        this.onDestroy$.emit();
    }

    protected queryProjectInfo(successCb = () => {}) {
        return this.void$
            .switchMap(() => this.projectService.getProjectInformation( this.projectID ) )
            .do(meta => this.projectMetadata = meta)
            .catch(err => {
                this.fetchError = `${err.name} - ${err.status}: ${err.message}`;
                throw `Failed to fetch ${err.message}`;
            })
            .do(data => successCb())
            .subscribe();
    }
}
