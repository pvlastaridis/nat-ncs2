import { Component, OnInit } from '@angular/core';
import { Response } from '@angular/http';
import { JhiLanguageService, AlertService, DataUtils } from 'ng-jhipster';
import { Observable } from 'rxjs/Rx';

import { Upload } from './upload.model';
import { UploadService } from './upload.service';
import {Router} from '@angular/router';

@Component({
    selector: 'jhi-upload-results',
    templateUrl: './upload.component.html',
})
export class UploadComponent implements OnInit {

    upload: Upload;
    authorities: any[];
    isSaving: boolean;
    uploadType: boolean;

    error: any;
    success: any;
    reverse: any;

    constructor(
        private dataUtils: DataUtils,
        private alertService: AlertService,
        private uploadService: UploadService,
        private router: Router
    ) {
        this.uploadType = false;
        this.upload = {};
        this.upload.id = this.randomString(16, 'aA#');
    }

    ngOnInit() {
    }

    byteSize(field) {
        if (field) {
            return this.dataUtils.byteSize(field);
        } else {
            return 0;
        }
    }

    openFile(contentType, field) {
        return this.dataUtils.openFile(contentType, field);
    }

    setFileData(event, upload, field, isImage) {
        if (event.target.files && event.target.files[0]) {
            const file = event.target.files[0];
            if (isImage && !/^image\//.test(file.type)) {
                return;
            }
            this.dataUtils.toBase64(file, (base64Data) => {
                upload[field] = base64Data;
                upload[`${field}ContentType`] = file.type;
            });
        }
    }

    testdata() {
        this.upload.fasta_text = '>sp|P0AGM7|URAA_ECOLI Uracil permease OS=Escherichia coli (strain K12) GN=uraA PE=1 SV=1\n' +
            'MTRRAIGVSERPPLLQTIPLSLQHLFAMFGATVLVPVLFHINPATVLLFNGIGTLLYLFI\n' +
            'CKGKIPAYLGSSFAFISPVLLLLPLGYEVALGGFIMCGVLFCLVSFIVKKAGTGWLDVLF\n' +
            'PPAAMGAIVAVIGLELAGVAAGMAGLLPAEGQTPDSKTIIISITTLAVTVLGSVLFRGFL\n' +
            'AIIPILIGVLVGYALSFAMGIVDTTPIINAHWFALPTLYTPRFEWFAILTILPAALVVIA\n' +
            'EHVGHLVVTANIVKKDLLRDPGLHRSMFANGLSTVISGFFGSTPNTTYGENIGVMAITRV\n' +
            'YSTWVIGGAAIFAILLSCVGKLAAAIQMIPLPVMGGVSLLLYGVIGASGIRVLIESKVDY\n' +
            'NKAQNLILTSVILIIGVSGAKVNIGAAELKGMALATIVGIGLSLIFKLISVLRPEEVVLD\n' +
            'AEDADITDK';
    }

    save() {
        this.upload.uploadType = this.uploadType;
        this.isSaving = true;
        this.subscribeToSaveResponse(this.uploadService.create(this.upload));
    }

    private subscribeToSaveResponse(result: Observable<Upload>) {
        result.subscribe((res: Upload) =>
            this.onSaveSuccess(res), (res: Response) => this.onSaveError(res));
    }

    private onSaveSuccess(result: Upload) {
        this.isSaving = false;
        this.router.navigate(['/upload-results/' +  this.upload.id ]);
    }

    private onSaveError(error) {
        try {
            error.json();
        } catch (exception) {
            error.message = error.text();
        }
        this.isSaving = false;
        this.onError(error);
    }

    private onError(error) {
        this.alertService.error(error.message, null, null);
    }

    private randomString( length: number, chars: string ) {
        let mask = '';
        if (chars.indexOf('a') > -1) { mask += 'abcdefghijklmnopqrstuvwxyz'; }
        if (chars.indexOf('A') > -1) { mask += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; }
        if (chars.indexOf('#') > -1) { mask += '0123456789'; }
        let result = '';
        for (let i = length; i > 0; --i) { result += mask[Math.floor(Math.random() * mask.length)]; }
        return result;
    }

    copyTextToClipboard() {
        const txtArea = document.createElement('textarea');

        txtArea.style.position = 'fixed';
        txtArea.style.top = '0';
        txtArea.style.left = '0';
        txtArea.style.opacity = '0';
        txtArea.value = 'http://localhost/#/upload-results/' + this.upload.id;
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
