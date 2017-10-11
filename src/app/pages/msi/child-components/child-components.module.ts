import { NgModule } from '@angular/core';
import { MatInputModule, MatButtonModule, MatDialogModule, MatTableModule, MatCheckboxModule, MatPaginatorModule } from '@angular/material';
import { FlexLayoutModule } from "@angular/flex-layout";
import { MsiFilesComponent,AddFilesDialog } from './msi-files/msi-files.component';
import { TreeModule } from 'angular-tree-component';

@NgModule({
  imports: [FlexLayoutModule, MatInputModule, MatDialogModule, MatButtonModule, MatTableModule, MatCheckboxModule, MatPaginatorModule, TreeModule],
  declarations: [MsiFilesComponent, AddFilesDialog],
  exports: [MsiFilesComponent, AddFilesDialog],
  providers: [],
  entryComponents: [
        AddFilesDialog,
    ]
})

export class MsiChildModule { }
