import { Component, OnInit } from '@angular/core';
import { ChartConfiguration } from 'chart.js';
import { AdminService } from '../../../services/admin.service';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { CommonModule } from '@angular/common'; // <-- Add this
import { NgChartsModule } from 'ng2-charts';



@Component({
  selector: 'app-analytics',
  standalone: true,
  imports: [MatCardModule,MatProgressSpinnerModule,CommonModule,NgChartsModule],
  templateUrl: './analytics.component.html',
  styleUrls: ['./analytics.component.scss']
})
export class AnalyticsComponent implements OnInit {
  occupancyRate: number = 0;
  totalReservations: number = 0;
  revenue: number = 0;

  public barChartData: ChartConfiguration['data'] = {
    labels: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    datasets: [
      { data: [0, 0, 0, 0, 0, 0, 0], label: 'Réservations par jour' }
    ]
  };

  public barChartOptions: ChartConfiguration['options'] = {
    responsive: true,
  };

  constructor(private adminService: AdminService) {}

  ngOnInit(): void {
    this.loadAnalyticsData();
  }

  loadAnalyticsData(): void {
    this.adminService.getParkingAnalytics().subscribe(data => {
      this.occupancyRate = data.occupancyRate;
      this.totalReservations = data.totalReservations;
      this.revenue = data.revenue;
      this.barChartData.datasets[0].data = data.reservationsByDay;
    });
  }
}