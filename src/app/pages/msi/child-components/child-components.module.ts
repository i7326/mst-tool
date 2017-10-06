import { NgModule } from '@angular/core';
import { MaterialModule, MdTableModule } from '@angular/material';
import { FlexLayoutModule } from "@angular/flex-layout";
import { CdkTableModule } from '@angular/cdk';
import { MsiDirectoryComponent,AddDirectoryDialog } from './msi-directory/msi-directory.component';

@NgModule({
  imports: [FlexLayoutModule, MaterialModule, MdTableModule, CdkTableModule],
  declarations: [MsiDirectoryComponent, AddDirectoryDialog],
  exports: [MsiDirectoryComponent, AddDirectoryDialog],
  providers: [],
  entryComponents: [
        AddDirectoryDialog,
    ]
})

export class MsiChildModule { }
