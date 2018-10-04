import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { D3Component3Component } from './d3-component3.component';

describe('D3Component3Component', () => {
  let component: D3Component3Component;
  let fixture: ComponentFixture<D3Component3Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ D3Component3Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(D3Component3Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should be created', () => {
    expect(component).toBeTruthy();
  });
});
