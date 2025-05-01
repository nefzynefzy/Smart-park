import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ParkingSettingsComponent } from './parking-settings.component';

describe('ParkingSettingsComponent', () => {
  let component: ParkingSettingsComponent;
  let fixture: ComponentFixture<ParkingSettingsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ParkingSettingsComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(ParkingSettingsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
