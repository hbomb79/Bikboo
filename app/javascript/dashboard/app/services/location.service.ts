import { Injectable } from '@angular/core';
import { Location } from '@angular/common';
import { ReplaySubject } from 'rxjs/ReplaySubject';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/map';

import { LoggerService } from './logger.service';

@Injectable()
export class LocationService {
    private urlObservable = new ReplaySubject<string>(1);

    currentUrl = this.urlObservable
        .map(url => this.location.normalize( url ))
        .map(url => ( /(.*)(\?.+)/g.exec( url ) || [] )[1] )

    currentUrlParams = this.urlObservable
        .map(url => ( /(.*)\?(.+)/g.exec( url ) || [] )[2] )

    constructor( private location: Location, private logger: LoggerService ) {
        this.urlObservable.next( location.path( false ) );

        // Subscribe to popState changes
        this.location.subscribe(state => {
            this.logger.debug("Caught popstate change: ", state);
            return this.urlObservable.next( state.url || '' );
        })
    }

    handleAnchorClick( target: HTMLAnchorElement ) : boolean {
        this.logger.debug("Handling anchor click from anchor ", target);

        return true;
    }

    go( url: string ) {
        this.logger.debug("Travelling to url ", url);
        if(/^http/.test( url )) {
            window.location.assign( url );
        } else {
            this.location.go( url );
            // this.urlObservable.next( url );
        }
    }

    replace(url: string) {
        this.logger.debug("Travelling to url ", url, " via full page reload");
        window.location.replace( url );
    }
}
