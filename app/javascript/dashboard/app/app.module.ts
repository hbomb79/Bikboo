/* Modules */
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';

/* Components */
import { AppComponent } from './app.component';
import { DocumentViewerComponent } from './common/document-viewer.component.ts';
import { NavigationComponent } from './common/navigation.component.ts';
import { ProfileModalComponent } from './common/profile-modal.component.ts';

import { ProjectListComponent } from './dashboard/project-list.component.ts';
import { ProjectTileComponent } from './dashboard/project-tile.component.ts';
import { ProjectViewerComponent } from './dashboard/project-viewer.component.ts';

/* Services */
import { Location, LocationStrategy, PathLocationStrategy } from '@angular/common';

import { LoggerService } from './services/logger.service';
import { DocumentService } from './services/document.service';
import { UserService } from './services/user.service';
import { LocationService } from './services/location.service'

import { EmbeddedComponentsService, EMBEDDED_COMPONENTS } from './services/embeddedComponents.service';

const embeddableComponents = [ ProjectListComponent, ProjectTileComponent, ProjectViewerComponent ]

@NgModule({
    declarations: [
        AppComponent,
        DocumentViewerComponent,
        NavigationComponent,
        ProfileModalComponent,

        ProjectListComponent,
        ProjectTileComponent,
        ProjectViewerComponent
    ],
    imports: [
        BrowserModule,
        BrowserAnimationsModule,
        HttpClientModule
    ],
    providers: [
        LoggerService,
        DocumentService,
        UserService,
        LocationService,
        EmbeddedComponentsService,
        Location,
        { provide: LocationStrategy, useClass: PathLocationStrategy },
        { provide: EMBEDDED_COMPONENTS, useValue: embeddableComponents }
    ],
    entryComponents: embeddableComponents,
    bootstrap: [AppComponent]
})
export class AppModule { }
