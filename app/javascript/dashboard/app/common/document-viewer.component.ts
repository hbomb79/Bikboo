import { Component, ViewContainerRef, OnInit,
         ElementRef, ComponentRef, OnDestroy, DoCheck,
         EventEmitter } from '@angular/core';

import { LoggerService } from '../services/logger.service';
import { DocumentService } from '../services/document.service';
import { EmbeddedComponentsService } from '../services/embeddedComponents.service';

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/switchMap';
import 'rxjs/add/operator/takeUntil';

import { DocumentContents } from '../interfaces';

// This constant must be true for animations to occur between
// view changes.
const ANIMATIONS:boolean = true;

// If this class is present on the host element (app-document-viewer)
// animations will NOT run, regardless of the above constant.
const ANIMATION_EXCLUDE:string = 'no-animations';

@Component({
    selector: 'app-document-viewer',
    template: ''
})
export class DocumentViewerComponent implements OnInit, DoCheck, OnDestroy {
    private hostElement: HTMLElement;

    // A list of component references, these will be delivered
    // from EmbbeddedComponentsService in this.loadNextView()
    protected embeddedComponents: ComponentRef<any>[];

    // This observable allows chaining of expressions
    // that would usually need intricate timing functions.
    // For example, animation chaining is simplified greatly
    // using this technique.
    private void$ = of<void>(undefined);
    private onDestroy$ = new EventEmitter<void>();
    private docContents = new EventEmitter<DocumentContents>();

    // These two divs allow simplified rotation of DOM elements.
    // It means that the next page has somewhere to go while the
    // components are (quickly) embedded. Without these, a brief
    // flicker would occur between the navigationStart and end.
    protected currentView: HTMLElement = document.createElement('div');
    protected pendingView: HTMLElement = document.createElement('div');

    constructor(
        elementRef: ElementRef,
        private logger: LoggerService,
        private documentService: DocumentService,
        private embeddedService: EmbeddedComponentsService
    ) {
        // Store a reference to the host element so that we can
        // swap views later (see this.rotateViews).
        this.hostElement = elementRef.nativeElement;
    }

    ngOnInit() {}
    ngDoCheck() {}
    ngOnDestroy() {}

    // Destroys the components inside the view and
    // resets 'this.embeddedComponents'.
    protected disassembleView() {
    }

    // Swaps the current view with the pending view.
    protected rotateViews() {
    }

    protected loadNextView() {
    }
}
