import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { RouterModule } from '@angular/router';

import { PhosphpredSharedModule } from '../shared';

import { HOME_ROUTE, HomeComponent } from './';
import {PhosphpredUploadModule} from '../entities/upload/upload.module';

@NgModule({
    imports: [
        PhosphpredSharedModule,
        RouterModule.forRoot([ HOME_ROUTE ], { useHash: true }),
        PhosphpredUploadModule
    ],
    declarations: [
        HomeComponent,
    ],
    entryComponents: [
    ],
    providers: [
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class PhosphpredHomeModule {}
