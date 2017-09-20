import { NgModule } from '@angular/core';
import { MsiComponent } from './msi.component';
import { MsiRoutingModule } from './msi-routing.module';
import { SharedModule } from '../shared/shared.module';
import { MaterialModule } from '@angular/material';
import { FormsModule } from '@angular/forms';
import { FlexLayoutModule } from "@angular/flex-layout";

@NgModule({
  imports: [MaterialModule, FlexLayoutModule, FormsModule, MsiRoutingModule],
  declarations: [MsiComponent],
  exports: [MsiComponent],
  providers: []
})
export class MsiModule { }
