import { Component, ElementRef, HostBinding, HostListener,
         OnInit, ViewChild, ViewChildren } from '@angular/core';

import { DocumentService } from './services/document.service';
import { LoggerService } from './services/logger.service';
import { UserService } from './services/user.service';
import { LocationService } from './services/location.service';

import templateString from './template.html';
@Component({
    selector: 'bikboo-shell',
    template: templateString
})
export class AppComponent implements OnInit {
    isStarting:boolean = true;
    isFetching:boolean = false;

    navigationEnabled: boolean = false;

    currentUrl: string;
    currentUrlParams: string;

    constructor(
        private documentService: DocumentService,
        private userService: UserService,
        private locationService: LocationService,
        private logger: LoggerService,
        private hostElement: ElementRef,
    ) {}

    ngOnInit() {
        this.locationService.currentUrl.subscribe(url => {
            this.logger.debug("LocationService has delivered new URL to AppComponent. New URL is ", url);
            this.currentUrl = url;
        })

        // this.locationService.currentUrlParams.subscribe(params => {
        //     console.log("Url has changed! Url params are now", params);
        //     this.currentUrlParams = params;
        // })
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
