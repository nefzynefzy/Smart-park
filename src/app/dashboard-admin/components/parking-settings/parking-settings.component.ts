import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { FormsModule } from '@angular/forms';
import { Component, NgModule, OnInit } from '@angular/core';
import { AdminService } from '../../../services/admin.service';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';

// Interface pour typer les paramètres de parking
interface ParkingSettings {
  totalSpaces: number;
  hourlyRate: number;
}

@Component({
  selector: 'app-parking-settings',
  templateUrl: './parking-settings.component.html',
  styleUrls: ['./parking-settings.component.scss'],
  standalone: true,
  imports: [
    ReactiveFormsModule,
    FormsModule,
    CommonModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatCardModule
  ],
})
export class ParkingSettingsComponent implements OnInit {
  settingsForm: FormGroup;

  constructor(private adminService: AdminService, private fb: FormBuilder) {
    this.settingsForm = this.fb.group({
      totalSpaces: [0, [Validators.required, Validators.min(1)]],
      hourlyRate: [0, [Validators.required, Validators.min(0)]]
    });
  }

  ngOnInit(): void {
    this.loadSettings();
  }

  loadSettings(): void {
    this.adminService.getParkingSettings().subscribe((settings: ParkingSettings) => {
      this.settingsForm.patchValue({
        totalSpaces: settings.totalSpaces,
        hourlyRate: settings.hourlyRate
      });
    });
  }

  saveSettings(): void {
    if (this.settingsForm.valid) {
      this.adminService.updateParkingSettings(this.settingsForm.value).subscribe(() => {
        alert('Paramètres mis à jour avec succès');
      });
    }
  }
}
