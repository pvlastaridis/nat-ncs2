import {Component, OnDestroy, OnInit } from '@angular/core';
import { AlertService } from 'ng-jhipster';
import { ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs/Rx';

import { UploadService } from './upload.service';
import {Observable} from 'rxjs/Observable';
import { Http, Response } from '@angular/http';

@Component({
    selector: 'jhi-upload',
    templateUrl: './uploadResults.component.html'
})
export class UploadResultsComponent implements OnInit, OnDestroy {

    private subscription: Subscription;
    private routeParam: string;
    private varTimer: any;
    public fileUrl: string;
    uploadResults: any;
    selectedProtein: any;
    totalItems: any;
    queryCount: any;
    itemsPerPage: any;
    page: any;
    proteins: any;

    constructor(
        private http: Http,
        private alertService: AlertService,
        private uploadService: UploadService,
        private route: ActivatedRoute
    ) {
        this.page = 1;
        this.itemsPerPage = 5;
    }

    ngOnInit() {
        // this.languageService.addLocation('upload');
        this.subscription = this.route.params.subscribe((params) => {
            this.routeParam = params['id'];
            this.fileUrl = 'apins/files/' + this.routeParam;
            this.load(params['id']);
        });
        this.varTimer = null;
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
        clearTimeout(this.varTimer);
    }

    changeSelectedProtein(result) {
        this.selectedProtein = result;
    }

    load(id) {
        this.subscribeToSaveResponse(this.uploadService.find(id));
    }

    loadPage(page) {
        this.page = page;
        this.proteins = this.uploadResults.slice( this.itemsPerPage * (page - 1), this.itemsPerPage * page);
    }

    private subscribeToSaveResponse(result: Observable<Object>) {
        result.subscribe((res: Object) =>
            this.onSaveSuccess(res), (res: Response) => this.onSaveError(res));
    }

    private onSaveSuccess(result: Object) {
        // console.log(result);
        this.uploadResults = result;
        this.proteins = this.uploadResults.slice(0, this.itemsPerPage);
        this.totalItems = this.uploadResults.length;
        this.queryCount = this.uploadResults.length;
    }

    private onSaveError(error) {
        try {
            error.json();
        } catch (exception) {
            error.message = error.text();
        }
        this.onError(error);
    }

    private onError(error) {

        if (error.status === 404) {
            clearTimeout(this.varTimer);
            this.alertService.warning(error.headers.get('x-phosphpredapp-error'), null, null);
            this.varTimer = setTimeout(() => {
                this.load(this.routeParam);
            }, 5000);
        } else {
            this.alertService.addAlert(
                {
                    type: 'danger',
                    msg: error.headers.get('x-phosphpredapp-error'),
                    params: [],
                    timeout: 25000,
                    toast: false,
                    position: 'top right'
                }, []);
            this.uploadResults = true;
        }
    }

    getFile(bool: boolean) {
        this.http.get('/apins/files/' + this.routeParam).toPromise().then((response) => this.downloadFile(response)).catch(this.handleError);
    }

    private handleError(error: any): Promise<any> {
        console.error('An error occurred', error); // for demo purposes only
        return Promise.reject(error.message || error);
    }

    private downloadFile( data: Response ) {
        const blob = new Blob( [data], { type: 'text/csv' } );
        const url = window.URL.createObjectURL( blob );
        window.open('/apins/files/' + this.routeParam);
    }

    copyTextToClipboard() {
        const txtArea = document.createElement('textarea');

        txtArea.style.position = 'fixed';
        txtArea.style.top = '0';
        txtArea.style.left = '0';
        txtArea.style.opacity = '0';
        txtArea.value = 'http://localhost/#/upload-results/' + this.routeParam;
        document.body.appendChild(txtArea);
        txtArea.select();
        try {
            const successful = document.execCommand('copy');
            const msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copying text command was ' + msg);
            if (successful) {
                return true;
            }
        } catch (err) {
            console.log('Oops, unable to copy');
        }
        document.body.removeChild(txtArea);
        return false;
    }
}
