import { Component, ViewContainerRef, ElementRef,
         ComponentRef, OnDestroy, DoCheck,
         EventEmitter, Input, Output, Inject } from '@angular/core';

import { Title } from '@angular/platform-browser';

import { LoggerService } from '../services/logger.service';
import { DocumentService } from '../services/document.service';
import { EmbeddedComponentsService } from '../services/embeddedComponents.service';

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import 'rxjs/add/operator/catch';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/delay';
import 'rxjs/add/operator/switchMap';
import 'rxjs/add/operator/takeUntil';

import $ from 'jquery';

import { DocumentContents } from '../interfaces';

// This constant must be true for animations to occur between
// view changes.
const ANIMATIONS:boolean = true;

// If this class is present on the host element (app-document-viewer)
// animations will NOT run, regardless of the above constant.
const ANIMATION_EXCLUDE:string = 'no-animations';

@Component({
    selector: 'app-document-viewer',
    template: ``
})
export class DocumentViewerComponent implements DoCheck, OnDestroy {
    hostElement: HTMLElement;

    // A list of component references, these will be delivered
    // from EmbbeddedComponentsService in this.loadNextView()
    protected embeddedComponents: ComponentRef<any>[] = [];

    // This observable allows chaining of expressions
    // that would usually need intricate timing functions.
    // For example, animation chaining is simplified greatly
    // using this technique.
    private void$ = of<void>(undefined);
    private onDestroy$ = new EventEmitter<void>();
    private docContents$ = new EventEmitter<DocumentContents>();

    // These two divs allow simplified rotation of DOM elements.
    // It means that the next page has somewhere to go while the
    // components are (quickly) embedded. Without these, a brief
    // flicker would occur between the navigationStart and end.
    protected currentView: HTMLElement = document.createElement('div');
    protected pendingView: HTMLElement = document.createElement('div');

    // The document has been received from the document service
    // and processing is about to begin
    @Output() docReceived = new EventEmitter<void>();

    // The document and it's embedded components (if any)
    // have been prepared
    @Output() docPrepared = new EventEmitter<void>();

    // The old document view has been removed from the DOM
    @Output() docRemoved = new EventEmitter<void>();

    // The new document view has been inserted in to the DOM
    @Output() docInserted = new EventEmitter<void>();

    // The views have been swapped (new is now current, old
    // has been freed from memory).
    @Output() viewSwapped = new EventEmitter<void>();

    // The document has been updated from AppComponent!
    // Emit the new document contents via the EventEmitter.
    // This will allow the DocumentViewer to switchMap the
    // render for the new document (allowing it to be cancelled)
    // if a new document comes in.
    @Input()
    set doc(document: DocumentContents) {
        if( document ) {
            this.docContents$.emit( document );
        }
    }

    @Input() hasBanner:boolean;

    constructor(
        elementRef: ElementRef,
        @Inject( ViewContainerRef ) private viewContainerRef,
        private titleService: Title,
        private logger: LoggerService,
        private documentService: DocumentService,
        private embeddedService: EmbeddedComponentsService
    ) {
        // Store a reference to the host element so that we can
        // swap views later (see this.rotateViews).
        this.hostElement = elementRef.nativeElement;

        $( this.currentView ).addClass("dynamic-nav-padding document");
        $( this.pendingView ).addClass("dynamic-nav-padding document");

        this.docContents$
            .switchMap( doc => this.loadNextView( doc ) )
            .takeUntil( this.onDestroy$ ) // When this notifier emits a value, stop.
            .subscribe(); // Subscribe now to start the observable
    }

    // Call detectChanges on each component to tell
    // Angular to call lifecycle hooks
    ngDoCheck() {
        this.embeddedComponents.forEach(comp => comp.changeDetectorRef.detectChanges());
    }

    // Component is being destroyed! Emit the 'onDestroy'
    // event so that the docContents$ pipe responsible
    // for rendering documents finishes
    ngOnDestroy() {
        this.onDestroy$.emit();
    }

    // Destroys the components inside the view and
    // resets 'this.embeddedComponents'.
    protected disassembleView() {
        this.embeddedComponents.forEach(comp => comp.destroy());
        this.embeddedComponents = [];
    }

    // Swaps the current view with the pending view.
    protected rotateViews() {
        const animationsEnabled = ANIMATIONS && !this.hostElement.classList.contains( ANIMATION_EXCLUDE )
        function runAnimation(target:HTMLElement, animatingIn:boolean, duration:number = 200) {
            return of(target)
                .do(() => {
                    $( target )[ animatingIn ? "addClass" : "removeClass" ]( "active" )
                })
                .delay(duration);
        }

        return of(this.currentView)
            .switchMap(view => {
                if( view.parentElement ) {
                    return runAnimation( view, false )
                        .do(() => view.parentElement.removeChild( view ))
                        .do(() => this.docRemoved.emit())
                        .switchMap(() => of( this.pendingView ) )
                }

                return of( this.pendingView );
            })
            .do(view => this.hostElement.appendChild( view ))
            .do(() => this.docInserted.emit())
            .switchMap(pending => {
                const old = this.currentView;
                this.currentView = pending;
                this.pendingView = old;
                this.pendingView.innerHTML = '';

                return of( pending )
            })
            .delay( animationsEnabled ? 200 : 0 )
            .switchMap(view => {
                return runAnimation( view, true )
                    .do(() => this.viewSwapped.emit())
            })
            .catch(err => {
                this.logger.error( `[Document viewer] Unable to rotate views, error: ${ err.message || err.stack || err }` )
                return of( err )
            });
    }

    protected loadNextView(doc: DocumentContents) : Observable<DocumentContents> {
        this.docReceived.emit();
        this.pendingView.innerHTML = doc.content || '';

        return of(doc)
            .switchMap(() => this.embeddedService.createEmbedded( this.pendingView, this.viewContainerRef ) )
            .do(comps => {
                this.disassembleView()
                this.embeddedComponents = comps
                this.docPrepared.emit()
            })
            .do(() => this.titleService.setTitle( "Bikboo \u2014 " + doc.title || 'No Title' ) )
            .switchMap(() => this.rotateViews())
            .catch(err => {
                this.logger.error(`Failed to load next view for document titled "${doc.title}", error: "${err.stack || err}".`);
                return of( err );
            });
    }
}
