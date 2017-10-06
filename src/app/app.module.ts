import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MaterialModule, MdTableModule } from '@angular/material';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { MstModule } from './pages/mst/mst.module';
import { MsiModule } from './pages/msi/msi.module';
import { SharedModule } from './pages/shared/shared.module';



@NgModule({
  declarations: [AppComponent],
  imports: [
    AppRoutingModule,
    MsiModule,
    MstModule,
    BrowserModule,
    BrowserAnimationsModule,
    MaterialModule,
    MdTableModule,
    SharedModule.forRoot()
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
