import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import {MatDialog, MatDialogConfig, MatDialogRef} from '@angular/material';

@Component({
  selector: 'add-directory-dialog',
  template: `
  <h2>Hi! I am the first dialog!</h2>
  <p>Test param: {{ param1 }}</p>
  <p>I'm working on a POC app, and I'm trying get the MdDialog component working. Does any one have a working example of what to pass to the MdDialog open method?</p>
  <button mat-raised-button (click)="dialogRef.close()">Close dialog</button>`
})
export class AddDirectoryDialog {
  param1: string;
  constructor(public dialogRef: MatDialogRef<any>) { }
}

@Component({
  selector: 'msi-directory',
  templateUrl: './msi-directory.component.html',
  styleUrls: ['./msi-directory.component.css']
})

export class MsiDirectoryComponent {
constructor(private dialog: MatDialog) { }

  openDialog(){
    let dialogRef: MatDialogRef<AddDirectoryDialog>;
    dialogRef = this.dialog.open(AddDirectoryDialog);
    return dialogRef.afterClosed();
  }

  displayedColumns = ['position', 'name', 'weight', 'symbol'];
  //dataSource = new ExampleDataSource();
}

export interface Element {
  name: string;
  position: number;
  weight: number;
  symbol: string;
}

const data: Element[] = [
  {position: 1, name: 'Hydrogen', weight: 1.0079, symbol: 'H'},
  {position: 2, name: 'Helium', weight: 4.0026, symbol: 'He'},
  {position: 3, name: 'Lithium', weight: 6.941, symbol: 'Li'},
  {position: 4, name: 'Beryllium', weight: 9.0122, symbol: 'Be'},
  {position: 5, name: 'Boron', weight: 10.811, symbol: 'B'},
  {position: 6, name: 'Carbon', weight: 12.0107, symbol: 'C'},
  {position: 7, name: 'Nitrogen', weight: 14.0067, symbol: 'N'},
  {position: 8, name: 'Oxygen', weight: 15.9994, symbol: 'O'},
  {position: 9, name: 'Fluorine', weight: 18.9984, symbol: 'F'},
  {position: 10, name: 'Neon', weight: 20.1797, symbol: 'Ne'},
  {position: 11, name: 'Sodium', weight: 22.9897, symbol: 'Na'},
  {position: 12, name: 'Magnesium', weight: 24.305, symbol: 'Mg'},
  {position: 13, name: 'Aluminum', weight: 26.9815, symbol: 'Al'},
  {position: 14, name: 'Silicon', weight: 28.0855, symbol: 'Si'},
  {position: 15, name: 'Phosphorus', weight: 30.9738, symbol: 'P'},
  {position: 16, name: 'Sulfur', weight: 32.065, symbol: 'S'},
  {position: 17, name: 'Chlorine', weight: 35.453, symbol: 'Cl'},
  {position: 18, name: 'Argon', weight: 39.948, symbol: 'Ar'},
  {position: 19, name: 'Potassium', weight: 39.0983, symbol: 'K'},
  {position: 20, name: 'Calcium', weight: 40.078, symbol: 'Ca'},
];

/**export class ExampleDataSource extends DataSource<any> {
  /** Connect function called by the table to retrieve one stream containing the data to render.
  connect(): Observable<Element[]> {
    return Observable.of(data);
  }

  disconnect() {}
}
**/
