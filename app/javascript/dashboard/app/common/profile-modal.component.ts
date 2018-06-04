import { Component, OnInit, Input, Output, ElementRef, ViewChild, HostListener } from '@angular/core'
import { UserInformation } from '../interfaces'

import { UserService } from '../services/user.service';

import { trigger, state, style, animate, transition } from '@angular/animations';

@Component({
    selector: 'app-profile-modal',
    template: `
        <div id="profile-modal" *ngIf="isOpen" [@modalState]>
            <div class="wrapper">
                <div id="top">
                    <div class="wrapper">
                        <div id="image">
                            <img bind-src="loggedInUser.image_url" alt="Profile avatar">
                        </div>
                        <span>{{loggedInUser.name}}</span>
                    </div>
                </div>
                <div id="mid">
                    <a href="/dashboard">Projects</a>
                    <a href="/account">Settings</a>
                    <a href="/help">Help</a>
                </div>
                <a href="/signout" class="button inplace no-follow" id="signout" #signout>Sign out</a>
            </div>
        </div>
    `,
    animations: [
        trigger("modalState", [
            transition(':enter', [
                style({ opacity: 0, top: "45px"}),
                animate('100ms ease-out', style({opacity: 1, top: "60px"}))
            ]),
            transition(':leave', [
                style({opacity: 1, top: "60px"}),
                animate('100ms ease-in', style({opacity: 0, top: "45px"}))
            ])
        ])
    ]
})
export class ProfileModalComponent implements OnInit {
    @Input("user") loggedInUser: UserInformation;
    @Output() isOpen:boolean = false;

    @ViewChild("signout") signOutButton:ElementRef;

    nativeElement:HTMLElement;

    constructor(elementRef: ElementRef, private userService: UserService) {
        this.nativeElement = elementRef.nativeElement;
    }

    ngOnInit() {}

    toggle() {
        this.isOpen = !this.isOpen
    }

    @HostListener('click', ['$event.target', '$event.button', '$event.ctrlKey', '$event.metaKey'])
    onClick( eventTarget: HTMLElement, button: number, ctrlKey: boolean, metaKey: boolean ) {
        if( button !== 0 || ctrlKey || metaKey || !this.signOutButton.nativeElement.contains( eventTarget ) ) {
            return true;
        }

        // To have gotten to this point, we must have clicked on the signOutButton child.
        // Sign the user out via the user service (this will handle all incoming websocket pings
        // so that we don't throw a 401 unauthorized error at the user while signing out).
        this.userService.signOut();
        return false;
    }
}
