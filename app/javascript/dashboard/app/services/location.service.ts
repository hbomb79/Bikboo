import { Injectable } from '@angular/core';
import { Location } from '@angular/common';
import { ReplaySubject } from 'rxjs/ReplaySubject';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/map';

import { LoggerService } from './logger.service';

@Injectable()
export class LocationService {
    urlObservable = new ReplaySubject<string>(1);

    currentUrl = this.urlObservable
        .map(url => this.location.normalize( url ));
        // .map(url => ( /(.*)(\?.+)/g.exec( url ) || [] )[1] );

    currentUrlParams = this.urlObservable
        .map(url => ( /(.*)\?(.+)/g.exec( url ) || [] )[2] );

    constructor( private location: Location, private logger: LoggerService ) {
        this.urlObservable.next( location.path( false ) );

        // Subscribe to popState changes
        this.location.subscribe(state => {
            this.logger.warn("Caught popstate change: ", state);
            return this.urlObservable.next( state.url || '' );
        })
    }

    handleAnchorClick( target: HTMLAnchorElement ) : boolean {
        this.logger.debug("Handling anchor click from anchor ", target);

        if(
            target.classList.contains('no-follow') ||
            target.download ||
            target.host !== window.location.host ||
            target.protocol !== window.location.protocol ) {
            return true;
        }

        // Knowing that the protocol and host are the same,
        // take the rest of the URL and travel there (as it's internal).
        this.go( target.pathname + target.search + target.hash );

        // Disallow further processing of this URL.
        return false;
    }

    go( url: string ) {
        this.logger.debug("Travelling to url ", url);
        if(/^http/.test( url )) {
            this.logger.warn("External URL, travelling");
            window.location.assign( url );
        } else {
            this.logger.warn("Internal URL, travelling");
            this.location.go( url );
            this.urlObservable.next( url );
        }
    }

    replace(url: string) {
        this.logger.debug("Travelling to url ", url, " via full page reload");
        window.location.replace( url );
    }
}
