import { NgModule } from '@angular/core';
import { MsiComponent } from './msi.component';
import { MsiRoutingModule } from './msi-routing.module';
import { SharedModule } from '../shared/shared.module';
import { MaterialModule, MdTableModule } from '@angular/material';
import { FormsModule } from '@angular/forms';
import { CdkTableModule } from '@angular/cdk';
import { FlexLayoutModule } from "@angular/flex-layout";
import { MsiChildModule } from "./child-components/child-components.module"

@NgModule({
  imports: [MaterialModule, FlexLayoutModule, FormsModule, MsiRoutingModule, MsiChildModule, MdTableModule, CdkTableModule],
  declarations: [MsiComponent],
  exports: [MsiComponent],
  providers: []
})
export class MsiModule { }
