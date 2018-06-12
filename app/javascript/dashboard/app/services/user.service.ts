import { Injectable, EventEmitter } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';

import { Observable } from 'rxjs/Observable';
import { of } from 'rxjs/observable/of';
import { interval } from 'rxjs/observable/interval';
import { switchMap } from 'rxjs/operators';
import 'rxjs/add/observable/interval';

import { UserInformation } from '../interfaces';

import { LoggerService } from './logger.service';
import { LocationService } from './location.service';
import { SocketService } from './socket.service';

@Injectable()
export class UserService {
    currentUser = new EventEmitter<UserInformation>();
    user:UserInformation;
    private socket;
    private signingOut:boolean;

    constructor(
        private logger: LoggerService,
        private http: HttpClient,
        private socketService: SocketService,
        private locationService: LocationService
    ) {
        this.getAuthenticationDetails(() => {
            Observable
                .interval(60000)
                .do(() => this.getAuthenticationDetails() )
                .subscribe();
        });
    }

    signOut() {
        // When signing out, the server will transmit a 'destroy_session' ping,
        // telling the client that the user has signed out in another tab.
        // This isn't correct however, we want to supress this message while signing out
        // and instead tell the user their signout was successful.

        //TODO: If the websocket is broken (can happen if the users cookie is incorrect, or
        // a server connection issue), signing out completely stops working (or, more accurately,
        // the user is signed out but receives no feedback and simply sits on the same page).
        // This is because the user is only considered 'signed out' by the client when the websocket
        // receives a 'destroy_session' ping. To fix this, we should move the signout logic here
        // and simply tell the websocket to ignore incoming pings (don't display duplicate signed out
        // notifications).
        this.signingOut = true;
        this.http.get<any>('/signout.json', { responseType: 'json' } )
            .subscribe({
                error: (error) => {
                    this.logger.dump("error", "Failure while trying to sign out current user. Not able to continue de-auth process.", error);
                }
            });
    }

    protected getAuthenticationDetails( cb = (user?) => {} ) {
        this.http.get<any>('/api/user.json', { responseType: 'json' })
            .subscribe(
                (data) => {
                    this.currentUser.next( data.user );
                    cb(data.user);
                    this.determineSocket( data.user );
                    this.user = data.user;
                },
                (error) => {
                    this.logger.dump("error", "Failure while trying to fetch authentication details from server.", error);
                }
            );
    }

    protected determineSocket( user ) {
        if( user )
            this.establishSocketConnection()
        else
            this.destroySocketConnection( true );
    }

    protected establishSocketConnection() {
        if( this.socket ) return

        this.socket = this.socketService.actionCable.subscriptions.create( "UserChannel", {
            received: (data) => {
                setTimeout( () => {
                    switch( data.action ) {
                        case 'destroy_session': {
                            return this.getAuthenticationDetails((user) => {
                                if( !user ) {
                                    if( this.signingOut ) {
                                        (window as any).notices.queue("Signed out!");
                                        this.signingOut = false;
                                        this.locationService.go("/");
                                    } else {
                                        (window as any).notices.queue("Signed out in another tab!");
                                    }
                                }
                            });
                        }
                        case 'revoke_auth_token': {
                            return this.getAuthenticationDetails((user) => {
                                if( !user ) {
                                    if( this.signingOut ){
                                        (window as any).notices.queue("Signed out of all devices");
                                        this.signingOut = false;
                                        this.locationService.go("/");
                                    } else {
                                        (window as any).notices.queue("Account authentication token has been revoked. Please sign in again to issue a new token.", true);
                                    }
                                }
                            })
                        }
                    }
                }, 250 );
            },
            disconnected: ({willAttemptReconnect}) => {
                if( !willAttemptReconnect )
                    this.destroySocketConnection();
            }
        });
    }

    protected destroySocketConnection( uninstall = false ) {
        if( this.socket ) {
            this.socket.unsubscribe()
            this.socket = undefined;
        }

        if( uninstall )
            this.socketService.disconnectCable();
    }
}
