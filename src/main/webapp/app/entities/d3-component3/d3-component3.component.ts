import {AfterViewInit, Component, Input, OnInit} from '@angular/core';
// import * as pvz from module('/target/www/pviz-bundle.js');
declare var pviz: any;
declare var $: any;

@Component({
  selector: 'jhi-app-d3-component3',
  templateUrl: './d3-component3.component.html',
  styleUrls: ['./d3-component3.component.css'],
})
export class D3Component3Component implements OnInit, AfterViewInit {

  private pviz: any;

  _protein: any = {};

  @Input() set protein(value: string) {

      this._protein = value;

      if (this._protein) {
          const seqEntry = new pviz.SeqEntry({
              sequence: this._protein.seq
          });

          const view = new pviz.SeqEntryAnnotInteractiveView({
              model: seqEntry,
              el: '#main'
          });
          view.render();
          const ptFeatures = [];
          let index = 0;
          for (const data of this._protein.motifs) {
              ptFeatures.push({

                  category: 'Motifs',
                  type: 'bar' + index++,
                  start: data.locationFrom,
                  end: data.locationTo,
                  text: index + '',
                  description: data.name,
              });
          }
          seqEntry.addFeatures(ptFeatures);
      }
  }

  get protein(): string {

      return this._protein;
  }

  constructor() {
      this._protein.name = '';
      this._protein.seq = '';
  }

  ngOnInit() {
  }

  ngAfterViewInit() {
  }
}
