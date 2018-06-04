/* Modules */
import { BrowserModule, Title } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { NgModule, enableProdMode } from '@angular/core';
import { InlineSVGModule } from 'ng-inline-svg';

/* Components */
import { AppComponent } from './app.component';
import { DocumentViewerComponent } from './common/document-viewer.component.ts';
import { NavigationComponent } from './common/navigation.component.ts';
import { ProfileModalComponent } from './common/profile-modal.component.ts';

import { ProjectListComponent } from './dashboard/project-list.component.ts';
import { ProjectTileComponent } from './dashboard/project-tile.component.ts';
import { ProjectViewerComponent } from './dashboard/project-viewer.component.ts';
import { ProjectCreateComponent } from './dashboard/project-create.component.ts';

/* Services */
import { Location, LocationStrategy, PathLocationStrategy } from '@angular/common';

import { LoggerService } from './services/logger.service';
import { DocumentService } from './services/document.service';
import { UserService } from './services/user.service';
import { LocationService } from './services/location.service';
import { ProjectService } from './services/project.service';
import { SocketService } from './services/socket.service';

import { EmbeddedComponentsService, EMBEDDED_COMPONENTS } from './services/embeddedComponents.service';

const embeddableComponents = [ ProjectListComponent, ProjectTileComponent, ProjectViewerComponent, ProjectCreateComponent ]

if( process.env.NODE_ENV == 'production' )
    enableProdMode()

@NgModule({
    declarations: [
        AppComponent,
        DocumentViewerComponent,
        NavigationComponent,
        ProfileModalComponent,

        ProjectListComponent,
        ProjectTileComponent,
        ProjectViewerComponent,
        ProjectCreateComponent
    ],
    imports: [
        BrowserModule,
        BrowserAnimationsModule,
        HttpClientModule,
        InlineSVGModule
    ],
    providers: [
        LoggerService,
        DocumentService,
        UserService,
        LocationService,
        EmbeddedComponentsService,
        ProjectService,
        SocketService,
        Location,
        { provide: LocationStrategy, useClass: PathLocationStrategy },
        { provide: EMBEDDED_COMPONENTS, useValue: embeddableComponents },
        Title
    ],
    entryComponents: embeddableComponents,
    bootstrap: [AppComponent]
})
export class AppModule { }
