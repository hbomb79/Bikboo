import { Component, OnInit, Input, HostBinding,
         ElementRef, OnDestroy, EventEmitter } from '@angular/core'

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { interval } from 'rxjs/observable/interval';
import { switchMap } from 'rxjs/operators';
import 'rxjs/add/observable/interval';

import { trigger, style, animate, transition, query, stagger } from '@angular/animations';

import { ProjectMetadata, SidebarStatus } from '../interfaces';

import { LoggerService } from '../services/logger.service';
import { ProjectService } from '../services/project.service';
import { SidebarService } from '../services/sidebar.service';
import { LocationService } from '../services/location.service';

import $ from 'jquery';

const DEFAULT_PAGE:string = "overview";

@Component({
    selector: 'app-project-viewer',
    template: `
    <div id="fetch-errors" [ngSwitch]="fetchError?.status" *ngIf="fetchError">
        <section id="error" *ngSwitchCase="404">
            <h2 class="section-title">Project Not Found</h2>
            <p>The request for this projects details failed with 404 - not found. Please check that the URL for this project is correct, and that it hasn't moved or been removed.</p>
        </section>
        <section id="error" *ngSwitchCase="401">
            <h2 class="section-title">Permission denied</h2>
            <p>Unable to access project, request sender was deemed unauthorized by the server. Please check that the URL you accessed is correct.</p>
        </section>
        <section id="error" *ngSwitchDefault>
            <h2 class="section-title">Fetch Failed</h2>
            <p>We were unable to fetch project information from the remote server, please try again later.</p>
            <p>Error message received: <code>{{fetchError}}</code></p>
        </section>
    </div>
    <section class="main" *ngIf="!fetchError">
        <div class="content">
            <div class="loading" *ngIf="isFetching" [@loadingPlaceholders]>
                <p>Loading...</p>
            </div>
            <div *ngIf="projectMetadata && !isFetching">
                <!--<section id="header-notice" *ngIf="!projectMetadata.project.status">
                    <div class="wrapper warning" *ngIf="projectMetadata.slides.length > 1 && projectMetadata.slides.length < 10">
                        <p>Unable to submit project for creation because you haven't got enough slides; you need at least 10 slides to submit</p>
                    </div>
                    <div class="wrapper info" *ngIf="projectMetadata.slides.length >= 10">
                        <p>All done creating slides? Submit your project for creation!</p>
                    </div>
                </section>-->

                <div id="sidebar" class="dynamic-nav-padding">
                    <div class="wrapper">
                        <div class="title">
                            <h2>Project Editor</h2>
                            <span class="sub">{{projectMetadata?.project.title}}</span>
                        </div>
                        <div class="options">
                            <ul id="top-level">
                                <li><a href="#!overview" [class.active]="currentPage == 'overview'">Overview</a></li>
                                <li><a href="#!slides" [class.active]="currentPage == 'slides'">Slide Editor</a></li>
                                <li><a href="#!help" [class.active]="currentPage == 'help'">Help</a></li>
                                <li><a href="#!settings" [class.active]="currentPage == 'settings'">Settings</a></li>

                                <li id="bottom">
                                    <a (click)="toggleSidebar()">{{sidebarCollapsed && '' || 'Collapse'}}</a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div id="dynamic-container" [ngSwitch]="projectMetadata.slides.length">
                    <h2 id="section-title">{{currentPage}}</h2>
                    <div id="slide-notice" class="empty-notice" *ngSwitchCase="0">
                        <div class="wrapper clearfix">
                            <div id="left">
                                <img src="{{questionMarkSrc}}" alt="Question mark image"/>
                            </div>
                            <div id="right">
                                <h2>No Slides</h2>
                                <p>This project doesn't have any slides yet, create some now in our slide editor</p>
                                <a href="/editor/project/{{projectID}}" id="edit" class="button">Open Editor</a>
                            </div>
                        </div>
                    </div>
                    <div id="slides" *ngSwitchDefault>
                        <h2 class="section-title">Project Slides</h2>
                        <p>Test</p>
                    </div>
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
    questionMarkSrc = require("images/question-mark.png");

    protected projectMetadata:ProjectMetadata;
    protected isFetching:boolean = false;
    protected fetchError:Error;

    protected sidebarActive:boolean = false;
    protected sidebarCollapsed:boolean = false;

    protected onDestroy$ = new EventEmitter<void>();

    protected validPages:string[] = [ "overview", "slides", "help", "settings" ];
    protected _currentPage:string = DEFAULT_PAGE;
    set currentPage( page:string ) {
        if( page == this._currentPage )
            return;
        else if( this.validPages.indexOf( page ) > -1 )
            this._currentPage = page;
        else
            window.location.hash = `#!${DEFAULT_PAGE}`;
    }

    get currentPage() : string {
        return this._currentPage;
    }

    get sectionTitle() : string {
        return this.isFetching ? "Fetching Project" : "Project Breakdown"
    }

    constructor(
        private el: ElementRef,
        private logger: LoggerService,
        private projectService: ProjectService,
        private sidebarService: SidebarService,
        private locationService: LocationService
    ) {
        // Embedded component service doesn't apply property bindings so
        // the projectID must be fetched manually from the element.
        this.projectID = el.nativeElement.attributes.project.value;
        this.sidebarService.status.subscribe( ( status:SidebarStatus ) => {
            this.sidebarActive = status.active;
            this.sidebarCollapsed = status.collapsed;
        } );

        this.locationService.currentUrl
            .do( url => this.currentPage = ( /^#?!/.test( window.location.hash ) ) ? window.location.hash.substr( 2 ) : DEFAULT_PAGE )
            .takeUntil( this.onDestroy$ )
            .subscribe();
    }

    ngOnInit() {
        this.isFetching = true
        this.queryProjectInfo(() => {
            this.isFetching = false;
            setTimeout( () => {
                this.sidebarService.active = true;
                this.sidebarService.collapsed = false;
            }, 50 );

            Observable
                .interval(60000)
                .do(() => this.queryProjectInfo() )
                .takeUntil(this.onDestroy$)
                .subscribe();
        })
    }

    ngOnDestroy() {
        this.sidebarService.active = false;
        this.onDestroy$.emit();
    }

    toggleSidebar() {
        this.sidebarService.collapsed = !this.sidebarCollapsed;
    }

    protected queryProjectInfo(successCb = () => {}) {
        return this.projectService.getProjectInformation( this.projectID )
            .do(meta => this.projectMetadata = meta)
            .do(() => console.log( this.projectMetadata ))
            .catch(err => {
                this.fetchError = err;
                throw `Failed to fetch ${err.message}`;
            })
            .do(data => successCb())
            .subscribe();
    }
}
