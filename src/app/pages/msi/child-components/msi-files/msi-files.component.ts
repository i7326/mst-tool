import { Component, OnInit } from '@angular/core';
import { DataSource } from '@angular/cdk/collections';
import { BehaviorSubject } from 'rxjs/BehaviorSubject';
import { MatDialog, MatDialogConfig, MatDialogRef } from '@angular/material';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import 'rxjs/add/operator/startWith';
import 'rxjs/add/observable/merge';
import 'rxjs/add/operator/map';


@Component({
  selector: 'add-files-dialog',
  template: `
  <tree-root [nodes]="nodes" [options]="customTemplateStringOptions" (activate)="onEvent($event)"
    (onActiveChanged)="onEvent($event)"
    (onFocus)="onEvent($event)"
    (onBlur)="onEvent($event)">
      </tree-root>


  <h2>Hi! I am the first dialog!</h2>
  <p>Test param: {{ param1 }}</p>
  <p>I'm working on a POC app, and I'm trying get the MdDialog component working. Does any one have a working example of what to pass to the MdDialog open method?</p>
  <button mat-raised-button (click)="dialogRef.close()">Close dialog</button>`
})

export class AddFilesDialog implements OnInit {
  param1: string;
  onEvent($event) {
    alert("Test");
    console.log($event)
  }
  nodes = [
    {
      expanded: true,
      name: 'Destination Computer',
      subTitle: 'the root',
      children: [
        {
          name: 'My Documents', children: [
            { name: 'My Pictures' }
          ]
        },
        {
          name: 'Program Files', children: [
            { name: 'Common Files' }
          ]
        },
        {
          name: 'Windows', children: [
            {
              name: 'Profiles', children: [
                {
                  name: 'All Users', children: [
                    { name: 'Application Data' },
                  ]
                },
                { name: 'Desktop' },
                {
                  name: 'Local Settings', children: [
                    { name: 'Application Data' },
                  ]
                },
              ]
            },
            { name: 'Temp' }
          ]
        },
      ]
    }
  ];


  constructor(public dialogRef: MatDialogRef<any>) { }


  customTemplateStringOptions = {
    //displayField: 'subTitle',
    isExpandedField: 'expanded',
    idField: 'uuid',
    nodeHeight: 23,
    allowDrag: true,
    useVirtualScroll: true
  }

  ngOnInit() {
    console.log('test');
  }


}

@Component({
  selector: 'msi-files',
  templateUrl: './msi-files.component.html',
  styleUrls: ['./msi-files.component.css']
})

export class MsiFilesComponent implements OnInit {
  size: number = data.length;

  constructor(private dialog: MatDialog) { }

  ngOnInit() {
    console.log();
  }


  openDialog() {
    let dialogRef: MatDialogRef<AddFilesDialog>;
    dialogRef = this.dialog.open(AddFilesDialog);
    return dialogRef.afterClosed();
  }

  displayedColumns = ['position', 'name', 'weight'];
  dataSource = new ExampleDataSource();
}

export interface Source {
  id: number;
  dest: string;
  source: string;
  symbol: string;
}

const data: Source[] = [
  { id: 1, dest: 'Hydrogen', source: '1.0079', symbol: 'H' },
  { id: 2, dest: 'Helium', source: '4.0026', symbol: 'He' },
  { id: 3, dest: 'Lithium', source: '6.941', symbol: 'Li' },
  { id: 4, dest: 'Beryllium', source: '9.0122', symbol: 'Be' }
];

export class SourceFilesDatabase {

}

export class ExampleDataSource extends DataSource<any> {
  /** Connect function called by the table to retrieve one stream containing the data to render. */
  connect(): Observable<Source[]> {
    return Observable.of(data);
  }

  disconnect() { }
}
