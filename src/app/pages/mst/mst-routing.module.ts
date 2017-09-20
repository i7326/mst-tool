import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MstComponent } from './mst.component';

@NgModule({
  imports: [
    RouterModule.forChild([
      {path: '', redirectTo: 'mst', pathMatch: 'full' },
      { path: 'mst', component: MstComponent }
    ])
  ],
  exports: [RouterModule]
})
export class MstRoutingModule { }
