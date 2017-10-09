import { NgModule } from '@angular/core';
import { MstComponent } from './mst.component';
import { MstRoutingModule } from './mst-routing.module';
import { SharedModule } from '../shared/shared.module';
import { MatCardModule, MatInputModule, MatCheckboxModule, MatButtonModule, MatSnackBarModule } from '@angular/material';
import { FormsModule } from '@angular/forms';
import { FlexLayoutModule } from "@angular/flex-layout";

@NgModule({
  imports: [MatCardModule, MatInputModule, MatButtonModule, MatCheckboxModule, MatSnackBarModule, FlexLayoutModule, FormsModule, MstRoutingModule],
  declarations: [MstComponent],
  exports: [MstComponent],
  providers: []
})
export class MstModule { }
