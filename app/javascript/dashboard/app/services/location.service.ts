import { Injectable } from '@angular/core';
import { Location } from '@angular/common';
import { ReplaySubject } from 'rxjs/ReplaySubject';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/map';

import { LoggerService } from './logger.service';

@Injectable()
export class LocationService {
    urlObservable = new ReplaySubject<string>(1);

    currentUrl = this.urlObservable.map(url => this.location.normalize( url ));

    constructor( private location: Location, private logger: LoggerService ) {
        this.urlObservable.next( location.path( false ) );

        this.location.subscribe(state => {
            return this.urlObservable.next( state.url || '' );
        })
    }

    handleAnchorClick( target: HTMLAnchorElement ) : boolean {
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
        if(/^http/.test( url )) {
            window.location.assign( url );
        } else {
            this.location.go( url );
            this.urlObservable.next( url );
        }
    }

    replace(url: string) {
        window.location.replace( url );
    }
}
