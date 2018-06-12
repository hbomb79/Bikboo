import { Injectable, EventEmitter } from '@angular/core';
import 'rxjs/add/operator/do';
import 'rxjs/add/operator/map';

import { LoggerService } from './logger.service';

import { SidebarStatus } from '../interfaces';

@Injectable()
export class SidebarService {
    status = new EventEmitter<SidebarStatus>();

    // The type of sidebar to display.
    // 1 = Project Sidebar.
    type:number = 1;

    // The sidebar (in future) is dynamic, as it serves multiple
    // pages. This data object is dynamic and contains different
    // keys depending on the sidebar being used.
    data:any = false;

    protected isActive:boolean = false;
    set active( active:boolean ) {
        this.isActive = active;
        this.deploy();
    }

    get active() : boolean {
        return this.isActive;
    }
    
    protected isCollapsed:boolean = false;
    set collapsed( collapsed:boolean ) {
        this.isCollapsed = collapsed;
        this.deploy();
    }

    get collapsed() : boolean {
        return this.isCollapsed;
    }

    constructor( private logger: LoggerService ) {};
    protected deploy() {
        this.status.next(<SidebarStatus>{active: this.isActive, collapsed: this.isCollapsed});
    }

    toggle() {
        this.collapsed = !this.isCollapsed;
    }
}
