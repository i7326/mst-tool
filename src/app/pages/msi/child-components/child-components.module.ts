import { NgModule } from '@angular/core';
import { MaterialModule } from '@angular/material';
import { MsiDirectoryComponent } from './msi-directory/msi-directory.component';

@NgModule({
  imports: [MaterialModule],
  declarations: [MsiDirectoryComponent],
  exports: [MsiDirectoryComponent],
  providers: []
})

export class MsiChildModule { }
