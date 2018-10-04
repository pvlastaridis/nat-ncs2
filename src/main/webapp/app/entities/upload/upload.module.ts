import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { PhosphpredSharedModule } from '../../shared';
import { D3Component3Component } from '../d3-component3/d3-component3.component';

import {
    UploadService,
    UploadResultsComponent,
    UploadGuidelinesComponent,
    UploadInformationComponent,
    UploadComponent,
    uploadRoute, HomologsComponent, ReferencesComponent, MotifsComponent,
} from './';

const ENTITY_STATES = [
    ...uploadRoute
];

@NgModule({
    imports: [
        PhosphpredSharedModule,
        RouterModule.forRoot(ENTITY_STATES, { useHash: true })
    ],
    declarations: [
        UploadComponent,
        UploadResultsComponent,
        UploadGuidelinesComponent,
        D3Component3Component,
        UploadInformationComponent,
        HomologsComponent,
        MotifsComponent,
        ReferencesComponent
    ],
    entryComponents: [
        UploadComponent,
        UploadResultsComponent
    ],
    providers: [
        UploadService
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA],
    exports: [UploadComponent]
})
export class PhosphpredUploadModule {}
