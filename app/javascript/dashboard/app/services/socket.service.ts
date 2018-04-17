import { Injectable } from '@angular/core';

import { LoggerService } from './logger.service';

import ActionCable from 'actioncable';

@Injectable()
export class SocketService {
    public actionCable;

    /*
     * The SocketService provides a unified way to create and destroy
     * web socket connections.
     *
     * Dynamic components should avoid creating their own sockets; this functionality
     * is best handled by an associatted service (UserService, ProjectService, etc), or
     * AppComponent directly.
     */
	constructor( private logger: LoggerService) {
        if ( process.env.NODE_ENV != "production" )
            ActionCable.startDebugging();

        this.actionCable = ActionCable.createConsumer();

        (window as any).cable = this.actionCable;
    }

    restartCable() {
        this.actionCable.connect();
    }

    disconnectCable() {
        if( !this.actionCable.connection.disconnected )
            this.actionCable.disconnect();
    }
}
