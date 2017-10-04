import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  tabs:any = [
      { path: 'msi', label: 'Create MSI' },
      { path: 'mst', label: 'Create MST' }
    ]

    getState(outlet) {
      return outlet.activatedRouteData.state;
  }
}
