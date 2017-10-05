import { Component, OnInit } from '@angular/core';
//import { DataSource } from '@angular/cdk/collections';
import {Observable} from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import {MdDialog, MdDialogConfig, MdDialogRef} from '@angular/material';

@Component({
  selector: 'add-directory-dialog',
  template: `
  <h2>Hi! I am the first dialog!</h2>
  <p>Test param: {{ param1 }}</p>
  <p>I'm working on a POC app, and I'm trying get the MdDialog component working. Does any one have a working example of what to pass to the MdDialog open method?</p>
  <button md-raised-button (click)="dialogRef.close()">Close dialog</button>`
})
export class AddDirectoryDialog {
  param1: string;
  constructor(public dialogRef: MdDialogRef<any>) { }
}

@Component({
  selector: 'msi-directory',
  templateUrl: './msi-directory.component.html',
  styleUrls: ['./msi-directory.component.css']
})

export class MsiDirectoryComponent {
  //displayedColumns = ['position', 'name', 'weight', 'symbol'];
  //dataSource = new ExampleDataSource();
}
