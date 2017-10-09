import { NgModule } from '@angular/core';
import { MatInputModule, MatButtonModule, MatDialogModule, MatTableModule } from '@angular/material';
import { FlexLayoutModule } from "@angular/flex-layout";
import { MsiDirectoryComponent,AddDirectoryDialog } from './msi-directory/msi-directory.component';

@NgModule({
  imports: [FlexLayoutModule, MatInputModule, MatDialogModule, MatButtonModule, MatTableModule],
  declarations: [MsiDirectoryComponent, AddDirectoryDialog],
  exports: [MsiDirectoryComponent, AddDirectoryDialog],
  providers: [],
  entryComponents: [
        AddDirectoryDialog,
    ]
})

export class MsiChildModule { }
