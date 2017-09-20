import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MsiComponent } from './msi.component';

@NgModule({
  imports: [
    RouterModule.forChild([
      { path: 'msi', component: MsiComponent }
    ])
  ],
  exports: [RouterModule]
})

export class MsiRoutingModule { }
