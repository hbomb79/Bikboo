import { Component, ElementRef, HostBinding, HostListener,
         OnInit, ViewChild, ViewChildren } from '@angular/core';

import { DocumentService } from './services/document.service';
import { LoggerService } from './services/logger.service';
import { UserService } from './services/user.service';
import { LocationService } from './services/location.service';

import { DocumentContents } from './interfaces';

import templateString from './template.html';
@Component({
    selector: 'bikboo-shell',
    template: templateString
})
export class AppComponent implements OnInit {
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

    // Depending on the classes present on the 
    navigationEnabled: boolean = false;

    currentUrl: string;
    currentDocument: DocumentContents;

    constructor(
        private documentService: DocumentService,
        private userService: UserService,
        private locationService: LocationService,
        private logger: LoggerService,
        private hostElement: ElementRef,
    ) {}

    ngOnInit() {
        this.locationService.currentUrl.subscribe(url => {
            this.currentUrl = url;

            clearTimeout( this.progressBarTimeout )
            this.progressBarTimeout = setTimeout( () => {
                this.isFetching = true;
            }, 200 )
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
    onDocumentPrepared(){
        this.logger.debug("[Embedded Document] Prepared");
    }

    // Callback used to track the 'docRemoved' event on the DocumentViewerComponent
    onDocumentRemoved(){
        this.logger.debug("[Embedded Document] Removed");
    }

    // Callback used to track the 'docInserted' event on the DocumentViewerComponent
    onDocumentInserted(){
        this.logger.debug("[Embedded Document] Inserted");
    }

    // Callback used to track the 'viewSwapped' event on the DocumentViewerComponent
    onDocumentSwapComplete(){
        // Removes the rendering progress bar (if one is shown)
        // after a small delay to prevent flickering.
        setTimeout(() => {
            this.isRendering = false;
        }, 500);
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
