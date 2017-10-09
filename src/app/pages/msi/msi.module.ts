import { NgModule } from '@angular/core';
import { MsiComponent } from './msi.component';
import { MsiRoutingModule } from './msi-routing.module';
import { SharedModule } from '../shared/shared.module';
import { MatCardModule, MatInputModule, MatCheckboxModule, MatButtonModule, MatSnackBarModule } from '@angular/material';
import { FormsModule } from '@angular/forms';
import { FlexLayoutModule } from "@angular/flex-layout";
import { MsiChildModule } from "./child-components/child-components.module"

@NgModule({
  imports: [MatCardModule, MatInputModule, MatCheckboxModule, MatButtonModule, MatSnackBarModule, FlexLayoutModule, FormsModule, MsiRoutingModule, MsiChildModule],
  declarations: [MsiComponent],
  exports: [MsiComponent],
  providers: []
})
export class MsiModule { }
