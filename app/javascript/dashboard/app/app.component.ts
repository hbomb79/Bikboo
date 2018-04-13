import { Component, ElementRef, HostBinding, HostListener,
         OnInit, ViewChild, ViewChildren } from '@angular/core';

import { trigger, state, style, animate, transition } from '@angular/animations';

import { DocumentService } from './services/document.service';
import { LoggerService } from './services/logger.service';
import { UserService } from './services/user.service';
import { LocationService } from './services/location.service';

import { DocumentContents } from './interfaces';

import templateString from './template.html';
@Component({
    selector: 'bikboo-shell',
    template: templateString,
    animations: [
        trigger("navState", [
            transition(':enter', [
                style({transform: 'translateY(-100%)', opacity: 0}),
                animate('100ms ease-out', style({transform: 'translateY(0)', opacity: 1}))
            ]),
            transition(':leave', [
                style({transform: 'translateY(0)', opacity: 1}),
                animate('100ms ease-in', style({transform: 'translateY(-100%)', opacity: 0}))
            ])
        ])
    ]
})
export class AppComponent implements OnInit {
    // A hash of DOM element configurations. Rather than these being sprinkled
    // throughout the class definition, they're all located here.
    // These are automatically updated when 'updateHost' is executed.
    protected DOMConfig = {
        banner: false as any,
        subBanner: false as any
    };

    isStarting:boolean = true;

    // When 'true', a progress bar representing the progress of document fetch
    // will be displayed
    isFetching:boolean = false;

    // When 'true', a loading bar will appear (typically replacing the progress
    // bar from above) which moves much faster with no predefined end. This is to
    // indicate 'rendering'.
    isRendering:boolean = false;

    // A place to store the timeout index for the progress bar.
    // This is used to prevent the appearance of the progress
    // bar if the page loads quick enough.
    private progressBarTimeout:any;

    currentUrl:string;
    currentDocument:DocumentContents;

    @HostBinding('class')
    protected hostClasses:string = '';

    constructor(
        private documentService: DocumentService,
        private userService: UserService,
        private locationService: LocationService,
        private logger: LoggerService,
        private hostElement: ElementRef,
    ) {}

    ngOnInit() {
        this.locationService.currentUrl.subscribe(url => {
            if( url == this.currentUrl ) {
                // As the URL has changed, but the normalised URL is the same,
                // we'll assume that only the hash component has changed.
                //TODO: Handle hash scroll.
            } else {
                this.currentUrl = url;

                clearTimeout( this.progressBarTimeout )
                this.progressBarTimeout = setTimeout( () => {
                    this.isFetching = true;
                }, 200 )
            }
        })
        this.documentService.currentDocument.subscribe(doc => this.currentDocument = doc);
    }

    // Callback used to track the 'docReceived' event on the DocumentViewerComponent
    onDocumentReceived(){
        // If the document was received within 200ms, the
        // timeout won't have completed and
        // a progress bar hasn't appeared. Don't show a rendering
        // bar in this situation.
        clearTimeout( this.progressBarTimeout );
        if( this.isFetching ) {
            this.isFetching = false;
            this.isRendering = true;
        }
    }

    // Callback used to track the 'docPrepared' event on the DocumentViewerComponent
    onDocumentPrepared(){ }

    // Callback used to track the 'docRemoved' event on the DocumentViewerComponent
    onDocumentRemoved(){ }

    // Callback used to track the 'docInserted' event on the DocumentViewerComponent
    onDocumentInserted() {
        setTimeout(() => this.updateHost(), 0);
    }

    // Callback used to track the 'viewSwapped' event on the DocumentViewerComponent
    onDocumentSwapComplete(){
        // If this was the initial load, set isStarting to false
        setTimeout(() => {
            this.isStarting = false

            this.updateHost()
        }, 0);

        // Removes the rendering progress bar (if one is shown)
        // after a small delay to prevent flickering.
        setTimeout(() => {
            this.isRendering = false;
        }, 500);
    }

    // Update the classes present on the host element, basing the new
    // values off of the values found in the embedded document.
    updateHost() {
        const pageSlug = this.currentUrl ? /^\/*(.+?)\/*$/g.exec( this.currentUrl )[1].replace(/\//g, '-') : 'index';

        this.DOMConfig.banner = pageSlug != "index"
        this.DOMConfig.subBanner = this.currentDocument.sub_title;

        this.hostClasses = [
            `page-${pageSlug}`,
            `tree-${pageSlug.match(/[^-]+/)[0]}`,
            `${this.isStarting ? "not-" : ""}ready`
        ].join(' ')
    }

    @HostListener('click', ['$event.target', '$event.button', '$event.ctrlKey', '$event.metaKey'])
    onClick( eventTarget: HTMLElement, button: number, ctrlKey: boolean, metaKey: boolean ) {
        if( button !== 0 || ctrlKey || metaKey ) {
            // The user either clicked the link with a button other than the left mouse click,
            // or was holding ctrl/meta key. Allow the browser to handle this request.
            return true
        }

        // If click occured on an element inside an anchor tag, we must climb up the tree until an
        // anchor tag is found.
        let current: HTMLElement|null = eventTarget;
        while( current && !( current instanceof HTMLAnchorElement ) ) {
            // Set the next target to the parent of this one; if there is no new
            // target, the while loop will no longer run.
            current = current.parentElement;
        }

        if( current instanceof HTMLAnchorElement ) {
            // We found an anchor tag, pass the request off to the
            // LocationService.

            // This function will return true if the attempt to handle
            // fails. This will allow the browser to handle the request
            // itself.
            // If all goes to plan, 'false' will be returned, stopping
            // the browser from processing the click any further.
            return this.locationService.handleAnchorClick( current )
        }
    }

    // @HostListener('window:resize', ['$event.target.innerWidth'])
    // onResize() {
    // }
}
