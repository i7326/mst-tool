import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MsiComponent } from './msi.component';

@NgModule({
  imports: [
    RouterModule.forChild([
      { path: 'msi', component: MsiComponent, data: { state: 'msi' } }
    ])
  ],
  exports: [RouterModule]
})

export class MsiRoutingModule { }
