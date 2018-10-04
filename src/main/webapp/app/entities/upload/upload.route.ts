import { Routes } from '@angular/router';

import { UploadGuidelinesComponent } from './upload-guidelines.component';
import { UploadResultsComponent } from './uploadResults.component';
import {UploadInformationComponent} from './upload-information.component';
import {HomologsComponent} from './homologs.component';
import {ReferencesComponent} from './references.component';
import {MotifsComponent} from './motifs.component';

export const uploadRoute: Routes = [
    // {
    //     path: 'upload',
    //     component: UploadComponent,
    //     data: {
    //         pageTitle: 'phosphpredApp.upload.home.title'
    //     }
    // },
    {
        path: 'upload-results/:id',
        component: UploadResultsComponent,
        data: {
            pageTitle: 'global.upload.home.title'
        }
    },
    {
        path: 'guidelines',
        component: UploadGuidelinesComponent,
        data: {
            pageTitle: 'global.upload.home.title2'
        }
    },
    {
        path: 'introduction',
        component: UploadInformationComponent,
        data: {
            pageTitle: 'global.upload.home.title3'
        }
    },
    {
        path: 'homologs',
        component: HomologsComponent,
        data: {
            pageTitle: 'global.upload.home.title4'
        }
    },
    {
        path: 'references',
        component: ReferencesComponent,
        data: {
            pageTitle: 'global.upload.home.title5'
        }
    },
    {
        path: 'motifs',
        component: MotifsComponent,
        data: {
            pageTitle: 'global.upload.home.title6'
        }
    }
];
